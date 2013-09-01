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
    
    PlayerDetailView* playerDetailView;
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
    // 背景終了
    [backgroundView clearGL];
    [backgroundView removeFromSuperview];
    backgroundView = NULL;
}

+ (void)ShowBackgroundView
{
    if (instance) {
        [instance showBackgroundView];
    }
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

- (void)saveData
{
    // データ保存
    bool ret = hg::UserData::sharedUserData()->saveData();
    if (!ret) {
        DialogView* dialog = [[[DialogView alloc] initWithMessage:@"Sorry, an unexpected error happend!"] autorelease];
        [dialog addButtonWithText:@"OK" withAction:^{
        }];
        [dialog show];
    }
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
                    [m setColor:[UIColor colorWithHexString:@"#ff4444"]];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        
                        if (hg::UserData::sharedUserData()->getCurrentClearRatio() < 1.0) {
                            [self stageStart];
                        }
                        else {
                            NSString* msg = [NSString stringWithFormat:@"You've already cleared this stage. Please Select new Stage."];
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:msg] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                // nothing
                            }];
                            [dialog show];
                        }
                    }];
                }
                
                // Select your ship.
                buttonY += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Select My Unit"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeSelectPlayer WithFrame:mainFrame] autorelease];
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
                            [[StatusView GetInstance] showProgress];
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
                
                // repair all
                buttonY += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Repair All Units"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        // buy
                        int cost = hg::UserData::sharedUserData()->getRepairAllCost();
                        if (cost == 0) {
                            NSString* msg = [NSString stringWithFormat:@"You don't need to do this."];
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:msg] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                // nothing
                            }];
                            [dialog show];
                        } else if (hg::UserData::sharedUserData()->getMoney() >= cost) {
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
                        else {
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
                }
                
                // battle with someone
                buttonY += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX, buttonY, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Select Units"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeSelectAlly WithFrame:mainFrame] autorelease];
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
                }
                
            } // end of menu 1
            
            {
                //float buttonX2 = mainFrame.size.width - 10 - MenuButtonWidth - 20 - MenuButtonWidth;
                float buttonX2 = 10;
                float buttonY2 = StatusViewHeight + 5;
                
                // buy ally
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Buy Units"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        [self hideMenuViewAnimate];
                        AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeShop WithFrame:mainFrame] autorelease];
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
                }
                
                // sell ally
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Sell Units"];
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
                }
                
                // select stage
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Return to Base"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        NSString* msg = @"";
                        if (hg::UserData::sharedUserData()->getCurrentClearRatio() < 1.0) {
                            msg = @"You will get All fighters repaired and lose half of the Money. Are you sure to do this?";
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:msg] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                hg::UserData* u = hg::UserData::sharedUserData();
                                u->returnToBase();
                                u->saveData();
                                [[StatusView GetInstance] loadUserInfo];
                                if (playerDetailView) {
                                    [playerDetailView loadGrade];
                                }
                                DialogView* dialog2 = [[[DialogView alloc] initWithMessage:@"Welcome back to the Base! All fighters are repaired now!"] autorelease];
                                [dialog2 addButtonWithText:@"OK" withAction:^{
                                    // do nothing
                                }];
                                [dialog2 show];
                            }];
                            [dialog addButtonWithText:@"Cancel" withAction:^{
                                // do nothing
                            }];
                            [dialog show];
                        }
                        // no penalty
                        else {
                            DialogView* dialog2 = [[[DialogView alloc] initWithMessage:@"Do you want to start over this stage again?"] autorelease];
                            [dialog2 addButtonWithText:@"OK" withAction:^{
                                hg::UserData* u = hg::UserData::sharedUserData();
                                u->returnToBase();
                                u->saveData();
                                [[StatusView GetInstance] loadUserInfo];
                                if (playerDetailView) {
                                    [playerDetailView loadGrade];
                                }
                            }];
                            [dialog2 addButtonWithText:@"Cancel" withAction:^{
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
                    [m setText:@"Select Stage"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        
                        hg::UserData* u = hg::UserData::sharedUserData();
                        if (u->getCurrentClearRatio() == 0 || u->getCurrentClearRatio() >= 1.0) {
                            
                            // show select area table view
                            [self hideMenuViewAnimate];
                            StageTableView* vc = [[[StageTableView alloc] initWithFrame:mainFrame] autorelease];
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
                                [[StatusView GetInstance] showProgress];
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
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:@"You can change the Stage when the Occupy Ratio is 0% or 100%"] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                // do nothing
                            }];
                            [dialog show];
                            
                        }
                        
                    }];
                }
                
                // option stage
                /*
                buttonY2 += (MenuButtonHeight + MenuButtonGap);
                {
                    CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
                    MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
                    [m setText:@"Delete Data"];
                    [menuBaseView addSubview:m];
                    [m setOnTapAction:^(MenuButton *target) {
                        DialogView* dialog = [[[DialogView alloc] initWithMessage:@"Are you sure to delete all of your game data?"] autorelease];
                        [dialog addButtonWithText:@"OK" withAction:^{
                            DialogView* dialog = [[[DialogView alloc] initWithMessage:@"If you delete the data, it would never be back. Is it really OK?"] autorelease];
                            [dialog addButtonWithText:@"OK" withAction:^{
                                hg::UserData::DeleteAllData();
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [[StatusView GetInstance] loadUserInfo];
                                    // reload detail view
                                    {
                                        if (playerDetailView) {
                                            [playerDetailView removeFromSuperview];
                                            [playerDetailView release];
                                            playerDetailView = nil;
                                        }
                                        CGRect playderDetailViewFrame = CGRectMake(0, 0, viewFrame.size.width, viewFrame.size.height);
                                        playerDetailView = [[PlayerDetailView alloc] initWithFrame:playderDetailViewFrame];
                                        [self.view addSubview:playerDetailView];
                                        [playerDetailView loadGrade];
                                    }
                                });
                                DialogView* dialog = [[[DialogView alloc] initWithMessage:@"You now on fresh start! Good luck!"] autorelease];
                                [dialog addButtonWithText:@"OK" withAction:^{
                                }];
                                [dialog show];
                            }];
                            [dialog addButtonWithText:@"Cancel" withAction:^{
                            }];
                            [dialog show];
                        }];
                        [dialog addButtonWithText:@"Cancel" withAction:^{
                            // do nothing
                        }];
                        [dialog show];
                    }];
                }*/
            } // end of menu 2
            
        }
    });
    
}

