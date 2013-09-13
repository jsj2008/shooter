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
    UIView* curtain;
    
    // background
#if IS_BACKGROUND
    BackgroundView* backgroundView;
#endif
#if IS_REPORT_REUSE
    ReportView* reportView;
#endif
    
    // menu
    UIView* menuBaseView;
    UIView* mainBaseView;
    
    // status
    
    // touch frame
    CGRect mainFrame;
    CGRect viewFrame;
    
#if IS_PLAYER_DETAIL
    PlayerDetailView* playerDetailView;
#endif
    MasIconadManagerViewController *mas_;
#if IS_MAIN_ADMOB
    GADBannerView* gadBannerView_;
#endif
    
}
@end

static MainViewController* instance = nil;

@implementation MainViewController


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
        
        bottomView = [[UIView alloc] initWithFrame:viewFrame];
        [bottomView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:bottomView];
        
        [self showTitle];
        
    }
    return self;
}


static UIImage* checkImg = nil;
+ (UIImage*)getCheckImage
{
    if (checkImg == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:ICON_CHECK ofType:@"png"];
        checkImg = [[UIImage alloc] initWithContentsOfFile:path];
    }
    return checkImg;
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
    if (instance) {
        @autoreleasepool {
            GADBannerView *bannerView_;
            // 画面下部に標準サイズのビューを作成する
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
                bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
            }
            else{
                bannerView_ = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerLandscape];
            }
            
            // 広告の「ユニット ID」を指定する。これは AdMob パブリッシャー ID です。
            bannerView_.adUnitID = ADDMOB_PUBLISHER_ID;
            
            // ユーザーに広告を表示した場所に後で復元する UIViewController をランタイムに知らせて
            // ビュー階層に追加する。
            bannerView_.rootViewController = instance;
            // 一般的なリクエストを行って広告を読み込む。
            [bannerView_ loadRequest:[GADRequest request]];
            return bannerView_;
        }
    }
    return nil;
}

//=======================================================
// GFViewDelegate
//=======================================================
#if IS_GAMEFEAT
- (void)didShowGameFeat{
    // GameFeatが表示されたタイミングで呼び出されるdelegateメソッド
    NSLog(@"didShowGameFeat");
}
- (void)didCloseGameFeat{
    // GameFeatが閉じられたタイミングで呼び出されるdelegateメソッド
    NSLog(@"didCloseGameFeat");
}
#endif


+(void)Start
{
    if (instance)
    {
        [instance start];
    }
}

-(void)start
{
    [self removeTitle];
    [self showMainView:true showMessage:true];
#if IS_BGM
    [[OALSimpleAudio sharedInstance] playBg:BGM_MENU loop:true];
#endif
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
    if (backgroundView) {
        [backgroundView removeFromSuperview];
        backgroundView = nil;
    }
    // 背景
    backgroundView = [[BackgroundView alloc] init];
    [bottomView addSubview:backgroundView];
#endif
}

- (void)showTitle
{
    // タイトルメニュー
    title = [[TitleView alloc] init];
    assert(title != nil);
    [self.view addSubview:title];
    
    // admob
    if (!gadBannerView_)
    {
        gadBannerView_ = [MainViewController CreateGADBannerView];
    }
    [title addSubview:gadBannerView_];
    CGRect r = gadBannerView_.frame;
    r.origin.x = title.frame.size.width/2 - r.size.width/2;
    [gadBannerView_ setFrame:r];
    
}

- (void)removeTitle
{
    [title removeFromSuperview];
    title = nil;
}

-(void)removeMainView
{
    if (menuBaseView) {
#if IS_MENU_REUSE
        [menuBaseView setUserInteractionEnabled:NO];
        [menuBaseView setAlpha:0];
#else
        [menuBaseView removeFromSuperview];
        menuBaseView = nil;
#endif
    }
    if (mainBaseView) {
#if IS_MENU_REUSE
        [mainBaseView setUserInteractionEnabled:NO];
        [mainBaseView setAlpha:0];
#else
        [mainBaseView removeFromSuperview];
        mainBaseView = nil;
#endif
    }
}

