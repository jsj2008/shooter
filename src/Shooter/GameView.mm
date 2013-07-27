//
//  ViewController.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "GameView.h"
//#import "HGGame.h"
#import "HGame.h"
#import "HGLView.h"
#import "PadView.h"
#import "Common.h"
#import "TouchHandlerView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+MyCategory.h"
#import "UIColor+MyCategory.h"
#import "UserData.h"
#import "MenuButton.h"
#import "ImageButtonView.h"
#import "AllyTableView.h"

#define DEPLOY_BTN_SIZE 50


@interface GameView()
{
    // game's main thread
    dispatch_queue_t _game_queue;
    
    UIButton* deployBtn;
    
    // OpenGL
    HGLView* _glview;
    
    //HGGame::t_keystate keystate;
    hg::KeyInfo keyState;
    
    // deploy button state
    NSTimeInterval deployedTime;
    NSTimeInterval collectedTime;
    CALayer* deployBtnSubLayer;
    
    // action
    void (^onEndAction)();
    
    // base
    UIView* baseView;
    CGRect baseFrame;
    
    UIView* baseCurtain;
    
}
@end

@implementation GameView

static NSObject* lock = nil;

- (void)dealloc
{
    if (_glview) {
        [_glview release];
    }
    if (onEndAction)
    {
        [onEndAction release];
    }
    [baseView release];
    [baseCurtain release];
    [super dealloc];
}

- (id) initWithOnEndAction:(void(^)(void))action
{
    self = [super init];
    onEndAction = [action copy];
    if (lock == nil)
    {
        lock = [[NSObject alloc] init];
    }
    if (self)
    {
        CGRect frame = [[UIScreen mainScreen] applicationFrame];
        CGRect viewFrame = CGRectMake(0, 0, frame.size.height, frame.size.width);
        [self setFrame:viewFrame];
        
        // 3d描画用ビューを初期化
        _glview = [[HGLView alloc] initWithFrame:viewFrame WithRenderBlock:^{
            @synchronized(lock)
            {
                hg::render();
            }
        }];
        [self addSubview:_glview];
        [self initialize];
        
        // 描画開始
        [_glview start];
        
    }
    return self;
}

