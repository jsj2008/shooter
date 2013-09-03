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
#import "StageTableView.h"
#import "StatusView.h"
#import "BackgroundView.h"
#import "UIColor+MyCategory.h"
#import "ClearView.h"
#import "GameView.h"
#import "MenuButton.h"
#import "DialogView.h"
#import "MessageView.h"
#import "ReportView.h"
#import "PlayerDetailView.h"
#import "ObjectAL.h"
#import "MasIconadManagerViewController.h"
#import "SystemMonitor.h"

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
#if IS_BACKGROUND
    BackgroundView* backgroundView;
#endif
    
    // menu
    UIView* menuBaseView;
    UIView* mainBaseView;
    
    // status
#if IS_STATUS
    StatusView* statusView;
#endif
    
    // touch frame
    CGRect mainFrame;
    CGRect viewFrame;
    
    PlayerDetailView* playerDetailView;
    MasIconadManagerViewController *mas_;
    
}
@end

static MainViewController* instance = nil;

@implementation MainViewController

- (void)dealloc
{
    if (menuBaseView) {
        [menuBaseView release];
    }
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        // データロード
        hg::initRandom();
        hg::UserData::sharedUserData()->loadData();
        
        menuBaseView = NULL;
        
        instance = self;
        //menuView = NULL;
        
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        viewFrame = CGRectMake(0, 0, frame.size.height, frame.size.width);
        mainFrame = CGRectMake(0, StatusViewHeight, frame.size.height, frame.size.width - StatusViewHeight);
        
        bottomView = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
        [bottomView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:bottomView];
        
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

// AdMob
+(GADBannerView*)CreateGADBannerView
{
    GADBannerView *bannerView_;
    // 画面下部に標準サイズのビューを作成する
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        bannerView_ = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner] autorelease];
    }
    else{
        bannerView_ = [[[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape] autorelease];
    }
    
    // 広告の「ユニット ID」を指定する。これは AdMob パブリッシャー ID です。
    bannerView_.adUnitID = ADDMOB_PUBLISHER_ID;
    
    // ユーザーに広告を表示した場所に後で復元する UIViewController をランタイムに知らせて
    // ビュー階層に追加する。
    bannerView_.rootViewController = self;
    // 一般的なリクエストを行って広告を読み込む。
    [bannerView_ loadRequest:[GADRequest request]];
    return bannerView_;
}

//=======================================================
// GFViewDelegate
//=======================================================
- (void)didShowGameFeat{
    // GameFeatが表示されたタイミングで呼び出されるdelegateメソッド
    NSLog(@"didShowGameFeat");
}
- (void)didCloseGameFeat{
    // GameFeatが閉じられたタイミングで呼び出されるdelegateメソッド
    NSLog(@"didCloseGameFeat");
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
    
    //[self removeAllSubview];
    [self removeTitle];
    [self showMainView:true showMessage:true];
    [[OALSimpleAudio sharedInstance] playBg:BGM_MENU loop:true];
}

+ (void)RemoveBackgroundView
{
    if (instance) {
        [instance removeBackgroundView];
    }
}

- (void)removeBackgroundView
{
#if IS_BACKGROUND
    // 背景終了
    [backgroundView clearGL];
    [backgroundView removeFromSuperview];
    backgroundView = NULL;
#endif
}

+ (void)ShowBackgroundView
{
#if IS_BACKGROUND
    if (instance) {
        [instance showBackgroundView];
    }
#endif
}

- (void)showBackgroundView
{
#if IS_BACKGROUND
    // 背景
    backgroundView = [[[BackgroundView alloc] init] autorelease];
    [bottomView addSubview:backgroundView];
#endif
}

- (void)showTitle
{
    // タイトルメニュー
    title = [[[TitleView alloc] init] autorelease];
    assert(title != nil);
    [self.view addSubview:title];
    
    // admob
    {
        GADBannerView* ad = [MainViewController CreateGADBannerView];
        [title addSubview:ad];
        CGRect r = ad.frame;
        r.origin.x = title.frame.size.width/2 - r.size.width/2;
        [ad setFrame:r];
    }
}

- (void)removeTitle
{
    [title removeFromSuperview];
}