-(void)hideMenuViewAnimate
{
    if (menuBaseView == nil) return;
    CGRect f = mainFrame;
    f.origin.x = mainFrame.size.width;
    
    __weak UIView* removeView = menuBaseView;
    [UIView animateWithDuration:MenuAnimationDuration animations:^{
        [removeView setFrame:f];
    }
                     completion:^(BOOL finished) {
                     }];
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
        DialogView* dialog = [[DialogView alloc] initWithMessage:NSLocalizedString(@"Sorry, an unexpected error happend!", nil)];
        [dialog addButtonWithText:@"OK" withAction:^{
        }];
        [dialog show];
    }
#if IS_DEBUG
    NSLog(@"save data2");
    [SystemMonitor dump];
#endif
}

- (void)pushBattle
{
    if (hg::UserData::sharedUserData()->getCurrentClearRatio() < 1.0) {
        [self stageStart];
    }
    else {
        NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"You've already cleared this stage. Please Select new Stage.", nil)];
        DialogView* dialog = [[DialogView alloc] initWithMessage:msg];
        [dialog addButtonWithText:@"OK" withAction:^{
            // nothing
        }];
        [dialog show];
    }
}

-(void)repairAllUnits
{
    
    // buy
    int cost = hg::UserData::sharedUserData()->getRepairAllCost();
    if (cost == 0) {
        NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"You don't need to do this.", nil)];
        DialogView* dialog = [[DialogView alloc] initWithMessage:msg];
        [dialog addButtonWithText:@"OK" withAction:^{
            // nothing
        }];
        [dialog show];
    } else if (hg::UserData::sharedUserData()->getMoney() >= cost) {
        NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"It Costs %d gold. Are you sure to repair all?", nil), cost];
        DialogView* dialog = [[DialogView alloc] initWithMessage:msg];
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
        DialogView* dialog = [[DialogView alloc] initWithMessage:msg];
        [dialog addButtonWithText:@"OK" withAction:^{
            // nothing
        }];
        [dialog show];
    }
}

