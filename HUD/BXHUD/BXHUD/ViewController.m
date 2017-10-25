//
//  ViewController.m
//  BXHUD
//
//  Created by 李良明 on 2017/6/19.
//  Copyright © 2017年 李良明. All rights reserved.
//

#import "BXHUD.h"

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

    [BXHUD showBXGIFHUDToView:self.view GIFImageName:@"baixin.gif" animateDuration:4 text:@""];
    
    [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(hideBXHUD) userInfo:nil repeats:NO];
}

- (void)hideBXHUD
{
    [BXHUD hideBXHUDForView:self.view];
    [BXHUD showBXNormalHUDToView:self.view text:@"加载失败" compelete:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
