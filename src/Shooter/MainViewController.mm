//
//  ViewController.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MainViewController.h"
#import "HGGame.h"
#import "Common.h"
#import "TitleView.h"
#import "AppDelegate.h"
//#import "MenuView.h"
#import "TroopsView.h"
#import "UserData.h"
#import "AllyTableView.h"
#import "StatusView.h"
#import "BackgroundView.h"
#import "UIColor+MyCategory.h"
#import "GameView.h"
#import "MenuButton.h"

const float MenuAnimationDuration = 0.2;

@interface MainViewController()
{
    // shootingView
    GameView* gameView;
    
    // title
    TitleView* title;
    
    // bottom
    UIView* bottomView;
    
    // curtain
    UIView* curtain;
    
    // background
    BackgroundView* backgroundView;
    
    // menu
    UIView* menuBaseView;
    UIView* mainBaseView;
    
    // status
    StatusView* statusView;
    
    // touch frame
    CGRect mainFrame;
    CGRect viewFrame;
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
        menuBaseView = NULL;
        
        instance = self;
        //menuView = NULL;
        
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        viewFrame = CGRectMake(0, 0, frame.size.height, frame.size.width);
        mainFrame = CGRectMake(0, StatusViewHeight, frame.size.height, frame.size.width - StatusViewHeight);
        
        bottomView = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
        [bottomView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:bottomView];
        
        [self showBackgroundView];
        [self showTitle];
        
    }
    return self;
}

-(void)earthQuake
{
    UIView* v = mainBaseView;
    
    CABasicAnimation *animation =
    [CABasicAnimation animationWithKeyPath:@"position"];
    [animation setDuration:0.005];
    [animation setRepeatCount:8];
    [animation setAutoreverses:YES];
    [animation setFromValue:[NSValue valueWithCGPoint:
                             CGPointMake([v center].x - 10.0f, [v center].y)]];
    [animation setToValue:[NSValue valueWithCGPoint:
                           CGPointMake([v center].x + 10.0f, [v center].y)]];
    [[self.view layer] addAnimation:animation forKey:@"position"];
    /*
    [UIView animateWithDuration:0.01 animations:^{
        CGRect f = self.view.frame;
        if (rand()%10 >= 5)
        {
            f.origin.x += rand()%5;
        }
        else
        {
            f.origin.x += rand()%5 * -1;
        }
        if (rand()%10 >= 5)
        {
            f.origin.y += rand()%5;
        }
        else
        {
            f.origin.y += rand()%5 * -1;
        }
        [self.view setFrame:f];
    } completion:^(BOOL finished) {
        if ([[NSDate date] timeIntervalSince1970] - start <= 0.5)
        {
            [self earthQuake];
        }
        else
        {
            CGRect f = self.view.frame;
            f.origin.x = 0;
            f.origin.y = 0;
            [self.view setFrame:f];
        }
    }];*/
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
    
    //[self removeAllSubview];
    [self removeTitle];
    [self showMainView];
}

- (void)removeBackgroundView
{
    // 背景終了
    [backgroundView clearGL];
    [backgroundView removeFromSuperview];
    backgroundView = NULL;
}

- (void)showBackgroundView
{
    // 背景
    backgroundView = [[[BackgroundView alloc] init] autorelease];
    [bottomView addSubview:backgroundView];
}

- (void)showTitle
{
    // タイトルメニュー
    title = [[[TitleView alloc] init] autorelease];
    assert(title != nil);
    [self.view addSubview:title];
}

- (void)removeTitle
{
    [title removeFromSuperview];
}

-(void)removeMainView
{
    [mainBaseView removeFromSuperview];
}

-(void)hideMenuViewAnimate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        CGRect f = mainFrame;
        f.origin.x = mainFrame.size.width;
        [UIView animateWithDuration:MenuAnimationDuration animations:^{
            [menuBaseView setFrame:f];
            [menuBaseView setAlpha:0];
        }
                         completion:^(BOOL finished) {
                             [menuBaseView removeFromSuperview];
                             //[self earthQuake];
                         }];
    });
}

