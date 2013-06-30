//
//  ViewController.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "ViewController.h"
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

#define DEPLOY_BTN_SIZE 50


@interface ViewController()
{
    // game's main thread
    dispatch_queue_t _game_queue;
    
    // UI
    PadView* _leftPadView;
    PadView* _rightPadView;
    
    UIButton* deployBtn;
    
    // OpenGL
    HGLView* _glview;
    
    //HGGame::t_keystate keystate;
    hg::KeyInfo keyState;
    
    // deploy button state
    NSTimeInterval deployedTime;
    NSTimeInterval collectedTime;
    CALayer* deployBtnSubLayer;
    
}
@end

@implementation ViewController

static NSObject* lock = nil;

- (void)dealloc
{
    if (_glview) {
        [_glview release];
    }
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (lock == nil)
    {
        lock = [[NSObject alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    ////////////////////
    // 3d描画用ビューを初期化
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    CGRect viewFrame = CGRectMake(0, 0, frame.size.height, frame.size.width);
    _glview = [[HGLView alloc] initWithFrame:viewFrame WithRenderBlock:^{
        @synchronized(lock)
        {
            hg::render();
        }
    }];
    self.view = _glview;
    
    ////////////////////
    // 3d以外の初期化
    _leftPadView = nil;
    _rightPadView = nil;
    
    [self initialize];
    
    ////////////////////
    // 描画開始
    [_glview start];
}

- (void)initialize
{
    
    @synchronized(lock)
    {
        
        // 出現リスト読み込み
        NSBundle* bundle = [NSBundle mainBundle];
        NSString* path = [bundle pathForResource:@"enemyList" ofType:@"json"];
        NSData* dataEnemyList = [NSData dataWithContentsOfFile:path];
        NSError* error;
        NSDictionary* dicEnemyList = [NSJSONSerialization JSONObjectWithData:dataEnemyList options:kNilOptions error:&error];
        
#warning DELETE FIGHTER DATA AFTER GAME!!!!!!!!
        // Create Spawn Data
        hg::SpawnData spawnData;
        for (NSDictionary* d in dicEnemyList)
        {
            int tmpGroup = [[d valueForKey:@"group"] integerValue] - 1;
            hg::FighterInfo* f = new hg::FighterInfo();
            f->fighterType = [[d valueForKey:@"fighterType"] integerValue];
            f->level = [[d valueForKey:@"level"] integerValue];
            if (tmpGroup >= spawnData.size())
            {
                spawnData.push_back(hg::SpawnGroup());
            }
            spawnData[tmpGroup].push_back(f);
        }
        
        
        hg::FighterInfo* pPlayerInfo = NULL;
        hg::FriendData friendData;
        hg::FighterList fList = hg::UserData::sharedUserData()->getFighterList();
        
        for (hg::FighterList::iterator it = fList.begin(); it != fList.end(); ++it)
        {
            hg::FighterInfo* info = *it;
            if (info->isPlayer)
            {
                pPlayerInfo = info;
                continue;
            }
            if (info->isReady && info->life > 0)
            {
                friendData.push_back(info);
                continue;
            }
        }
        
        // setup game
        //HGGame::initialize();
        hg::cleanup();
        hg::initialize(spawnData, pPlayerInfo, friendData);
        
        // creating game thread
        _game_queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
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
                            // 終了処理
                            // フェードアウト
                            dispatch_async(dispatch_get_main_queue(), ^{
                                CGRect f = [UIScreen mainScreen].applicationFrame;
                                CGRect cf = f;
                                cf.size.width = f.size.height;
                                cf.size.height = f.size.width;
                                UIView* curtain = [[[UIView alloc] initWithFrame:cf] autorelease];
                                [curtain setBackgroundColor:[UIColor blackColor]];
                                [curtain setAlpha:0];
                                [self.view addSubview:curtain];
                                [UIView animateWithDuration:1.0 animations:^{
                                    [curtain setAlpha:1];
                                } completion:^(BOOL finished) {
                                    [self dismissViewControllerAnimated:true completion:^{
                                    }];
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
        
        // タッチイベント(左)
        {
            CGRect aframe = [UIScreen mainScreen].applicationFrame;
            CGRect frame = CGRectMake(0, 0, aframe.size.height, aframe.size.width);
            frame.origin.x = 0;
            frame.origin.y = aframe.size.width - frame.size.height;
            _leftPadView = [[[PadView alloc] initWithFrame:frame WithOnTouchBlock:^(int degree, float power, bool touchBegan, bool touchEnd) {
                keyState.degree = degree;
                keyState.power = power;
            }] autorelease];
            [_glview addSubview:_leftPadView];
        }
        
        float btnGap = 12;
        // 発射ボタン
        {
            CGRect aframe = [UIScreen mainScreen].applicationFrame;
            CGRect frame = CGRectMake(0, 0, aframe.size.height, aframe.size.width);
            frame.size.width = 100;
            frame.size.height = 100;
            frame.origin.x = aframe.size.height - frame.size.width - btnGap;
            frame.origin.y = aframe.size.width - frame.size.height - btnGap;
            
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
            
            [_glview addSubview:button];
        }
        
        // デプロイ
        {
            
            CGRect aframe = [UIScreen mainScreen].applicationFrame;
            CGRect frame = CGRectMake(0, 0, aframe.size.height, aframe.size.width);
            frame.size.width = DEPLOY_BTN_SIZE;
            frame.size.height = DEPLOY_BTN_SIZE;
            frame.origin.x = aframe.size.height - frame.size.width - btnGap;
            frame.origin.y = aframe.size.width - frame.size.height - btnGap - 120;
            
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = frame;
            [button setTitle:@"Ally" forState:UIControlStateNormal];
            [button addTarget:self action:@selector(deployFriend) forControlEvents:UIControlEventTouchUpInside];
            [button setContentVerticalAlignment:UIControlContentVerticalAlignmentBottom];
            
            // ボタンデザイン
            [button.layer setCornerRadius:DEPLOY_BTN_SIZE/2];
            [button.layer setMasksToBounds:YES];
            [button.layer setBorderWidth:3];
            [button.layer setBorderColor:[[UIColor colorWithHexString:@"#ffffff"] CGColor]];
            
            [button setBackgroundColorString:@"#64aa2b" forState:UIControlStateNormal radius:0];
            [button setBackgroundColorString:@"#ff4940" forState:UIControlStateHighlighted radius:0];
            [button setBackgroundColorString:@"#666666" forState:UIControlStateDisabled radius:0];
            
            [button.titleLabel setFont:[UIFont fontWithName:@"EuphemiaUCAS" size:12]];
            [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            
            UIColor *color = button.currentTitleColor;
            button.titleLabel.layer.shadowColor = [color CGColor];
            button.titleLabel.layer.shadowRadius = 4.0f;
            button.titleLabel.layer.shadowOpacity = .9;
            button.titleLabel.layer.shadowOffset = CGSizeZero;
            button.titleLabel.layer.masksToBounds = NO;
            
            [_glview addSubview:button];
            deployBtn = button;
            
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

- (void) deployFriend
{
    keyState.shouldDeployFriend = true;
    [deployBtn setEnabled:false];
    [deployBtn setAlpha:0.5];
    
    deployedTime = [[NSDate date] timeIntervalSince1970];
    [self tickDeployButton];
    
    deployBtnSubLayer = [CALayer layer];
    [deployBtnSubLayer setBackgroundColor:[UIColor colorWithHexString:@"#ff4940"].CGColor];
    [deployBtnSubLayer setFrame:CGRectMake(0, 0, 0, 0)];
    [deployBtnSubLayer setCornerRadius:0];
    [deployBtn.layer addSublayer:deployBtnSubLayer];
}

- (void) tickDeployButton
{
    int64_t delayInSeconds = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSTimeInterval diff = [[NSDate date] timeIntervalSince1970] - deployedTime;
        if (diff >= 10)
        {
            // 冷却完了
            [deployBtn setEnabled:true];
            [deployBtn setAlpha:1];
            [deployBtn setTitle:@"Alone" forState:UIControlStateNormal];
            [deployBtn removeTarget:self action:@selector(deployFriend) forControlEvents:UIControlEventTouchUpInside];
            [deployBtn addTarget:self action:@selector(collectFriend) forControlEvents:UIControlEventTouchUpInside];
            [deployBtnSubLayer removeFromSuperlayer];
        }
        else
        {
            [deployBtn setTitle:[NSString stringWithFormat:@"%.1f", 10 - diff] forState:UIControlStateNormal];
            float w = (DEPLOY_BTN_SIZE*0.95)*(10-diff)/10;
            [deployBtnSubLayer setFrame:CGRectMake(DEPLOY_BTN_SIZE/2-w/2, DEPLOY_BTN_SIZE/2-w/2, w, w)];
            [deployBtnSubLayer setCornerRadius:w/2];
            [self tickDeployButton];
        }
    });
}

- (void) collectFriend
{
    keyState.shouldCollectFriend = true;
    [deployBtn setEnabled:false];
    [deployBtn setAlpha:0.5];
    collectedTime = [[NSDate date] timeIntervalSince1970];
    [self tickCollectButton];
    
    deployBtnSubLayer = [CALayer layer];
    [deployBtnSubLayer setBackgroundColor:[UIColor colorWithHexString:@"#ff4940"].CGColor];
    [deployBtnSubLayer setFrame:CGRectMake(0, 0, DEPLOY_BTN_SIZE, DEPLOY_BTN_SIZE)];
    [deployBtnSubLayer setCornerRadius:DEPLOY_BTN_SIZE/2];
    [deployBtn.layer addSublayer:deployBtnSubLayer];
}

- (void) tickCollectButton
{
    int64_t delayInSeconds = 0.05;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSTimeInterval diff = [[NSDate date] timeIntervalSince1970] - collectedTime;
        if (diff >= 10)
        {
            // 冷却完了
            [deployBtn setEnabled:true];
            [deployBtn setAlpha:1];
            [deployBtn setTitle:@"Ally" forState:UIControlStateNormal];
            [deployBtn removeTarget:self action:@selector(collectFriend) forControlEvents:UIControlEventTouchUpInside];
            [deployBtn addTarget:self action:@selector(deployFriend) forControlEvents:UIControlEventTouchUpInside];
            [deployBtnSubLayer removeFromSuperlayer];
        }
        else
        {
            [deployBtn setTitle:[NSString stringWithFormat:@"%.1f", 10 - diff] forState:UIControlStateNormal];
            float w = (DEPLOY_BTN_SIZE*0.95)*(10-diff)/10;
            [deployBtnSubLayer setFrame:CGRectMake(DEPLOY_BTN_SIZE/2-w/2, DEPLOY_BTN_SIZE/2-w/2, w, w)];
            [deployBtnSubLayer setCornerRadius:w/2];
            [self tickCollectButton];
        }
    });
}

@end
