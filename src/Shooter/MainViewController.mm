//
//  ViewController.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "MainViewController.h"
#import "HGGame.h"
#import "Common.h"
#import "TitleView.h"
#import "AppDelegate.h"
#import "BackgroundView.h"
#import "MenuView.h"
#import "TroopsView.h"

@interface MainViewController()
{
    // shootingView
    ViewController* gameViewController;
    
    // title
    TitleView* title;
    
    // background
    BackgroundView* backgroundView;
    
    // menu
    MenuView* menuView;
}
@end

static MainViewController* instance = nil;

@implementation MainViewController

- (void)dealloc
{
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        // メンバ初期化
        instance = self;
        menuView = NULL;
        
        // 背景
        backgroundView = [[BackgroundView alloc] init];
        assert(backgroundView != nil);
        [self.view addSubview:backgroundView];
        
        // タイトルメニュー
        title = [[TitleView alloc] init];
        assert(title != nil);
        [self.view addSubview:title];
        
    }
    return self;
}

+(void)Start
{
    if (instance)
    {
        [instance start];
    }
}

-(void)start
{
    [title removeFromSuperview];
    [title release];
    title = NULL;
    
    [self showMenu];
}

-(void)showMenu
{
    assert(menuView == NULL);
    menuView = [[MenuView alloc] init];
    [self.view addSubview:menuView];
}

+(void)StageStart
{
    if (instance)
    {
        [instance stageStart];
    }
}

-(void)stageStart
{
    // 背景終了
    [backgroundView clearGL];
    [backgroundView removeFromSuperview];
    backgroundView = NULL;
    
    // ゲーム開始
    gameViewController = [[ViewController alloc] init];
    [self presentViewController:gameViewController animated:NO completion:^{
        // nothing
    }];
}

+(void)ShowTroops
{
    if (instance)
    {
        [instance showTroops];
    }
}

-(void)showTroops
{
    // メニューをかくしてテーブルを表示
    [UIView animateWithDuration:0.2 animations:^{
        CGRect f = menuView.frame;
        f.origin.x = f.size.width;
        menuView.frame = f;
    } completion:^(BOOL finished) {
        TroopsView* t = [[TroopsView alloc] init];
        [self.view addSubview:t];
    }];
}

@end