- (void)showMenu
{
    dispatch_async(dispatch_get_main_queue(), ^{
        // Menu
        {
            menuBaseView = [[[UIView alloc] initWithFrame:mainFrame] autorelease];
            [mainBaseView setBackgroundColor:[UIColor clearColor]];
            [mainBaseView addSubview:menuBaseView];
            
            // Menu animation
            CGRect tmpFrame = mainFrame;
            tmpFrame.origin.x = mainFrame.size.width;
            [menuBaseView setFrame:tmpFrame];
            
            // animation
            [UIView animateWithDuration:0.2 animations:^{
                [menuBaseView setFrame:mainFrame];
            } completion:^(BOOL finished) {
                //[self earthQuake];
            }];
            
            // start battle
            {
                CGRect frm = CGRectMake(mainFrame.size.width - 220, mainFrame.size.height - 250, 200, 50);
                MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                [m setText:@"Battle"];
                [menuBaseView addSubview:m];
                [m setOnTapAction:^(MenuButton *target) {
                    [self stageStart];
                }];
            }
            
            // Select Ally
            {
                CGRect frm = CGRectMake(mainFrame.size.width - 220, mainFrame.size.height - 180, 200, 50);
                MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                [m setText:@"Select Ally"];
                [menuBaseView addSubview:m];
                [m setOnTapAction:^(MenuButton *target) {
                    [self hideMenuViewAnimate];
                    AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeSelectAlly WithFrame:mainFrame] autorelease];
                    [self.view addSubview:vc];
                    // animate
                    {
                        [vc setTransform:CGAffineTransformMakeScale(0.8, 0.0)];
                        [vc setUserInteractionEnabled:FALSE];
                        [UIView animateWithDuration:MenuAnimationDuration animations:^{
                            [vc setAlpha:1];
                            [vc setTransform:CGAffineTransformMakeScale(1,1)];
                        }completion:^(BOOL finished) {
                            [vc setUserInteractionEnabled:TRUE];
                        }];
                    }
                    [vc setOnEndAction:^{
                        [self showMenu];
                        // animate
                        {
                            [vc setUserInteractionEnabled:FALSE];
                            [UIView animateWithDuration:MenuAnimationDuration animations:^{
                                [vc setTransform:CGAffineTransformMakeScale(0.8, 0.0)];
                            } completion:^(BOOL finished) {
                                [vc removeFromSuperview];
                            }];
                        }
                    }];
                }];
            }
            
            
            // fix ally
            // Select Ally
            {
                CGRect frm = CGRectMake(mainFrame.size.width - 220, mainFrame.size.height - 110, 200, 50);
                MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                [m setText:@"Repair"];
                [menuBaseView addSubview:m];
                [m setOnTapAction:^(MenuButton *target) {
                    [self hideMenuViewAnimate];
                    AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeFix WithFrame:mainFrame] autorelease];
                    [self.view addSubview:vc];
                    // animate
                    {
                        [vc setTransform:CGAffineTransformMakeScale(0.8, 0.0)];
                        [vc setUserInteractionEnabled:FALSE];
                        [UIView animateWithDuration:MenuAnimationDuration animations:^{
                            [vc setAlpha:1];
                            [vc setTransform:CGAffineTransformMakeScale(1,1)];
                        }completion:^(BOOL finished) {
                            [vc setUserInteractionEnabled:TRUE];
                        }];
                    }
                    [vc setOnEndAction:^{
                        [self showMenu];
                        // animate
                        {
                            [vc setUserInteractionEnabled:FALSE];
                            [UIView animateWithDuration:MenuAnimationDuration animations:^{
                                [vc setTransform:CGAffineTransformMakeScale(0.8, 0.0)];
                            } completion:^(BOOL finished) {
                                [vc removeFromSuperview];
                            }];
                        }
                    }];
                }];
            }
            
            
        }
    });
    
}

-(void)showMainView
{
    mainBaseView = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
    [mainBaseView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:mainBaseView];
    
    // ステータス
    statusView = [[[StatusView alloc] init] autorelease];
    [mainBaseView addSubview:statusView];
    [statusView loadUserInfo];
    
    // MENU
    [self showMenu];
    
}

-(void)stageStart
{
    // 消す
    curtain = [[UIView alloc] initWithFrame:viewFrame];
    [curtain setBackgroundColor:[UIColor blackColor]];
    [curtain setAlpha:0];
    [self.view addSubview:curtain];
    
    [UIView animateWithDuration:0.5 animations:^{
        [mainBaseView setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
        [curtain setAlpha:1];
    } completion:^(BOOL finished) {
        
        [self removeBackgroundView];
        [self removeMainView];
        
        // ゲーム開始
        gameView = [[[GameView alloc] initWithOnEndAction:^{
            // 背景復活
            [gameView removeFromSuperview];
            [self showBackgroundView];
            [self showMainView];
            [curtain removeFromSuperview];
        }] autorelease];
        [self.view addSubview:gameView];
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

/*
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
    AllyTableView* avc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeSelectAlly] autorelease];
    //[self addChildViewController:avc];
    [self.view addSubview:avc];
    
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
}*/

@end