// UI初期化
- (void)initialize
{
    
    @synchronized(lock)
    {
        // initialize game
        {
            // 出現リスト読み込み
            NSBundle* bundle = [NSBundle mainBundle];
            NSString* path = [bundle pathForResource:@"enemyList" ofType:@"json"];
            NSData* dataEnemyList = [NSData dataWithContentsOfFile:path];
            NSError* error;
            NSDictionary* dicEnemyList = [NSJSONSerialization JSONObjectWithData:dataEnemyList options:kNilOptions error:&error];
            
            // Create Spawn Data
            hg::SpawnData spawnData;
            for (NSDictionary* d in dicEnemyList)
            {
                int tmpGroup = [[d valueForKey:@"group"] integerValue] - 1;
#warning DELETE FIGHTER DATA AFTER GAME!!!!!!!!
                hg::FighterInfo* f = new hg::FighterInfo();
                int fighterType = [[d valueForKey:@"fighterType"] integerValue];
                hg::UserData::setDefaultInfo(f, fighterType);
                f->level = [[d valueForKey:@"level"] integerValue];
                if (tmpGroup >= spawnData.size())
                {
                    spawnData.push_back(hg::SpawnGroup());
                }
                spawnData[tmpGroup].push_back(f);
            }
            
            // initialize game
            hg::FighterInfo* pPlayerInfo = hg::UserData::sharedUserData()->getPlayerInfo();
            assert(pPlayerInfo != NULL);
            
            // setup game
            hg::cleanup();
            
            hg::initialize(spawnData, pPlayerInfo);
            
            // creating game thread
            _game_queue = dispatch_queue_create("com.hayo.shooter.game", NULL);
            //_game_queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(_game_queue, ^{
                NSDate* nowDt;
                NSTimeInterval start;
                NSTimeInterval end;
                float base_sleep = 1.0/FPS;
                float sleep;
                while (1)
                {
                    nowDt = [NSDate date];
                    start = [nowDt timeIntervalSince1970];
                    {
                        // calling game's main process
                        @synchronized(lock)
                        {
                            hg::update(keyState);
                            keyState.shouldDeployFriend = false;
                            keyState.shouldCollectFriend = false;
                            [_glview draw];
                            if (hg::isGameEnd())
                            {
                                NSLog(@"is game end");
                                // 終了処理
                                hg::UserData::sharedUserData()->initAfterBattle();
                                // 戦果集計
                                {
                                    using namespace hg;
                                    BattleResult br = getResult();
                                    UserData* u = UserData::sharedUserData();
                                    u->addMoney(br.earnedMoney);
                                }
                                
                                // フェードアウト
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    CGRect f = [UIScreen mainScreen].applicationFrame;
                                    CGRect cf = f;
                                    cf.size.width = f.size.height;
                                    cf.size.height = f.size.width;
                                    [baseCurtain setUserInteractionEnabled:true];
                                    [baseCurtain setBackgroundColor:[UIColor blackColor]];
                                    [baseCurtain setAlpha:0];
                                    [UIView animateWithDuration:1.0 animations:^{
                                        [baseCurtain setAlpha:1];
                                    } completion:^(BOOL finished) {
                                        onEndAction();
                                    }];
                                });
                                break;
                            }
                        }
                    }
                    nowDt = [NSDate date];
                    end = [nowDt timeIntervalSince1970];
                    sleep = base_sleep - (end - start);
                    if (sleep > 0)
                    {
                        [NSThread sleepForTimeInterval:sleep];
                    }
                    
                }
            });
        }// end of initialize game
        
        // baseview
        {
            CGRect aframe = [UIScreen mainScreen].applicationFrame;
            CGRect frame = CGRectMake(0, 0, aframe.size.height, aframe.size.width);
            frame.origin.x = 0;
            frame.origin.y = 0;
            baseView = [[UIView alloc] initWithFrame:frame];
            [baseView setBackgroundColor:[UIColor clearColor]];
            baseFrame = frame;
            [self addSubview:baseView];
        }
        
        // タッチイベント(左)
        {
            CGRect frame = baseFrame;
            UIView* _leftPadView = [[[PadView alloc] initWithFrame:frame WithOnTouchBlock:^(int degree, float power, bool touchBegan, bool touchEnd) {
                keyState.degree = degree;
                keyState.power = power;
            }] autorelease];
            [baseView addSubview:_leftPadView];
        }
        
        float btnGap = 12;
        // 発射ボタン
        {
            CGRect frame;
            frame.size.width = 100;
            frame.size.height = 100;
            frame.origin.x = baseFrame.size.width - frame.size.width - btnGap;
            frame.origin.y = baseFrame.size.height - frame.size.height - btnGap;
            
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = frame;
            [button setTitle:@"Fire" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(startFire) forControlEvents:UIControlEventTouchDown];
            [button addTarget:self action:@selector(stopFire) forControlEvents:UIControlEventTouchUpInside];
            [button addTarget:self action:@selector(stopFire) forControlEvents:UIControlEventTouchUpOutside];
            [button setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
            
            // ボタンデザイン
            [button.layer setCornerRadius:48];
            [button.layer setMasksToBounds:YES];
            [button.layer setBorderWidth:3];
            [button.layer setBorderColor:[[UIColor colorWithHexString:@"#ffffff"] CGColor]];
            
            [button setBackgroundColorString:@"#67e300" forState:UIControlStateNormal radius:0];
            [button setBackgroundColorString:@"#ff4940" forState:UIControlStateHighlighted radius:0];
            
            [button.titleLabel setFont:[UIFont fontWithName:@"EuphemiaUCAS" size:12]];
            [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            
            UIColor *color = button.currentTitleColor;
            button.titleLabel.layer.shadowColor = [color CGColor];
            button.titleLabel.layer.shadowRadius = 4.0f;
            button.titleLabel.layer.shadowOpacity = .9;
            button.titleLabel.layer.shadowOffset = CGSizeZero;
            button.titleLabel.layer.masksToBounds = NO;
            
            [baseView addSubview:button];
        }
        
        // deploy
        {
            CGRect frame;
            frame.size.width = DEPLOY_BTN_SIZE;
            frame.size.height = DEPLOY_BTN_SIZE;
            frame.origin.x = baseFrame.size.width - frame.size.width - btnGap;
            frame.origin.y = baseFrame.size.height - frame.size.height - btnGap - 160;
            
            ImageButtonView* backImgView = [[ImageButtonView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
            UIImage* img = [UIImage imageNamed:@"checkmark.png"];
            
            [backImgView setBackgroundColor:[UIColor whiteColor]];
            [backImgView setFrame:frame];
            [backImgView.layer setCornerRadius:8];
            [backImgView.layer setBorderColor:[UIColor colorWithHexString:@"#222222"].CGColor];
            [backImgView.layer setBorderWidth:3];
            
            [backImgView setImage:img];
            [backImgView setContentMode:UIViewContentModeScaleAspectFit];
            [backImgView setUserInteractionEnabled:YES];
            
            [baseView addSubview:backImgView];
            
            [backImgView setOnTapAction:^(ImageButtonView *target) {
                hg::setPause(true);
                [baseCurtain setUserInteractionEnabled:true];
                [UIView animateWithDuration:0.2 animations:^{
                    [baseCurtain setBackgroundColor:[UIColor blackColor]];
                    [baseCurtain setAlpha:0.8];
                }];
                
                AllyTableView* vc = [[[AllyTableView alloc] initWithViewMode:AllyViewModeDeployAlly WithFrame:baseFrame] autorelease];
                [self addSubview:vc];
                // animate
                {
                    [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                    [vc setUserInteractionEnabled:FALSE];
                    [UIView animateWithDuration:0.2 animations:^{
                        [vc setAlpha:1];
                        [vc setTransform:CGAffineTransformMakeScale(1,1)];
                    }completion:^(BOOL finished) {
                        [vc setUserInteractionEnabled:TRUE];
                    }];
                }
                [vc setOnEndAction:^{
                    // animate
                    {
                        [vc setUserInteractionEnabled:FALSE];
                        [UIView animateWithDuration:0.2 animations:^{
                            [baseCurtain setAlpha:0];
                            [baseCurtain setUserInteractionEnabled:false];
                            [vc setTransform:CGAffineTransformMakeScale(1.5, 0.0)];
                        } completion:^(BOOL finished) {
                            [vc removeFromSuperview];
                            hg::setPause(false);
                            hg::deployFriends();
                        }];
                    }
                }];
            }];
        }
        
        // curtain
        {
            baseCurtain = [[UIView alloc] initWithFrame:baseFrame];
            [self addSubview:baseCurtain];
            [baseCurtain setUserInteractionEnabled:false];
        }
        
    }
    
}

- (void) startFire
{
    keyState.isFire = 1;
}

- (void) stopFire
{
    keyState.isFire = 0;
}

@end