-(void)removeMainView
{
    if (menuBaseView) {
        [menuBaseView removeFromSuperview];
        [menuBaseView release];
        menuBaseView = nil;
    }
    [mainBaseView removeFromSuperview];
}

-(void)hideMenuViewAnimate
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (menuBaseView == nil) return;
        CGRect f = mainFrame;
        f.origin.x = mainFrame.size.width;
        
        UIView* removeView = menuBaseView;
        //menuBaseView = nil;
        [UIView animateWithDuration:MenuAnimationDuration animations:^{
            [removeView setFrame:f];
            /*[removeView setAlpha:0];*/
        }
                         completion:^(BOOL finished) {
                             /*
                             [removeView removeFromSuperview];
                             //[self earthQuake];
                             [removeView release];*/
                         }];
    });
}

- (void)saveData
{
#if IS_DEBUG
        NSLog(@"save data1");
        [SystemMonitor dump];
#endif
    
    // データ保存
    bool ret = hg::UserData::sharedUserData()->saveData();
    if (!ret) {
        DialogView* dialog = [[[DialogView alloc] initWithMessage:NSLocalizedString(@"Sorry, an unexpected error happend!", nil)] autorelease];
        [dialog addButtonWithText:@"OK" withAction:^{
        }];
        [dialog show];
    }
#if IS_DEBUG
        NSLog(@"save data2");
        [SystemMonitor dump];
#endif
}

- (void)showMenu
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
#if IS_DEBUG
        NSLog(@"showMenu1");
        [SystemMonitor dump];
#endif
        // Menu
        {
            if (menuBaseView != nil) {
                // animation
                [UIView animateWithDuration:0.2 animations:^{
                    [menuBaseView setFrame:mainFrame];
                } completion:^(BOOL finished) {
                }];
            }
            else {
                
            menuBaseView = [[UIView alloc] initWithFrame:mainFrame];
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
                    [m setText:NSLocalizedString(@"Battle", nil)];
                    [m setColor:[UIColor colorWithHexString:@"#ff4444"]];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        
                        if (hg::UserData::sharedUserData()->getCurrentClearRatio() < 1.0) {
                            [self stageStart];
                        }
                        else {
                            NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"You've already cleared this stage. Please Select new Stage.", nil)];
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:msg] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                // nothing
                            }];
                            [dialog show];
                        }
                    }];
                }
                
                // repair all
                buttonY += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:NSLocalizedString(@"Repair All Units", nil)];
                    [menuBaseView addSubview:m];
                    [m setColor:[UIColor greenColor]];
                    [m setOnTapAction:^(MenuButton *target) {
                        // buy
                        int cost = hg::UserData::sharedUserData()->getRepairAllCost();
                        if (cost == 0) {
                            NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"You don't need to do this.", nil)];
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:msg] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                // nothing
                            }];
                            [dialog show];
                        } else if (hg::UserData::sharedUserData()->getMoney() >= cost) {
                            NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"It Costs %d gold. Are you sure to repair all?", nil), cost];
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:msg] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                hg::UserData::sharedUserData()->repairAll();
#if IS_STATUS
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[StatusView GetInstance] loadUserInfo];
                                });
#endif
                            }];
                            [dialog addButtonWithText:@"Cancel" withAction:^{
                                // nothing
                            }];
                            [dialog show];
                        }
                        else {
                            NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"It Costs %d gold. You need more gold", nil), cost];
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
                    [m setColor:[UIColor greenColor]];
                    [m setText:NSLocalizedString(@"Repair", nil)];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
#if IS_DEBUG
        NSLog(@"show fix");
        [SystemMonitor dump];
#endif
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeFix WithFrame:mainFrame] autorelease];
                        [self.view addSubview:vc];
#if IS_STATUS
                        [[StatusView GetInstance] hideProgress];
#endif
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
#if IS_DEBUG
        NSLog(@"show fix2");
        [SystemMonitor dump];
