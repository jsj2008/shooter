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
#import "MenuView.h"
#import "TroopsView.h"
#import "UserData.h"
#import "AllyViewController.h"
#import "StatusView.h"
#import "BackgroundView.h"
#import "UIColor+MyCategory.h"

@interface MainViewController()
{
    // shootingView
    ViewController* gameViewController;
    
    // title
    TitleView* title;
    
    // background
    //BackgroundView* backgroundView;
    
    // menu
    MenuView* menuView;
    TroopsView* troopsView;
    
    // status
    StatusView* statusView;
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
        instance = self;
        menuView = NULL;
        
        // 背景
        //backgroundView = [[BackgroundView alloc] init];
        //assert(backgroundView != nil);
        //[self.view addSubview:backgroundView];
        
        // タイトルメニュー
        title = [[TitleView alloc] init];
        assert(title != nil);
        [self.view addSubview:title];
        
        //[self.view setBackgroundColor:[UIColor colorWithHexString:@"#111133"]];
        
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
    // データロード
    hg::UserData::sharedUserData()->loadData();
    //HGGame::userinfo::loadData();
    
    // タイトル
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
    
    statusView = [[StatusView alloc] init];
    [self.view addSubview:statusView];
    [statusView loadUserInfo];
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
    //[backgroundView clearGL];
    //[backgroundView removeFromSuperview];
    //backgroundView = NULL;
    
    // ゲーム開始
    gameViewController = [[ViewController alloc] init];
    [self presentViewController:gameViewController animated:NO completion:^{
        // nothing
    }];
}

+(void)PresentViewController:(UIViewController*) vc
{
    if (instance)
    {
        [instance presentViewController:vc];
    }
}

- (void)presentViewController:(UIViewController*)vc
{
    [self presentViewController:vc animated:YES completion:^{
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
    AllyViewController* avc = [[[AllyViewController alloc] initWithViewMode:AllyViewModeSelectAlly] autorelease];
    //[self addChildViewController:avc];
    
    avc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:avc animated:YES completion:^{
    }];
}

+(void)HideTroops
{
    if (instance)
    {
        [instance hideTroops];
    }
}

-(void)hideTroops
{
    [UIView animateWithDuration:0.2 animations:^{
        [troopsView setAlpha:0];
        CGRect f = menuView.frame;
        f.origin.x = 0;
        menuView.frame = f;
    } completion:^(BOOL finished) {
        [troopsView release];
        troopsView = NULL;
    }];
}

@end
