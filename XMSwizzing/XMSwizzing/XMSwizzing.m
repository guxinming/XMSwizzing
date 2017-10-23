//
//  XMSwizzing.m
//  XMSwizzing
//
//  Created by 李良明 on 2017/10/19.
//  Copyright © 2017年 李良明. All rights reserved.
//

#import "XMSwizzing.h"
#import <objc/runtime.h>
#import <objc/message.h>

#define aspect_invoke(aspects, info) \
for (AspectIdentifier *aspect in aspects) {\
[aspect invokeWithInfo:info];\
if (aspect.options & AspectOptionAutomaticRemoval) { \
aspectsToRemove = [aspectsToRemove?:@[] arrayByAddingObject:aspect]; \
} \
}

@implementation NSObject (XMSwizzing)

+ (id<AspectToken>)aspect_hookSelector:(SEL)selector withOptions:(AspectOptions)options usingBlock:(id)block error:(NSError *__autoreleasing *)error
{
    return aspect_add((id)self, selector, options, block, error);
}

- (id<AspectToken>)aspect_hookSelector:(SEL)selector withOptions:(AspectOptions)options usingBlock:(id)block error:(NSError *__autoreleasing *)error
{
    return aspect_add((id)self, selector, options, block, error);
}

static AspectsContainer *aspect_getContainerForObject(NSObject *self, SEL selector) {
    NSCParameterAssert(self);
    //改变方法名称，在原有基础上拼接 aspects_
    SEL aliasSelector = aspect_aliasForSelector(selector);
    AspectsContainer *aspectContainer = objc_getAssociatedObject(self, aliasSelector);
    if (!aspectContainer) {
        aspectContainer = [AspectsContainer new];
        objc_setAssociatedObject(self, aliasSelector, aspectContainer, OBJC_ASSOCIATION_RETAIN);
    }
    return aspectContainer;
}

static AspectsContainer *aspect_getContainerForClass(Class klass, SEL selector) {
    NSCParameterAssert(klass);
    AspectsContainer *classContainer = nil;
    do {
        classContainer = objc_getAssociatedObject(klass, selector);
        if (classContainer.hasAspects) break;
    }while ((klass = class_getSuperclass(klass)));
    
    return classContainer;
}

static void aspect_hookedGetClass(Class class, Class statedClass) {
    NSCParameterAssert(class);
    NSCParameterAssert(statedClass);
    Method method = class_getInstanceMethod(class, @selector(class));
    IMP newIMP = imp_implementationWithBlock(^(id self) {
        return statedClass;
    });
    class_replaceMethod(class, @selector(class), newIMP, method_getTypeEncoding(method));
}

static void __ASPECTS_ARE_BEING_CALLED__(__unsafe_unretained NSObject *self, SEL selector, NSInvocation *invocation) {
    NSCParameterAssert(self);
    NSCParameterAssert(invocation);
    SEL originalSelector = invocation.selector;
    SEL aliasSelector = aspect_aliasForSelector(invocation.selector);
    invocation.selector = aliasSelector;
    AspectsContainer *objectContainer = objc_getAssociatedObject(self, aliasSelector);
    AspectsContainer *classContainer = aspect_getContainerForClass(object_getClass(self), aliasSelector);
    AspectInfo *info = [[AspectInfo alloc] initWithInstance:self invocation:invocation];
    NSArray *aspectsToRemove = nil;
    
    // Before hooks.
    aspect_invoke(classContainer.beforeAspects, info);
    aspect_invoke(objectContainer.beforeAspects, info);
    
    // Instead hooks.
    BOOL respondsToAlias = YES;
    if (objectContainer.insteadAspects.count || classContainer.insteadAspects.count) {
        aspect_invoke(classContainer.insteadAspects, info);
        aspect_invoke(objectContainer.insteadAspects, info);
    }else {
        Class klass = object_getClass(invocation.target);
        do {
            if ((respondsToAlias = [klass instancesRespondToSelector:aliasSelector])) {
                [invocation invoke];
                break;
            }
        }while (!respondsToAlias && (klass = class_getSuperclass(klass)));
    }
    
    // After hooks.
    aspect_invoke(classContainer.afterAspects, info);
    aspect_invoke(objectContainer.afterAspects, info);
    
    // If no hooks are installed, call original implementation (usually to throw an exception)
    if (!respondsToAlias) {
        invocation.selector = originalSelector;
        SEL originalForwardInvocationSEL = NSSelectorFromString(AspectsForwardInvocationSelectorName);
        if ([self respondsToSelector:originalForwardInvocationSEL]) {
            ((void( *)(id, SEL, NSInvocation *))objc_msgSend)(self, originalForwardInvocationSEL, invocation);
        }else {
            [self doesNotRecognizeSelector:invocation.selector];
        }
    }
    
    // Remove any hooks that are queued for deregistration.
    [aspectsToRemove makeObjectsPerformSelector:@selector(remove)];
}