#endif
                        [vc setOnEndAction:^{
#if IS_DEBUG
        NSLog(@"end fix");
        [SystemMonitor dump];
#endif
                            [self showMenu];
                            [self saveData];
#if IS_STATUS
                            [[StatusView GetInstance] showProgress];
#endif
                            // animate
                            {
                                [vc setUserInteractionEnabled:FALSE];
                                [UIView animateWithDuration:MenuAnimationDuration animations:^{
                                    [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                                } completion:^(BOOL finished) {
                                    [vc removeFromSuperview];
                                }];
                            }
#if IS_DEBUG
        NSLog(@"end fix2");
        [SystemMonitor dump];
#endif
                        }];
                    }];
                }
                
                // battle with someone
                buttonY += (MenuButtonHeight + MenuButtonGap);
                // buy ally
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setColor: [UIColor yellowColor]];
                    [m setText:NSLocalizedString(@"Buy Units", nil)];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeShop WithFrame:mainFrame] autorelease];
                        [self.view addSubview:vc];
#if IS_STATUS
                        [[StatusView GetInstance] hideProgress];
#endif
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
                            [self saveData];
#if IS_STATUS
                            [[StatusView GetInstance] showProgress];
#endif
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
                //float buttonX2 = mainFrame.size.width - 10 - MenuButtonWidth - 20 - MenuButtonWidth;
                float buttonX2 = 10;
                float buttonY2 = StatusViewHeight + 5;
                
                // select stage
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:NSLocalizedString(@"Return to Base", nil)];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        NSString* msg = @"";
                        if (hg::UserData::sharedUserData()->getCurrentClearRatio() < 1.0) {
                            msg = NSLocalizedString(@"You will get All fighters repaired and lose half of the Money. Are you sure to do this?", nil);
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:msg] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                hg::UserData* u = hg::UserData::sharedUserData();
                                u->returnToBase();
                                u->saveData();
#if IS_STATUS
                                [[StatusView GetInstance] loadUserInfo];
#endif
                                if (playerDetailView) {
                                    [playerDetailView loadGrade];
                                }
                                DialogView* dialog2 = [[[DialogView alloc] initWithMessage:NSLocalizedString(@"Welcome back to the Base! All fighters are repaired now!", nil)] autorelease];
                                [dialog2 addButtonWithText:NSLocalizedString(@"OK", nil) withAction:^{
                                    // do nothing
                                }];
                                [dialog2 show];
                            }];
                            [dialog addButtonWithText:NSLocalizedString(@"Cancel", nil) withAction:^{
                                // do nothing
                            }];
                            [dialog show];
                        }
                        // no penalty
                        else {
                            DialogView* dialog2 = [[[DialogView alloc] initWithMessage:NSLocalizedString(@"Do you want to start over this stage again?", nil)] autorelease];
                            [dialog2 addButtonWithText:NSLocalizedString(@"OK", nil) withAction:^{
                                hg::UserData* u = hg::UserData::sharedUserData();
                                u->returnToBase();
                                u->saveData();
#if IS_STATUS
                                [[StatusView GetInstance] loadUserInfo];
#endif
                                if (playerDetailView) {
                                    [playerDetailView loadGrade];
                                }
                            }];
                            [dialog2 addButtonWithText:NSLocalizedString(@"Cancel", nil) withAction:^{
                                // do nothing
                            }];
                            [dialog2 show];
                        }
                    }];
                }
                
                // select area
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:NSLocalizedString(@"Select Stage", nil)];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        
                        hg::UserData* u = hg::UserData::sharedUserData();
                        if (u->getCurrentClearRatio() == 0 || u->getCurrentClearRatio() >= 1.0) {
                            
                            // show select area table view
                            [self hideMenuViewAnimate];
                            StageTableView* vc = [[[StageTableView alloc] initWithFrame:mainFrame] autorelease];
                            [self.view addSubview:vc];
#if IS_STATUS
                            [[StatusView GetInstance] hideProgress];
#endif
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
#if IS_STATUS
                                [[StatusView GetInstance] showProgress];
#endif
                                [self showMenu];
                                [self saveData];
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
                            
                        }
                        else {
                            // 途中
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:NSLocalizedString(@"You can change the Stage when the Occupy Ratio is 0% or 100%", nil)] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                // do nothing
                            }];
                            [dialog show];
                            
                        }
                        
                    }];
                }
                
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:NSLocalizedString(@"Select Units", nil)];
                    [menuBaseView addSubview:m];
                    [m setColor:[UIColor colorWithHexString:@"#ffcc00"]];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeSelectAlly WithFrame:mainFrame] autorelease];
                        [self.view addSubview:vc];