-(void)buyUnits
{
    [self hideMenuViewAnimate];
    AllyTableView* vc = [[AllyTableView alloc] initWithViewMode:AllyViewModeShop WithFrame:mainFrame];
    [self.view addSubview:vc];
#if IS_STATUS
    [[StatusView GetInstance] hideProgress];
#endif
    // animate
    [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
    [vc setUserInteractionEnabled:FALSE];
    {
        __weak AllyTableView* vc_ = vc;
        [UIView animateWithDuration:MenuAnimationDuration animations:^{
            [vc_ setAlpha:1];
            [vc_ setTransform:CGAffineTransformMakeScale(1,1)];
        }completion:^(BOOL finished) {
            [vc_ setUserInteractionEnabled:TRUE];
        }];
    }
    {
        __weak AllyTableView* vc_ = vc;
        __weak MainViewController* self_ = self;
        [vc setOnEndAction:^{
            [self_ showMenu];
            [self_ saveData];
#if IS_STATUS
            [[StatusView GetInstance] showProgress];
#endif
            // animate
            {
                [vc_ setUserInteractionEnabled:FALSE];
                __weak AllyTableView* vc__ = vc_;
                [UIView animateWithDuration:MenuAnimationDuration animations:^{
                    [vc__ setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                } completion:^(BOOL finished) {
                    [vc__ removeFromSuperview];
                }];
            }
        }];
    }
    
}

- (void)retrunToBase
{
   
    NSString* msg = @"";
    if (hg::UserData::sharedUserData()->getCurrentClearRatio() < 1.0) {
        msg = NSLocalizedString(@"You will get All fighters repaired and lose half of the Money. Are you sure to do this?", nil);
        DialogView* dialog = [[DialogView alloc] initWithMessage:msg];
        {
#if IS_PLAYER_DETAIL
            __weak PlayerDetailView* pdv_ = playerDetailView;
#endif
            [dialog addButtonWithText:@"OK" withAction:^{
                hg::UserData* u = hg::UserData::sharedUserData();
                u->returnToBase();
                u->saveData();
#if IS_STATUS
                [[StatusView GetInstance] loadUserInfo];
#endif
#if IS_PLAYER_DETAIL
                if (pdv_) {
                    [pdv_ loadGrade];
                }
#endif
                DialogView* dialog2 = [[DialogView alloc] initWithMessage:NSLocalizedString(@"Welcome back to the Base! All fighters are repaired now!", nil)];
                [dialog2 addButtonWithText:NSLocalizedString(@"OK", nil) withAction:^{
                    // do nothing
                }];
                [dialog2 show];
            }];
        }
        [dialog addButtonWithText:NSLocalizedString(@"Cancel", nil) withAction:^{
            // do nothing
        }];
        [dialog show];
    }
    // no penalty
    else {
        DialogView* dialog2 = [[DialogView alloc] initWithMessage:NSLocalizedString(@"Do you want to start over this stage again?", nil)];
#if IS_PLAYER_DETAIL
        __weak PlayerDetailView* pdv_ = playerDetailView;
#endif
        [dialog2 addButtonWithText:NSLocalizedString(@"OK", nil) withAction:^{
            hg::UserData* u = hg::UserData::sharedUserData();
            u->returnToBase();
            u->saveData();
#if IS_STATUS
            [[StatusView GetInstance] loadUserInfo];
#endif
#if IS_PLAYER_DETAIL
            if (pdv_) {
                [pdv_ loadGrade];
            }
#endif
        }];
        [dialog2 addButtonWithText:NSLocalizedString(@"Cancel", nil) withAction:^{
            // do nothing
        }];
        [dialog2 show];
    }
}

-(void)selectUnits
{
    [self hideMenuViewAnimate];
    AllyTableView* vc = [[AllyTableView alloc] initWithViewMode:AllyViewModeSelectAlly WithFrame:mainFrame];
    [self.view addSubview:vc];
#if IS_STATUS
    [[StatusView GetInstance] hideProgress];
#endif
    // animate
    {
        [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
        [vc setUserInteractionEnabled:FALSE];
        __weak AllyTableView* vc_ = vc;
        [UIView animateWithDuration:MenuAnimationDuration animations:^{
            [vc_ setAlpha:1];
            [vc_ setTransform:CGAffineTransformMakeScale(1,1)];
        }completion:^(BOOL finished) {
            [vc_ setUserInteractionEnabled:TRUE];
        }];
    }
    {
        __weak MainViewController* self_ = self;
        __weak AllyTableView* vc_ = vc;
        [vc setOnEndAction:^{
            [self_ showMenu];
            [self_ saveData];
#if IS_STATUS
            [[StatusView GetInstance] showProgress];
#endif
            // animate
            {
                [vc_ setUserInteractionEnabled:FALSE];
                __weak AllyTableView* vc__ = vc_;
                [UIView animateWithDuration:MenuAnimationDuration animations:^{
                    [vc__ setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                } completion:^(BOOL finished) {
                    [vc__ removeFromSuperview];
                }];
            }
        }];
    }
    
}

- (void)selectMyUnit
{
    [self hideMenuViewAnimate];
    AllyTableView* vc = [[AllyTableView alloc] initWithViewMode:AllyViewModeSelectPlayer WithFrame:mainFrame];
    [self.view addSubview:vc];
#if IS_STATUS
    [[StatusView GetInstance] hideProgress];
#endif
    // animate
    {
        [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
        [vc setUserInteractionEnabled:FALSE];
        __weak AllyTableView* vc_ = vc;
        [UIView animateWithDuration:MenuAnimationDuration animations:^{
            [vc_ setAlpha:1];
            [vc_ setTransform:CGAffineTransformMakeScale(1,1)];
        }completion:^(BOOL finished) {
            [vc_ setUserInteractionEnabled:TRUE];
        }];
    }
    {
        __weak AllyTableView* vc_ = vc;
        __weak MainViewController* self_ = self;
        [vc setOnEndAction:^{
#if IS_STATUS
            [[StatusView GetInstance] showProgress];
#endif
            [self_ showMenu];
            [self_ saveData];
            // animate
            {
                [vc_ setUserInteractionEnabled:FALSE];
                __weak AllyTableView* vc__ = vc_;
                [UIView animateWithDuration:MenuAnimationDuration animations:^{
                    [vc__ setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                } completion:^(BOOL finished) {
                    [vc__ removeFromSuperview];
                }];
            }
        }];
    }
    
}

- (void)showMenu
{
    
#if IS_DEBUG
    NSLog(@"showMenu1");
    [SystemMonitor dump];
#endif
    
    // Menu
    {
        if (menuBaseView != nil) {
            // animation
#if IS_MENU_REUSE
            CGRect tmpFrame = mainFrame;
            tmpFrame.origin.x = mainFrame.size.width;
            [menuBaseView setFrame:tmpFrame];
            [menuBaseView setTransform:CGAffineTransformMakeScale(1,1)];
            __weak UIView* mb_ = menuBaseView;
            [UIView animateWithDuration:0.2 animations:^{
                [mb_ setFrame:mainFrame];
                [mb_ setUserInteractionEnabled:TRUE];
                [mb_ setAlpha:1];
            } completion:^(BOOL finished) {
            }];
#else
            __weak UIView* mb = menuBaseView;
            [UIView animateWithDuration:0.2 animations:^{
                [mb setFrame:mainFrame];
            } completion:^(BOOL finished) {
            }];
#endif
        }
        else {
            
            if (menuBaseView) {
                [menuBaseView removeFromSuperview];
                menuBaseView = nil;
            }
            menuBaseView = [[UIView alloc] initWithFrame:mainFrame];
            [mainBaseView addSubview:menuBaseView];
            
            // Menu animation
            CGRect tmpFrame = mainFrame;
            tmpFrame.origin.x = mainFrame.size.width;
            [menuBaseView setFrame:tmpFrame];
            
            // animation
            __weak UIView* mb_ = menuBaseView;
            [UIView animateWithDuration:0.2 animations:^{
                [mb_ setFrame:mainFrame];
            } completion:^(BOOL finished) {
                //[self earthQuake];
            }];
            
            
            {
                
                // start battle
                float buttonX = mainFrame.size.width - 10 - MenuButtonWidth;
                float buttonY = StatusViewHeight + 5;
                
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
                    [m setText:NSLocalizedString(@"Battle", nil)];
                    [m setColor:[UIColor colorWithHexString:@"#ff4444"]];
                    [menuBaseView addSubview:m];
                    __weak MainViewController* self_ = self;
                    [m setOnTapAction:^(MenuButton *target) {
                        [self_ pushBattle];
                    }];
                }
                
                // repair all
                buttonY += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
                    [m setText:NSLocalizedString(@"Repair All Units", nil)];
                    [menuBaseView addSubview:m];
                    [m setColor:[UIColor greenColor]];
                    __weak MainViewController* self_ = self;
                    [m setOnTapAction:^(MenuButton *target) {
                        [self_ repairAllUnits];
                    }];
                }
                
                // fix ally
                buttonY += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
                    [m setColor:[UIColor greenColor]];
                    [m setText:NSLocalizedString(@"Repair", nil)];
                    [menuBaseView addSubview:m];
                    __weak MainViewController* self_ = self;
                    [m setOnTapAction:^(MenuButton *target) {
                        [self_ fixAlly];
                    }];
                }
                
                // battle with someone
                buttonY += (MenuButtonHeight + MenuButtonGap);
                // buy ally
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
                    [m setColor: [UIColor yellowColor]];
                    [m setText:NSLocalizedString(@"Buy Units", nil)];
                    [menuBaseView addSubview:m];
                    __weak MainViewController* self_ = self;
                    [m setOnTapAction:^(MenuButton *target) {
                        [self_ buyUnits];
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
                    MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
                    [m setText:NSLocalizedString(@"Return to Base", nil)];
                    [menuBaseView addSubview:m];
                    __weak MainViewController* self_ = self;
                    [m setOnTapAction:^(MenuButton *target) {
                        [self_ retrunToBase];
                    }];
                }
                
                // select area
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
                    [m setText:NSLocalizedString(@"Select Stage", nil)];
                    [menuBaseView addSubview:m];
                    __weak MainViewController* self_ = self;
                    [m setOnTapAction:^(MenuButton *target) {
                        [self_ showStageView];
                    }];
                }
                
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
                    [m setText:NSLocalizedString(@"Select Units", nil)];
                    [menuBaseView addSubview:m];
                    [m setColor:[UIColor colorWithHexString:@"#ffcc00"]];
                    __weak MainViewController* self_ = self;
                    [m setOnTapAction:^(MenuButton *target) {
                        [self_ selectUnits];
                    }];
                }
                
                
                // Select your ship.
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
                    [m setText:NSLocalizedString(@"Select My Unit", nil)];
                    [m setColor:[UIColor colorWithHexString:@"#ffcc00"]];
                    [menuBaseView addSubview:m];
                    __weak MainViewController* self_ = self;
                    [m setOnTapAction:^(MenuButton *target) {
                        [self_ selectMyUnit];
                    }];
                }
                
                
            } // end of menu 2
            
#if IS_MAIN_ADMOB
            // admob
            {
                if (!gadBannerView_) {
                    gadBannerView_ = [MainViewController CreateGADBannerView];
                }
                [gadBannerView_ removeFromSuperview];
                [menuBaseView addSubview:gadBannerView_];
                CGRect r = gadBannerView_.frame;
                r.origin.x = menuBaseView.frame.size.width/2 - r.size.width/2;
                r.origin.y = menuBaseView.frame.size.height - r.size.height;
                [gadBannerView_ setFrame:r];
                [gadBannerView_ loadRequest:[GADRequest request]];
            }
#endif
            
#if IS_GAMEFEAT
            // gamefeat
            {
                // start battle
                float w = 350;
                float h = MenuButtonHeight;
                float buttonX = mainFrame.size.width/2 - w/2;
                float buttonY = mainFrame.size.height - 10 - h;
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, w, h);
                    MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
                    [m setText:NSLocalizedString(@"Other Great Games!", nil)];
                    [m setColor:[UIColor cyanColor]];
                    [menuBaseView addSubview:m];
                    __weak MainViewController* self_ = self;
                    [m setOnTapAction:^(MenuButton *target) {
                        [GFController showGF:self_ site_id:GAMEFEAT_MEDIA_ID delegate:self_];
                    }];
                }
            }
#endif
            
#if IS_MEDIBAAD
            // medibaad
            {
                float w = mainFrame.size.width;
                float h = MenuButtonHeight;
                float buttonX = mainFrame.size.width/2 - w/2;
                float buttonY = mainFrame.size.height - 10 - h;
                UIView* v = [[UIView alloc] initWithFrame:CGRectMake(buttonX, buttonY, w, h)];
                [menuBaseView addSubview:v];
                
                MasIconadManagerViewController *m = [[MasIconadManagerViewController alloc] init];
                mas_ = m;
                [v addSubview:mas_.view];
                mas_.adOrigin = CGPointMake(0, 0);
                mas_.textVisible = 0;
                mas_.iconCount = 6;
                [mas_ setBackGround:[UIColor clearColor] opaque:NO];
                mas_.sID = @"ea7ab6746abb4a15de2a82deee207d5f3582b275b8f80021";
                [mas_ loadRequest];
            }
#endif
        }
    }