static void aspect_swizzleForwardInvocation(Class klass) {
    NSCParameterAssert(klass);
    // If there is no method, replace will act like class_addMethod.
    IMP originalImplementation = class_replaceMethod(klass, @selector(forwardInvocation:), (IMP)__ASPECTS_ARE_BEING_CALLED__, "v@:@");
    if (originalImplementation) {
        class_addMethod(klass, NSSelectorFromString(AspectsForwardInvocationSelectorName), originalImplementation, "v@:@");
    }
    //AspectLog(@"Aspects: %@ is now aspect aware.", NSStringFromClass(klass));
}

static void _aspect_modifySwizzledClasses(void (^block)(NSMutableSet *swizzledClasses)) {
    static NSMutableSet *swizzledClasses;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        swizzledClasses = [NSMutableSet new];
    });
    @synchronized(swizzledClasses) {
        block(swizzledClasses);
    }
}

static Class aspect_swizzleClassInPlace(Class klass) {
    NSCParameterAssert(klass);
    NSString *className = NSStringFromClass(klass);
    
    _aspect_modifySwizzledClasses(^(NSMutableSet *swizzledClasses) {
        if (![swizzledClasses containsObject:className]) {
            aspect_swizzleForwardInvocation(klass);
            [swizzledClasses addObject:className];
        }
    });
    return klass;
}

static Class aspect_hookClass(NSObject *self, NSError **error) {
    NSCParameterAssert(self);
    Class statedClass = self.class;
    Class baseClass = object_getClass(self);
    NSString *className = NSStringFromClass(baseClass);
    
    // Already subclassed
    if ([className hasSuffix:AspectsSubclassSuffix]) {
        return baseClass;
        
        // We swizzle a class object, not a single object.
    }else if (class_isMetaClass(baseClass)) {
        //如果是 元类, hook 住 __aspects_forwardInvocation:方法，并将其指向新的方法，返回的是当前类
        return aspect_swizzleClassInPlace((Class)self);
        // Probably a KVO'ed class. Swizzle in place. Also swizzle meta classes in place.
    }else if (statedClass != baseClass) {
        //返回的是当前的类的子类，
        return aspect_swizzleClassInPlace(baseClass);
    }
    
    // Default case. Create dynamic subclass.
    const char *subclassName = [className stringByAppendingString:AspectsSubclassSuffix].UTF8String;
    Class subclass = objc_getClass(subclassName);
    
    if (subclass == nil) {
        subclass = objc_allocateClassPair(baseClass, subclassName, 0);
        if (subclass == nil) {
//            NSString *errrorDesc = [NSString stringWithFormat:@"objc_allocateClassPair failed to allocate class %s.", subclassName];
//            AspectError(AspectErrorFailedToAllocateClassPair, errrorDesc);
            return nil;
        }
        
        aspect_swizzleForwardInvocation(subclass);
        aspect_hookedGetClass(subclass, statedClass);
        aspect_hookedGetClass(object_getClass(subclass), statedClass);
        objc_registerClassPair(subclass);
    }
    
    object_setClass(self, subclass);
    return subclass;
}

static BOOL aspect_isMsgForwardIMP(IMP impl) {
    return impl == _objc_msgForward
#if !defined(__arm64__)
    || impl == (IMP)_objc_msgForward_stret
#endif
    ;
}

static IMP aspect_getMsgForwardIMP(NSObject *self, SEL selector) {
    IMP msgForwardIMP = _objc_msgForward;
#if !defined(__arm64__)
    // As an ugly internal runtime implementation detail in the 32bit runtime, we need to determine of the method we hook returns a struct or anything larger than id.
    // https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/LowLevelABI/000-Introduction/introduction.html
    // https://github.com/ReactiveCocoa/ReactiveCocoa/issues/783
    // http://infocenter.arm.com/help/topic/com.arm.doc.ihi0042e/IHI0042E_aapcs.pdf (Section 5.4)
    Method method = class_getInstanceMethod(self.class, selector);
    const char *encoding = method_getTypeEncoding(method);
    BOOL methodReturnsStructValue = encoding[0] == _C_STRUCT_B;
    if (methodReturnsStructValue) {
        @try {
            NSUInteger valueSize = 0;
            NSGetSizeAndAlignment(encoding, &valueSize, NULL);
            
            if (valueSize == 1 || valueSize == 2 || valueSize == 4 || valueSize == 8) {
                methodReturnsStructValue = NO;
            }
        } @catch (__unused NSException *e) {}
    }
    if (methodReturnsStructValue) {
        msgForwardIMP = (IMP)_objc_msgForward_stret;
    }
#endif
    return msgForwardIMP;
}

