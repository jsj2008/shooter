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

@interface ViewController()
{
    // game's main thread
    dispatch_queue_t _game_queue;
    
    // UI
    PadView* _leftPadView;
    PadView* _rightPadView;
    
    UIButton* deployBtn;
    UIButton* collectBtn;
    
    // OpenGL
    HGLView* _glview;
    
    //HGGame::t_keystate keystate;
    hg::KeyInfo keyState;
    
}
@end

@implementation ViewController

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
#warning あとで
    return self;
}

- (void)viewDidLoad
{
    ////////////////////
    // 3d描画用ビューを初期化
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    CGRect viewFrame = CGRectMake(0, 0, frame.size.height, frame.size.width);
    _glview = [[HGLView alloc] initWithFrame:viewFrame WithRenderBlock:^{
        @synchronized(self)
        {
            //HGGame::render();
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
    
    hg::FighterInfo* pPlayerInfo = new hg::FighterInfo();
    pPlayerInfo->fighterType = 0;
    pPlayerInfo->life = 3000;
    pPlayerInfo->lifeMax = 3000;
    pPlayerInfo->shield = 3000;
    pPlayerInfo->shieldMax = 3000;
    pPlayerInfo->speed = 0.5;
    
    hg::FriendData friendData;
    {
        hg::FighterInfo* i = new hg::FighterInfo();
        i->fighterType = 1;
        i->life = 2000;
        i->lifeMax = 2000;
        i->shield = 1000;
        i->shieldMax = 1000;
        i->speed = 0.3;
        friendData.push_back(i);
    }
    {
        hg::FighterInfo* i = new hg::FighterInfo();
        i->fighterType = 2;
        i->life = 4000;
        i->lifeMax = 4000;
        i->shield = 11000;
        i->shieldMax = 11000;
        i->speed = 0.1;
        friendData.push_back(i);
    }
    
    // setup game
    //HGGame::initialize();
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
                @synchronized(self)
                {
                    //HGGame::update(&keystate);
                    hg::update(keyState);
                    keyState.shouldDeployFriend = false;
                    keyState.shouldCollectFriend = false;
                }
                [_glview draw];
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
        frame.size.width = 88;
        frame.size.height = 88;
        frame.origin.x = aframe.size.height - frame.size.width - btnGap;
        frame.origin.y = aframe.size.width - frame.size.height - btnGap;
        
        UIButton* fireBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        fireBtn.frame = frame;
        [fireBtn setTitle:@"Fire" forState:UIControlStateNormal];
        [fireBtn addTarget:self action:@selector(startFire) forControlEvents:UIControlEventTouchDown];
        [fireBtn addTarget:self action:@selector(stopFire) forControlEvents:UIControlEventTouchUpInside];
        [fireBtn addTarget:self action:@selector(stopFire) forControlEvents:UIControlEventTouchUpOutside];
        //[fireBtn setAlpha:0.3];
        
        [_glview addSubview:fireBtn];
    }
    
    // デプロイ
    {
        CGRect aframe = [UIScreen mainScreen].applicationFrame;
        CGRect frame = CGRectMake(0, 0, aframe.size.height, aframe.size.width);
        frame.size.width = 44;
        frame.size.height = 44;
        frame.origin.x = aframe.size.height - frame.size.width - btnGap;
        frame.origin.y = aframe.size.width - frame.size.height - 88 - btnGap*2;
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = frame;
        [btn setTitle:@"deploy" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(deployFriend) forControlEvents:UIControlEventTouchUpInside];
        //[btn setAlpha:0.3];
        [_glview addSubview:btn];
        deployBtn = btn;
        
    }
    
    // コレクト
    {
        CGRect aframe = [UIScreen mainScreen].applicationFrame;
        CGRect frame = CGRectMake(0, 0, aframe.size.height, aframe.size.width);
        frame.size.width = 44;
        frame.size.height = 44;
        frame.origin.x = aframe.size.height - frame.size.width - btnGap;
        frame.origin.y = aframe.size.width - frame.size.height - 88 - 44 - btnGap*3;
        
        UIButton* btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        btn.frame = frame;
        [btn setTitle:@"collect" forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(collectFriend) forControlEvents:UIControlEventTouchUpInside];
        //[btn setAlpha:0.3];
        [_glview addSubview:btn];
        collectBtn = btn;
        
        [btn setAlpha:0.5];
        [btn setEnabled:false];
        
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
    int64_t delayInSeconds = 10;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [collectBtn setEnabled:true];
        [collectBtn setAlpha:1];
    });
}
- (void) collectFriend
{
    keyState.shouldCollectFriend = true;
    [collectBtn setEnabled:false];
    [collectBtn setAlpha:0.5];
    int64_t delayInSeconds = 10;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [deployBtn setEnabled:true];
        [deployBtn setAlpha:1];
    });
}

@end