-(void)showMainView:(bool)showMenu showMessage:(bool)showMessage
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        mainBaseView = [[[UIView alloc] initWithFrame:viewFrame] autorelease];
        [mainBaseView setBackgroundColor:[UIColor clearColor]];
        [self.view addSubview:mainBaseView];
        
        // ステータス
        statusView = [StatusView CreateInstance];
        [mainBaseView addSubview:statusView];
        [statusView loadUserInfo];
        
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
    // check
    hg::UserData* userData = hg::UserData::sharedUserData();
    hg::FighterInfo* playerFighterInfo = userData->getPlayerFighterInfo();
    if (playerFighterInfo == NULL)
    {
        DialogView* dialog = [[[DialogView alloc] initWithMessage:@"Please select your Unit."] autorelease];
        [dialog addButtonWithText:@"OK" withAction:^{
            // do nothing
        }];
        [dialog show];
        return;
    }
    if (playerFighterInfo->life <= 0)
    {
        DialogView* dialog = [[[DialogView alloc] initWithMessage:@"Your unit is bloken. Please repair or change your Units."] autorelease];
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
    
    [playerDetailView removeFromSuperview];
    
    [UIView animateWithDuration:0.5 animations:^{
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
                ReportView* rv = [[ReportView alloc] initWithFrame:mainFrame];
                [[OALSimpleAudio sharedInstance] playBg:BGM_MENU loop:true];
                [self.view addSubview:rv];
                [rv autorelease];
                [rv setOnEndAction:^{
                    // ゲーム終了結果画面の終了後
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 背景復活
                        [gameView removeFromSuperview];
                        [self showBackgroundView];
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
            }); // dispatch_async
        }] autorelease]; // [[GameView alloc] initWithOnEndAction:
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