static void aspect_prepareClassAndHookSelector(NSObject *self, SEL selector, NSError **error) {
    NSCParameterAssert(selector);
    Class klass = aspect_hookClass(self, error);
    Method targetMethod = class_getInstanceMethod(klass, selector);
    IMP targetMethodIMP = method_getImplementation(targetMethod);
    if (!aspect_isMsgForwardIMP(targetMethodIMP)) {
        // Make a method alias for the existing method implementation, it not already copied.
        const char *typeEncoding = method_getTypeEncoding(targetMethod);
        SEL aliasSelector = aspect_aliasForSelector(selector);
        if (![klass instancesRespondToSelector:aliasSelector]) {
            __unused BOOL addedAlias = class_addMethod(klass, aliasSelector, method_getImplementation(targetMethod), typeEncoding);
            NSCAssert(addedAlias, @"Original implementation for %@ is already copied to %@ on %@", NSStringFromSelector(selector), NSStringFromSelector(aliasSelector), klass);
        }
        
        // We use forwardInvocation to hook in.
        class_replaceMethod(klass, selector, aspect_getMsgForwardIMP(self, selector), typeEncoding);
        //AspectLog(@"Aspects: Installed hook for -[%@ %@].", klass, NSStringFromSelector(selector));
    }
}

static id aspect_add(id self, SEL selector, AspectOptions options, id block, NSError **error) {
    NSCParameterAssert(self);
    NSCParameterAssert(selector);
    NSCParameterAssert(block);

    __block AspectIdentifier *identifier = nil;
    aspect_performLocked(^{
        //首先判断是否可以替换
        if (aspect_isSelectorAllowedAndTrack(self, selector, options, error)) {
            //获取容器，如果没有创建一个 并且将容器与方法名称动态关联
            AspectsContainer *aspectContainer = aspect_getContainerForObject(self, selector);
            //创建identifier
            identifier = [AspectIdentifier identifierWithSelector:selector object:self options:options block:block error:error];
            if (identifier) {
                
                //并且添加到容器中
                [aspectContainer addAspect:identifier withOptions:options];

                // Modify the class to allow message interception.
                aspect_prepareClassAndHookSelector(self, selector, error);
            }
        }
    });
    return identifier;
}

static NSMutableDictionary *aspect_getSwizzledClassesDict() {
    static NSMutableDictionary *swizzledClassesDict;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        swizzledClassesDict = [NSMutableDictionary new];
    });
    return swizzledClassesDict;
}

static BOOL aspect_isSelectorAllowedAndTrack(NSObject *self, SEL selector, AspectOptions options, NSError **error) {
    static NSSet *disallowedSelectorList;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        disallowedSelectorList = [NSSet setWithObjects:@"retain", @"release", @"autorelease", @"forwardInvocation:", nil];
    });
    
    // Check against the blacklist.(无法被替换的方法)
    NSString *selectorName = NSStringFromSelector(selector);
    if ([disallowedSelectorList containsObject:selectorName]) {
        return NO;
    }
    
    // Additional checks.
    AspectOptions position = options&AspectPositionFilter;
    if ([selectorName isEqualToString:@"dealloc"] && position != AspectPositionBefore) {
        return NO;
    }
    
    //类中不包含要替换的方法
    if (![self respondsToSelector:selector] && ![self.class instancesRespondToSelector:selector]) {
        return NO;
    }
    
    // Search for the current class and the class hierarchy IF we are modifying a class object
    if (class_isMetaClass(object_getClass(self))) {
        Class klass = [self class];
        NSMutableDictionary *swizzledClassesDict = aspect_getSwizzledClassesDict();
        Class currentClass = [self class];
        
        AspectTracker *tracker = swizzledClassesDict[currentClass];
        //子类已经hook了需要替换的方法
        if ([tracker subclassHasHookedSelectorName:selectorName]) {
            return NO;
        }
        
        do {
            tracker = swizzledClassesDict[currentClass];
            if ([tracker.selectorNames containsObject:selectorName]) {
                if (klass == currentClass) {
                    // Already modified and topmost!
                    return YES;
                }

                return NO;
            }
        } while ((currentClass = class_getSuperclass(currentClass)));
        
        // Add the selector as being modified.
        currentClass = klass;
        AspectTracker *subclassTracker = nil;
        do {
            tracker = swizzledClassesDict[currentClass];
            if (!tracker) {
                tracker = [[AspectTracker alloc] initWithTrackedClass:currentClass];
                swizzledClassesDict[(id<NSCopying>)currentClass] = tracker;
            }
            if (subclassTracker) {
                [tracker addSubclassTracker:subclassTracker hookingSelectorName:selectorName];
            } else {
                [tracker.selectorNames addObject:selectorName];
            }
            
            // All superclasses get marked as having a subclass that is modified.
            subclassTracker = tracker;
        }while ((currentClass = class_getSuperclass(currentClass)));
    } else {
        return YES;
    }
    
    return YES;
}

@end