#if IS_STATUS
                        [[StatusView GetInstance] hideProgress];
#endif
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
                            [self saveData];
#if IS_STATUS
                            [[StatusView GetInstance] showProgress];
#endif
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
                
                
                // Select your ship.
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:NSLocalizedString(@"Select My Unit", nil)];
                    [m setColor:[UIColor colorWithHexString:@"#ffcc00"]];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeSelectPlayer WithFrame:mainFrame] autorelease];
                        [self.view addSubview:vc];
#if IS_STATUS
                        [[StatusView GetInstance] hideProgress];
#endif
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
#if IS_STATUS
                            [[StatusView GetInstance] showProgress];
#endif
                            [self showMenu];
                            [self saveData];
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
                /*
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:NSLocalizedString(@"Sell Units", nil)];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeSell WithFrame:mainFrame] autorelease];
                        [self.view addSubview:vc];
                        [[StatusView GetInstance] hideProgress];
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
                            [self saveData];
                            [[StatusView GetInstance] showProgress];
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
                }*/
                
                
            } // end of menu 2
        
            // admob
                if (IS_MAIN_ADMOB)
                {
                    GADBannerView* ad = [MainViewController CreateGADBannerView];
                    [menuBaseView addSubview:ad];
                    CGRect r = ad.frame;
                    r.origin.x = menuBaseView.frame.size.width/2 - r.size.width/2;
                    r.origin.y = menuBaseView.frame.size.height - r.size.height;
                    [ad setFrame:r];
                }
                
                // gamefeat
                if (IS_GAMEFEAT){
                    // start battle
                    float w = 350;
                    float h = MenuButtonHeight;
                    float buttonX = mainFrame.size.width/2 - w/2;
                    float buttonY = mainFrame.size.height - 10 - h;
                    {
                        CGRect frm = CGRectMake(buttonX, buttonY, w, h);
                        MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                        [m setText:NSLocalizedString(@"Other Great Games!", nil)];
                        [m setColor:[UIColor cyanColor]];
                        [menuBaseView addSubview:m];
                        [m setOnTapAction:^(MenuButton *target) {
                            [GFController showGF:self site_id:GAMEFEAT_MEDIA_ID delegate:self];
                        }];
                    }
                }
                
                // medibaad
                if (IS_MEDIBAAD){
                    float w = mainFrame.size.width;
                    float h = MenuButtonHeight;
                    float buttonX = mainFrame.size.width/2 - w/2;
                    float buttonY = mainFrame.size.height - 10 - h;
                    UIView* v = [[UIView alloc] initWithFrame:CGRectMake(buttonX, buttonY, w, h)];
                    [menuBaseView addSubview:v];
                    
                    MasIconadManagerViewController *m = [[[MasIconadManagerViewController alloc] init] autorelease];
                    mas_ = m;
                    [v addSubview:mas_.view];
                    [m release];
                    mas_.adOrigin = CGPointMake(0, 0);
                    mas_.textVisible = 0;
                    mas_.iconCount = 6;
                    [mas_ setBackGround:[UIColor clearColor] opaque:NO];
                    mas_.sID = @"ea7ab6746abb4a15de2a82deee207d5f3582b275b8f80021";
                    [mas_ loadRequest];
                }
            }
        }
#if IS_DEBUG
        NSLog(@"showMenu2");
        [SystemMonitor dump];
#endif
            
    });
    
}

-(void)showMainView:(bool)showMenu showMessage:(bool)showMessage
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
#if IS_DEBUG
        NSLog(@"show main1");
        [SystemMonitor dump];
#endif
        [self showBackgroundView];
        mainBaseView = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
        [mainBaseView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:mainBaseView];
        
        // ステータス
#if IS_STATUS
        statusView = [StatusView CreateInstance];
        [mainBaseView addSubview:statusView];
        [statusView loadUserInfo];
#endif
        
        // player detail view
        {
            if (playerDetailView) {
                [playerDetailView release];
                playerDetailView = nil;
            }
            CGRect playderDetailViewFrame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
            playerDetailView = [[PlayerDetailView alloc] initWithFrame:playderDetailViewFrame];
            [self.view addSubview:playerDetailView];
            [playerDetailView loadGrade];
        }
        
        // MENU
        if (showMenu) {
            [self showMenu];
        }
        
        if (showMessage) {
            [self showMessage];
        }
        /*
         // dialog test
         DialogView* v = [[[DialogView alloc] initWithMessage:@"test?"] autorelease];
         [v addButtonWithText:@"test" withAction:^{
         NSLog(@"test button pushed");
         }];
         [v show];*/
