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
#import "TroopsView.h"
#import "UserData.h"
#import "AllyTableView.h"
#import "StatusView.h"
#import "BackgroundView.h"
#import "UIColor+MyCategory.h"
#import "GameView.h"
#import "MenuButton.h"
#import "DialogView.h"

const float MenuAnimationDuration = 0.2;
const float MenuButtonWidth = 180;
const float MenuButtonHeight = 44;
const float MenuButtonGap = 10;

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

-(void)earthquake
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
            
            {
                // start battle
                float buttonX = mainFrame.size.width - 10 - MenuButtonWidth;
                float buttonY = StatusViewHeight + 5;
                
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Battle"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self stageStart];
                    }];
                }
                
                // Select your ship.
                buttonY += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Select your ship"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeSelectPlayer WithFrame:mainFrame] autorelease];
                        [self.view addSubview:vc];
                        // animate
                        {
                            [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
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
                                    [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                                } completion:^(BOOL finished) {
                                    [vc removeFromSuperview];
                                }];
                            }
                        }];
                    }];
                }
                
                // repair all
                buttonY += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Repair All"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        // buy
                        int cost = hg::UserData::sharedUserData()->getRepairAllCost();
                        if (hg::UserData::sharedUserData()->getMoney() >= cost)
                        {
                            NSString* msg = [NSString stringWithFormat:@"It Costs %d gold. Are you sure to repair all?", cost];
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:msg] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                hg::UserData::sharedUserData()->repairAll();
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[StatusView GetInstance] loadUserInfo];
                                });
                            }];
                            [dialog addButtonWithText:@"Cancel" withAction:^{
                                // nothing
                            }];
                            [dialog show];
                        }
                        else
                        {
                            NSString* msg = [NSString stringWithFormat:@"It Costs %d gold. You need more gold", cost];
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:msg] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                // nothing
                            }];
                            [dialog show];
                        }
                        
                    }];
                }
                
                // fix ally
                buttonY += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Repair"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeFix WithFrame:mainFrame] autorelease];
                        [self.view addSubview:vc];
                        // animate
                        {
                            [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
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
                                    [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                                } completion:^(BOOL finished) {
                                    [vc removeFromSuperview];
                                }];
                            }
                        }];
                    }];
                }
                
                // battle with someone
                buttonY += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Select allies"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeSelectAlly WithFrame:mainFrame] autorelease];
                        [self.view addSubview:vc];
                        // animate
                        {
                            [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
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
                                    [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                                } completion:^(BOOL finished) {
                                    [vc removeFromSuperview];
                                }];
                            }
                        }];
                    }];
                }
                
            } // end of menu 1
            
            {
                float buttonX2 = mainFrame.size.width - 10 - MenuButtonWidth - 20 - MenuButtonWidth;
                float buttonY2 = StatusViewHeight + 5;
                
                // buy ally
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Buy ships"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeShop WithFrame:mainFrame] autorelease];
                        [self.view addSubview:vc];
                        // animate
                        {
                            [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
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
                                    [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                                } completion:^(BOOL finished) {
                                    [vc removeFromSuperview];
                                }];
                            }
                        }];
                    }];
                }
                
                // sell ally
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Sell ships"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeSell WithFrame:mainFrame] autorelease];
                        [self.view addSubview:vc];
                        // animate
                        {
                            [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
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
                                    [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                                } completion:^(BOOL finished) {
                                    [vc removeFromSuperview];
                                }];
                            }
                        }];
                    }];
                }
                
                // change stage
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Select stage"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        // TODO:
                    }];
                }
                
                // option stage
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Option"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        // TODO:
                    }];
                }
            } // end of menu 2
            
        }
    });
    
}

-(void)showMainView
{
    mainBaseView = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
    [mainBaseView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:mainBaseView];
    
    // ステータス
    statusView = [StatusView CreateInstance];
    [mainBaseView addSubview:statusView];
    [statusView loadUserInfo];
    
    // MENU
    [self showMenu];
    
    /*
    // dialog test
    DialogView* v = [[[DialogView alloc] initWithMessage:@"test?"] autorelease];
    [v addButtonWithText:@"test" withAction:^{
        NSLog(@"test button pushed");
    }];
    [v show];*/
    
}

-(void)stageStart
{
    // check
    hg::UserData* userData = hg::UserData::sharedUserData();
    hg::FighterInfo* playerFighterInfo = userData->getPlayerFighterInfo();
    if (playerFighterInfo == NULL)
    {
        DialogView* dialog = [[[DialogView alloc] initWithMessage:@"Please select your ship."] autorelease];
        [dialog addButtonWithText:@"OK" withAction:^{
            // do nothing
        }];
        [dialog show];
        return;
    }
    if (playerFighterInfo->life <= 0)
    {
        DialogView* dialog = [[[DialogView alloc] initWithMessage:@"Your ship is bloken. Please repaire or change your ship."] autorelease];
        [dialog addButtonWithText:@"OK" withAction:^{
            // do nothing
        }];
        [dialog show];
        return;
    }
    
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


@end