#if IS_DEBUG
    NSLog(@"showMenu2");
    [SystemMonitor dump];
#endif
    
}

-(void)showStageView
{
    __weak MainViewController* self_ = self;
    hg::UserData* u = hg::UserData::sharedUserData();
    if (u->getCurrentClearRatio() == 0 || u->getCurrentClearRatio() >= 1.0) {
        
        // show select area table view
        [self_ hideMenuViewAnimate];
        StageTableView* vc = [[StageTableView alloc] initWithFrame:mainFrame];
        [self_.view addSubview:vc];
#if IS_STATUS
        [[StatusView GetInstance] hideProgress];
#endif
        // animate
        {
            [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
            [vc setUserInteractionEnabled:FALSE];
            __weak StageTableView* vc_ = vc;
            [UIView animateWithDuration:MenuAnimationDuration animations:^{
                [vc_ setAlpha:1];
                [vc_ setTransform:CGAffineTransformMakeScale(1,1)];
            }completion:^(BOOL finished) {
                [vc_ setUserInteractionEnabled:TRUE];
            }];
        }
        
        __weak StageTableView* vc_ = vc;
        [vc setOnEndAction:^{
#if IS_STATUS
            [[StatusView GetInstance] showProgress];
#endif
            [self_ showMenu];
            [self_ saveData];
            // animate
            {
                [vc_ setUserInteractionEnabled:FALSE];
                __weak StageTableView* vc__ = vc_;
                [UIView animateWithDuration:MenuAnimationDuration animations:^{
                    [vc__ setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                } completion:^(BOOL finished) {
                    [vc__ removeFromSuperview];
                }];
            }
        }];
        
    }
    else {
        // 途中
        DialogView* dialog = [[DialogView alloc] initWithMessage:NSLocalizedString(@"You can change the Stage when the Occupy Ratio is 0% or 100%", nil)];
        [dialog addButtonWithText:@"OK" withAction:^{
            // do nothing
        }];
        [dialog show];
        
    }
    
}

-(void)showMainView:(bool)showMenu showMessage:(bool)showMessage
{
    
#if IS_DEBUG
    NSLog(@"show main1");
    [SystemMonitor dump];
#endif
    [self showBackgroundView];
#if IS_MENU_REUSE
    if (!mainBaseView) {
        mainBaseView = [[UIView alloc] initWithFrame:viewFrame];
        [mainBaseView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:mainBaseView];
    }
    [mainBaseView setTransform:CGAffineTransformMakeScale(1,1)];
    [mainBaseView setFrame:viewFrame];
    [mainBaseView setAlpha:1];
    [mainBaseView setUserInteractionEnabled:YES];
#else
    if (mainBaseView) {
        [mainBaseView removeFromSuperview];
        mainBaseView = nil;
    }
    mainBaseView = [[UIView alloc] initWithFrame:viewFrame];
    [mainBaseView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:mainBaseView];
#endif
    
    // ステータス
#if IS_STATUS
#if IS_STATUS_REUSE
    StatusView* statusView = [StatusView GetInstance];
    if (statusView == nil) {
        [mainBaseView addSubview:[StatusView CreateInstance]];
        statusView = [StatusView GetInstance];
    }
    [statusView loadUserInfo];
    [statusView showProgress];
#else
    StatusView* statusView = [StatusView CreateInstance];
    [mainBaseView addSubview:statusView];
    [statusView loadUserInfo];
#endif
#endif
    
    // player detail view
    {
        CGRect playderDetailViewFrame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
#if IS_PLAYER_DETAIL
        if (playerDetailView) {
            [playerDetailView removeFromSuperview];
            playerDetailView = nil;
        }
        playerDetailView = [[PlayerDetailView alloc] initWithFrame:playderDetailViewFrame];
        [self.view addSubview:playerDetailView];
        [playerDetailView loadGrade];
#endif
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
     DialogView* v = [[DialogView alloc] initWithMessage:@"test?"];
     [v addButtonWithText:@"test" withAction:^{
     NSLog(@"test button pushed");
     }];
     [v show];*/
#if IS_DEBUG
    NSLog(@"show main2");
    [SystemMonitor dump];
#endif
}

-(void)fixAlly
{
#if IS_DEBUG
    NSLog(@"show fix");
    [SystemMonitor dump];
#endif
    [self hideMenuViewAnimate];
    AllyTableView* vc = [[AllyTableView alloc] initWithViewMode:AllyViewModeFix WithFrame:mainFrame];
    
    {
        [self.view addSubview:vc];
#if IS_STATUS
        [[StatusView GetInstance] hideProgress];
#endif
        // animate
        {
            [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
            [vc setUserInteractionEnabled:FALSE];
            __weak AllyTableView* vc_ = vc;
            [UIView animateWithDuration:MenuAnimationDuration animations:^{
                [vc_ setAlpha:1];
                [vc_ setTransform:CGAffineTransformMakeScale(1,1)];
            }completion:^(BOOL finished) {
                [vc_ setUserInteractionEnabled:TRUE];
            }];
        }
    }
#if IS_DEBUG
    NSLog(@"show fix2");
    [SystemMonitor dump];
#endif
    
    {
        __weak AllyTableView* vc_ = vc;
        __weak MainViewController* self_ = self;
        [vc setOnEndAction:^{
#if IS_DEBUG
            NSLog(@"end fix");
            [SystemMonitor dump];
#endif
            [self_ showMenu];
            [self_ saveData];
#if IS_STATUS
            [[StatusView GetInstance] showProgress];
#endif
            // animate
            {
                [vc_ setUserInteractionEnabled:FALSE];
                __weak AllyTableView* vc__ = vc_;
                [UIView animateWithDuration:MenuAnimationDuration animations:^{
                    [vc__ setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                } completion:^(BOOL finished) {
                    [vc__ removeFromSuperview];
                }];
            }
#if IS_DEBUG
            NSLog(@"end fix2");
            [SystemMonitor dump];
#endif
        }];
    }
    vc = nil;
    
}

-(void) showMessage
{
    @autoreleasepool {
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
            
            MessageView* msgView = [[MessageView alloc] initWithMessageList:msgList];
            [msgView show];
        }
    }
}

-(void)endReport
{
    // ゲーム終了結果画面の終了後
    // 背景復活
    // クリア画面
    if (hg::UserData::sharedUserData()->isCleared()) {
#if IS_BGM
        [[OALSimpleAudio sharedInstance] playBg:BGM_CLEAR loop:true];
#endif
        ClearView* cv = [[ClearView alloc] initWithFrame:viewFrame];
        __weak MainViewController* self_ =self;
        [cv setOnEndAction:^{
            [self_ showMainView:true showMessage:true];
        }];
        [bottomView addSubview:cv];
        /*
        [self showMainView:true showMessage:true];
        ClearView* cv = [[ClearView alloc] initWithFrame:viewFrame];
        [mainBaseView addSubview:cv];
         */
    }
    else {
        // レベルアップ情報を表示
        [self showMainView:true showMessage:true];
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
        DialogView* dialog = [[DialogView alloc] initWithMessage:NSLocalizedString(@"Please select your Unit.", nil)];
        [dialog addButtonWithText:@"OK" withAction:^{
            // do nothing
        }];
        [dialog show];
        return;
    }
    if (playerFighterInfo->life <= 0)
    {
        DialogView* dialog = [[DialogView alloc] initWithMessage:NSLocalizedString(@"Your unit is bloken. Please repair or change your Units.", nil)];
        [dialog addButtonWithText:@"OK" withAction:^{
            // do nothing
        }];
        [dialog show];
        return;
    }
    
    // 消す
    if (curtain == nil) {
        curtain = [[UIView alloc] initWithFrame:viewFrame];
        [curtain setBackgroundColor:[UIColor blackColor]];
        [curtain setUserInteractionEnabled:NO];
        [curtain setAlpha:0];
    }
    [self.view addSubview:curtain];
    
    [self hideMenuViewAnimate];
    
#if IS_PLAYER_DETAIL
    if (playerDetailView) {
        [playerDetailView removeFromSuperview];
        playerDetailView = nil;
    }
#endif
    
#if IS_GAME_EXEC
    gameView = [[GameView alloc] init];
#endif
    
    __weak MainViewController* self_ = self;
    __weak UIView* mbv = mainBaseView;
    __weak UIView* ctn = curtain;
    [UIView animateWithDuration:0.3 animations:^{
        [mbv setTransform:CGAffineTransformMakeScale(0.8, 0.8)];
        [ctn setAlpha:1];
    } completion:^(BOOL finished) {
        [self_ stageStart2];
    }];
    
#if IS_DEBUG
    NSLog(@"stagestart 2");
    [SystemMonitor dump];
#endif
    
}

- (void)stageStart2
{
    [self removeBackgroundView];
    [self removeMainView];
    
    // ゲーム開始
#if IS_GAME_EXEC
    __weak MainViewController* self_ = self;
    [gameView setOnEndAction:^{
        [self_ onGameEnd];
    }];
    [self.view addSubview:gameView];
#else
    [self onGameEnd];
#endif
    
}

-(void)onGameEnd
{
    @autoreleasepool {
        // ゲーム終了後の結果画面
        [self saveData];
        [curtain removeFromSuperview];
#if IS_DEBUG
        NSLog(@"report 1");
        [SystemMonitor dump];
#endif
        if (gameView) {
            [gameView removeFromSuperview];
            gameView = nil;
        }
#if IS_REPORT
#if IS_REPORT_REUSE
        if (!reportView) {
            reportView = [[ReportView alloc] initWithFrame:mainFrame];
            __weak MainViewController* self_ = self;
            [reportView setOnEndAction:^{
                [self_ endReport];
            }]; // rv setOnEndAction
        }
        [self.view addSubview:reportView];
        [reportView loadReport];
#else
        reportView = [[ReportView alloc] initWithFrame:mainFrame];
        [self.view addSubview:rv];
#endif
#endif
#if IS_BGM
        [[OALSimpleAudio sharedInstance] playBg:BGM_MENU loop:true];
#endif
#if IS_REPORT
        {
#if IS_REPORT_REUSE
            __weak MainViewController* self_ = self;
            [reportView setOnEndAction:^{
                [self_ endReport];
            }]; // rv setOnEndAction
#else
#endif
        }
#else
        // ゲーム終了結果画面の終了後
        // 背景復活
        // クリア画面
        if (hg::UserData::sharedUserData()->isCleared()) {
#if IS_BGM
            [[OALSimpleAudio sharedInstance] playBg:BGM_CLEAR loop:true];
#endif
            [self showMainView:false showMessage:false];
            ClearView* cv = [[ClearView alloc] initWithFrame:viewFrame];
            __weak ClearView* acv = cv;
            __weak MainViewController* self_ = self;
            [cv setOnEndAction:^{
                [acv setUserInteractionEnabled:false];
                [acv removeFromSuperview];
                [self_ showMenu];
                [self_ showMessage];
            }];
            [self_.view addSubview:cv];
        }
        else {
            // レベルアップ情報を表示
            [self showMainView:true showMessage:true];
        }
#endif
#if IS_DEBUG
        NSLog(@"report 2");
        [SystemMonitor dump];
#endif
#if IS_MAIN_ADMOB
        [gadBannerView_ loadRequest:[GADRequest request]];
#endif
    }
    
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