#if IS_DEBUG
        NSLog(@"show main2");
        [SystemMonitor dump];
#endif
    });
}

-(void) showMessage
{
    if (hg::UserData::sharedUserData()->hasLevelUpInfo())
    {
        NSMutableArray* msgList = [NSMutableArray arrayWithObjects: nil];
        // レベルアップメッセージを作成
        while (1) {
            if (!hg::UserData::sharedUserData()->hasLevelUpInfo()) {
                break;
            }
            std::string msg = hg::UserData::sharedUserData()->popLevelupMessage();
            [msgList addObject:[NSString stringWithCString:msg.c_str() encoding:NSUTF8StringEncoding]];
        }
        
        MessageView* msgView = [[[MessageView alloc] initWithMessageList:msgList] autorelease];
        [msgView show];
    }
}

-(void)stageStart
{
#if IS_DEBUG
        NSLog(@"stagestart 1");
        [SystemMonitor dump];
#endif
    // check
    hg::UserData* userData = hg::UserData::sharedUserData();
    hg::FighterInfo* playerFighterInfo = userData->getPlayerFighterInfo();
    if (playerFighterInfo == NULL)
    {
        DialogView* dialog = [[[DialogView alloc] initWithMessage:NSLocalizedString(@"Please select your Unit.", nil)] autorelease];
        [dialog addButtonWithText:@"OK" withAction:^{
            // do nothing
        }];
        [dialog show];
        return;
    }
    if (playerFighterInfo->life <= 0)
    {
        DialogView* dialog = [[[DialogView alloc] initWithMessage:NSLocalizedString(@"Your unit is bloken. Please repair or change your Units.", nil)] autorelease];
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
    [self hideMenuViewAnimate];
    
    [playerDetailView removeFromSuperview];
    
    [UIView animateWithDuration:0.3 animations:^{
        [mainBaseView setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
        [curtain setAlpha:1];
    } completion:^(BOOL finished) {
        
        [self removeBackgroundView];
        [self removeMainView];
        
        // ゲーム開始
        gameView = [[[GameView alloc] initWithOnEndAction:^{
            // ゲーム終了後の結果画面
            [self saveData];
            dispatch_async(dispatch_get_main_queue(), ^{
#if IS_DEBUG
        NSLog(@"report 1");
        [SystemMonitor dump];
#endif
                ReportView* rv = [[ReportView alloc] initWithFrame:mainFrame];
                [[OALSimpleAudio sharedInstance] playBg:BGM_MENU loop:true];
                [self.view addSubview:rv];
                [rv autorelease];
                [rv setOnEndAction:^{
                    // ゲーム終了結果画面の終了後
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 背景復活
                        [gameView removeFromSuperview];
                        // クリア画面
                        if (hg::UserData::sharedUserData()->isCleared()) {
                            [[OALSimpleAudio sharedInstance] playBg:BGM_CLEAR loop:true];
                            [self showMainView:false showMessage:false];
                            [curtain removeFromSuperview];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                ClearView* cv = [[[ClearView alloc] initWithFrame:viewFrame] autorelease];
                                [cv setOnEndAction:^{
                                    [cv setUserInteractionEnabled:false];
                                    [cv removeFromSuperview];
                                    [self showMenu];
                                    [self showMessage];
                                }];
                                [self.view addSubview:cv];
                            });
                        }
                        else {
                            // レベルアップ情報を表示
                            [self showMainView:true showMessage:true];
                            [curtain removeFromSuperview];
                        }
                    }); // dispatch_async
                }]; // rv setOnEndAction
#if IS_DEBUG
                NSLog(@"report 2");
                [SystemMonitor dump];
#endif
            }); // dispatch_async
        }] autorelease]; // [[GameView alloc] initWithOnEndAction:
        [self.view addSubview:gameView];
    }];
    
#if IS_DEBUG
        NSLog(@"stagestart 2");
        [SystemMonitor dump];
#endif
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
