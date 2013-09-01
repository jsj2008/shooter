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
#import "HGameEngine.h"
#import "TouchHandlerView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIButton+MyCategory.h"
#import "UIColor+MyCategory.h"
#import "UserData.h"
#import "MenuButton.h"
#import "ImageButtonView.h"
#import "AllyTableView.h"
#import "DialogView.h"
#import "ObjectAL.h"
#import <vector>

#define DEPLOY_BTN_SIZE 50
#define CAMERA_ADJUST_BTN_SIZE 35

#define GAUGE_FRAME_WIDTH 20
#define GAUGE_FRAME_HEIGHT 160
#define GAUGE_BAR_WIDTH 10
#define GAUGE_BAR_HEIGHT 150

typedef struct EnemyData {
    EnemyData(int _fighterType):
        fighterType(_fighterType)
    {
    }
    int fighterType = 1000;
} EnemyData;

typedef std::vector<EnemyData> EnemyDataList;

typedef struct EnemyGroup {
    EnemyGroup(int in_stage_id, int in_min_prog):
    stage_id(in_stage_id),
    min_prog(in_min_prog){}
    int stage_id = 1;
    int min_prog = 1;
    EnemyDataList enemyDataList;
} EnemyGroup;

typedef std::vector<EnemyGroup> EnemyGroupList;

typedef struct EnemyGroupInfo
{
    EnemyGroupInfo(int inFromStageId, int inToStageId):
    fromStageId(inFromStageId),
    toStageId(inToStageId)
    {}
    int fromStageId = 0;
    int toStageId = 0;
} EnemyGroupInfo;

typedef std::vector<EnemyGroupInfo> EnemyGroupInfoList;

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
    
    bool upCamera;
    bool downCamera;
    bool isPlaying;
    
    CGRect hpGaugeFrameRect;
    CGRect shieldGaugeFrameRect;
    CGRect hpGaugeRect;
    CGRect shieldGaugeRect;
    UIView* hpGaugeBar;
    UIView* shieldGaugeBar;
    hg::FighterList enemyList;
    
}
@end

@implementation GameView

static NSObject* lock = nil;
static EnemyGroupList enemyGroupList;
static EnemyGroupInfoList enemyGroupInfoList;

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
    if (hpGaugeBar) {
        [hpGaugeBar release];
    }
    if (shieldGaugeBar) {
        [shieldGaugeBar release];
    }
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
        isPlaying = false;
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

- (void)initSpawnData
{
    if (enemyGroupList.size() > 0) return;
    
    // 出現リスト読み込み
    NSBundle* bundle = [NSBundle mainBundle];
    NSString* path = [bundle pathForResource:@"enemyList" ofType:@"json"];
    NSData* dataEnemyList = [NSData dataWithContentsOfFile:path];
    NSError* error;
    NSDictionary* dicEnemyList = [NSJSONSerialization JSONObjectWithData:dataEnemyList options:kNilOptions error:&error];
    
    EnemyGroup enemyGroup(-1, -1);
    enemyGroupInfoList.clear();
    int currentGroupId = -1;
    int from = 0;
    int current = -1;
    int currentStageId = 1;
    int size = [dicEnemyList count];
    int counter = 0;
    for (NSDictionary* d in dicEnemyList)
    {
        ++counter;
        int tmpGroupId = [[d valueForKey:@"group"] integerValue];
        int stage = [[d valueForKey:@"stage"] integerValue];
        int min_prog = [[d valueForKey:@"min_prog"] integerValue];
        int fighterType = [[d valueForKey:@"fighterType"] integerValue];
        if (currentGroupId != tmpGroupId) {
            if (enemyGroup.enemyDataList.size() > 0) {
                enemyGroupList.push_back(enemyGroup);
            }
            if (stage != currentStageId) {
                enemyGroupInfoList.push_back(EnemyGroupInfo(from, current));
                currentStageId = stage;
                from = ++current;
            } else {
                ++current;
            }
            enemyGroup = EnemyGroup(stage, min_prog);
            enemyGroup.enemyDataList.push_back(EnemyData(fighterType));
            currentGroupId = tmpGroupId;
        } else {
            enemyGroup.enemyDataList.push_back(EnemyData(fighterType));
        }
        if (size == counter) {
            enemyGroup.enemyDataList.push_back(EnemyData(fighterType));
            enemyGroupList.push_back(enemyGroup);
            enemyGroupInfoList.push_back(EnemyGroupInfo(from, current));
        }
    }
}

// UI初期化
- (void)initialize
{
    
    @synchronized(lock)
    {
        // initialize game
        {
            hg::initRandom();
            [self initSpawnData];

            upCamera = false;
            downCamera = false;
            enemyList.clear();
            
            // enemy listの抽選
            hg::SpawnData spawnData;
            int min_appear_count = 1;
            int max_appear_count = 2;
            int stage_id = hg::UserData::sharedUserData()->getStageId();
            int clear_ratio = (int)(hg::UserData::sharedUserData()->getCurrentClearRatio() * 100.0);
            bool is_last_stage = hg::UserData::sharedUserData()->isLastStageNow();
            switch (stage_id) {
                case 1:
                    if (clear_ratio > 50) {
                        max_appear_count = 2;
                    }
                    break;
                case 2:
                    max_appear_count = 3;
                    break;
                case 3:
                    max_appear_count = 4;
                    break;
                case 4:
                    max_appear_count = 4;
                    break;
                case 5:
                    max_appear_count = 5;
                    break;
            }
            int appear_num = hg::rand(min_appear_count, max_appear_count);
            float plus = 0;
            if (is_last_stage) {
                switch (stage_id) {
                    case 1:
                        appear_num = 2;
                        break;
                    case 2:
                        appear_num = 3;
                        plus = 1.2;
                        break;
                    case 3:
                        appear_num = 3;
                        plus = 1.4;
                        break;
                    case 4:
                        appear_num = 4;
                        plus = 1.6;
                        break;
                    case 5:
                        appear_num = 4;
                        plus = 2;
                        break;
                }
            }
            int from_group_index = enemyGroupInfoList[0].fromStageId;
            int to_group_index = enemyGroupInfoList[stage_id - 1].toStageId;
            int group_id = -1;
            int group_create_decrementer = appear_num;
            while (group_create_decrementer > 0) {
                int group_index = hg::rand(from_group_index, to_group_index);
                EnemyGroup enemyGroup = enemyGroupList[group_index];
                if (enemyGroup.stage_id == stage_id && enemyGroup.min_prog > clear_ratio) {
                    continue;
                } else {
                    group_id++;
                    spawnData.push_back(hg::SpawnGroup());
                    group_create_decrementer--;
                    int fix_enemy_lv = -1;
                    if (hg::rand(0, 100) <= 50) {
                        fix_enemy_lv = hg::rand(0, hg::UserData::sharedUserData()->getStageInfo().maxEnemyWeaponLv);
                    }
                    for (EnemyDataList::iterator it = enemyGroup.enemyDataList.begin(); it != enemyGroup.enemyDataList.end(); ++it) {
                        EnemyData enemyData = *it;
                        hg::FighterInfo* f = new hg::FighterInfo();
                        enemyList.push_back(f);
                        hg::UserData::sharedUserData()->setDefaultInfo(f, enemyData.fighterType);
                        spawnData[group_id].push_back(f);
                        if (appear_num > (appear_num - group_create_decrementer)) {
                            if (hg::rand(0, 100) <= 4 * (group_create_decrementer)) {
                                
                            }
                        }
                    }
                }
            }
            // add boss
            switch (stage_id) {
                case 1:
                    if (is_last_stage) {
                        hg::FighterInfo* f = new hg::FighterInfo();
                        enemyList.push_back(f);
                        hg::UserData::sharedUserData()->setDefaultInfo(f, 3000);
                        spawnData[group_id].push_back(f);
                    }
                    break;
                case 2:
                    if (is_last_stage) {
                        hg::FighterInfo* f = new hg::FighterInfo();
                        enemyList.push_back(f);
                        hg::UserData::sharedUserData()->setDefaultInfo(f, 3100);
                        spawnData[group_id].push_back(f);
                    }
                    break;
                case 3:
                    if (is_last_stage) {
                        hg::FighterInfo* f = new hg::FighterInfo();
                        enemyList.push_back(f);
                        hg::UserData::sharedUserData()->setDefaultInfo(f, 3200);
                        spawnData[group_id].push_back(f);
                    }
                    break;
                case 4:
                    if (is_last_stage) {
                        hg::FighterInfo* f = new hg::FighterInfo();
                        enemyList.push_back(f);
                        hg::UserData::sharedUserData()->setDefaultInfo(f, 3300);
                        spawnData[group_id].push_back(f);
                    }
                    break;
                case 5:
                    if (is_last_stage) {
                        {
                            // fake boss
                            hg::FighterInfo* f = new hg::FighterInfo();
                            enemyList.push_back(f);
                            hg::UserData::sharedUserData()->setDefaultInfo(f, 3400);
                            spawnData[group_id].push_back(f);
                        }
                        {
                            // true boss
                            spawnData.push_back(hg::SpawnGroup());
                            group_id++;
                            hg::FighterInfo* f = new hg::FighterInfo();
                            enemyList.push_back(f);
                            hg::UserData::sharedUserData()->setDefaultInfo(f, 3500);
                            spawnData[group_id].push_back(f);
                        }
                    }
                    break;
            }
            
            /*
             for (NSDictionary* d in dicEnemyList)
             {
             int tmpGroup = [[d valueForKey:@"group"] integerValue] - 1;
             hg::FighterInfo* f = new hg::FighterInfo();
             enemyList.push_back(f);
             int fighterType = [[d valueForKey:@"fighterType"] integerValue];
             hg::UserData::sharedUserData()->setDefaultInfo(f, fighterType);
             f->level = [[d valueForKey:@"level"] integerValue];
             if (tmpGroup >= spawnData.size())
                {
                    spawnData.push_back(hg::SpawnGroup());
                }
                spawnData[tmpGroup].push_back(f);
            }*/
            
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
                float base_sleep = 1.0/GAMEFPS;
                float sleep;
                isPlaying = true;
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
                            if (upCamera) {
                                hg::UserData::sharedUserData()->upCamera();
                                hg::setCameraZPostion(hg::UserData::sharedUserData()->getCameraPosition());
                            }
                            if (downCamera) {
                                hg::UserData::sharedUserData()->downCamera();
                                hg::setCameraZPostion(hg::UserData::sharedUserData()->getCameraPosition());
                            }
                            [_glview draw];
                            
                            // update life bar
                            dispatch_async(dispatch_get_main_queue()
                                           , ^{
                                               [self updateGauge];
                                           });
                            
                            if (hg::isGameEnd())
                            {
                                isPlaying = false;
                                NSLog(@"is game end");
                                // 終了処理
                                hg::UserData::sharedUserData()->initAfterBattle();
                                // 戦果集計
                                {
                                    using namespace hg;
                                    BattleResult br = getResult();
                                    UserData::sharedUserData()->setBattleResult(br);
                                    // データ保存
                                    UserData::sharedUserData()->saveData();
                                }
                                
                                // Fighter Infoのインスタンスを削除
                                for (hg::FighterList::iterator it = enemyList.begin(); it != enemyList.end(); ++it) {
                                    delete *it;
                                }
                                enemyList.clear();
                                
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
        float x = baseFrame.size.width;
        float y = baseFrame.size.height;
        // 発射ボタン
        {
            CGRect frame;
            frame.size.width = 100;
            frame.size.height = 100;
            x = x - frame.size.width - btnGap;
            y = y - frame.size.height - btnGap;
            frame.origin.x = x;
            frame.origin.y = y;
            
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
            x = x + DEPLOY_BTN_SIZE;
            y = y - btnGap - DEPLOY_BTN_SIZE;
            CGRect frame;
            frame.size.width = DEPLOY_BTN_SIZE;
            frame.size.height = DEPLOY_BTN_SIZE;
            frame.origin.x = x;
            frame.origin.y = y;
            
            ImageButtonView* backImgView = [[[ImageButtonView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)] autorelease];
            //UIImage* img = [UIImage imageNamed:@"checkmark.png"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Icon.1_04" ofType:@"png"];
            UIImage* img = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
            
            [backImgView setBackgroundColor:[UIColor whiteColor]];
            [backImgView setFrame:frame];
            [backImgView.layer setCornerRadius:8];
            [backImgView.layer setBorderColor:[UIColor colorWithHexString:@"#ffffff"].CGColor];
            [backImgView.layer setBorderWidth:0.5];
            
            [backImgView setImage:img];
            [backImgView setContentMode:UIViewContentModeScaleAspectFit];
            [backImgView setUserInteractionEnabled:YES];
            
            [baseView addSubview:backImgView];
            
            [backImgView setOnTapAction:^(ImageButtonView *target) {
                if (!isPlaying || !hg::isControllable()) return;
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
        
        // retreat
        {
            y = y - btnGap - DEPLOY_BTN_SIZE;
            CGRect frame;
            frame.size.width = DEPLOY_BTN_SIZE;
            frame.size.height = DEPLOY_BTN_SIZE;
            frame.origin.x = x;
            frame.origin.y = y;
            
            ImageButtonView* backImgView = [[ImageButtonView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
            //UIImage* img = [UIImage imageNamed:@"checkmark.png"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Icon.4_33" ofType:@"png"];
            UIImage* img = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
            
            [backImgView setBackgroundColor:[UIColor whiteColor]];
            [backImgView setFrame:frame];
            [backImgView.layer setCornerRadius:8];
            [backImgView.layer setBorderColor:[UIColor colorWithHexString:@"#ffffff"].CGColor];
            [backImgView.layer setBorderWidth:0.5];
            
            [backImgView setImage:img];
            [backImgView setContentMode:UIViewContentModeScaleAspectFit];
            [backImgView setUserInteractionEnabled:YES];
            
            [baseView addSubview:backImgView];
            
            [backImgView setOnTapAction:^(ImageButtonView *target) {
                if (!isPlaying || !hg::isControllable()) return;
                hg::setPause(true);
                [baseCurtain setUserInteractionEnabled:true];
                [UIView animateWithDuration:0.2 animations:^{
                    [baseCurtain setBackgroundColor:[UIColor blackColor]];
                    [baseCurtain setAlpha:0.8];
                }];
                
                // 退却するか確認して退却
                DialogView* dialog = [[[DialogView alloc] initWithMessage:@"Are you sure to reatreat?"] autorelease];
                [dialog addButtonWithText:@"OK" withAction:^{
                    [UIView animateWithDuration:0.2 animations:^{
                        [baseCurtain setAlpha:0];
                        [baseCurtain setUserInteractionEnabled:false];
                    } completion:^(BOOL finished) {
                        hg::setPause(false);
                        // 退却
                        hg::retreat();
                    }];
                }];
                [dialog addButtonWithText:@"Cancel" withAction:^{
                    // animate
                    [UIView animateWithDuration:0.2 animations:^{
                        [baseCurtain setAlpha:0];
                        [baseCurtain setUserInteractionEnabled:false];
                    } completion:^(BOOL finished) {
                        hg::setPause(false);
                    }];
                }];
                [dialog setCancelAction:^{
                    // animate
                    [UIView animateWithDuration:0.2 animations:^{
                        [baseCurtain setAlpha:0];
                        [baseCurtain setUserInteractionEnabled:false];
                    } completion:^(BOOL finished) {
                        hg::setPause(false);
                    }];
                }];
                dialog.closeOnTapBackground = false;
                [dialog show];
                
            }];
        }
        
        // hp gauge
        {
            hpGaugeFrameRect = CGRectMake(10, 10, GAUGE_FRAME_WIDTH, GAUGE_FRAME_HEIGHT);
            hpGaugeRect = CGRectMake(10 + (GAUGE_FRAME_WIDTH - GAUGE_BAR_WIDTH)/2, 10 + (GAUGE_FRAME_HEIGHT - GAUGE_BAR_HEIGHT)/2, GAUGE_BAR_WIDTH, GAUGE_BAR_HEIGHT);
            UIView* gaugeFrame = [[[UIView alloc] initWithFrame:hpGaugeFrameRect] autorelease];
            [gaugeFrame setBackgroundColor:[UIColor clearColor]];
            [gaugeFrame.layer setBorderColor:[UIColor whiteColor].CGColor];
            [gaugeFrame.layer setBorderWidth:2];
            [gaugeFrame.layer setCornerRadius:GAUGE_FRAME_WIDTH/2];
            [baseView addSubview:gaugeFrame];
            
            hpGaugeBar = [[[UIView alloc] initWithFrame:hpGaugeRect] autorelease];
            [hpGaugeBar setBackgroundColor:[UIColor greenColor]];
            [hpGaugeBar.layer setBorderWidth:0];
            [hpGaugeBar.layer setCornerRadius:GAUGE_BAR_WIDTH/2];
            [baseView addSubview:hpGaugeBar];
        }
        
        // shield gauge
        if (hg::UserData::sharedUserData()->getPlayerInfo()->shieldMax > 0) {
            shieldGaugeFrameRect = CGRectMake(10 + GAUGE_FRAME_WIDTH + 2, 10, GAUGE_FRAME_WIDTH, GAUGE_FRAME_HEIGHT);
            shieldGaugeRect = CGRectMake(10 + GAUGE_FRAME_WIDTH + 2 + (GAUGE_FRAME_WIDTH - GAUGE_BAR_WIDTH)/2, 10 + (GAUGE_FRAME_HEIGHT - GAUGE_BAR_HEIGHT)/2, GAUGE_BAR_WIDTH, GAUGE_BAR_HEIGHT);
            UIView* gaugeFrame = [[[UIView alloc] initWithFrame:shieldGaugeFrameRect] autorelease];
            [gaugeFrame setBackgroundColor:[UIColor clearColor]];
            [gaugeFrame.layer setBorderColor:[UIColor whiteColor].CGColor];
            [gaugeFrame.layer setBorderWidth:2];
            [gaugeFrame.layer setCornerRadius:GAUGE_FRAME_WIDTH/2];
            [baseView addSubview:gaugeFrame];
            
            shieldGaugeBar = [[[UIView alloc] initWithFrame:shieldGaugeRect] autorelease];
            [shieldGaugeBar setBackgroundColor:[UIColor blueColor]];
            [shieldGaugeBar.layer setBorderWidth:0];
            [shieldGaugeBar.layer setCornerRadius:GAUGE_BAR_WIDTH/2];
            [baseView addSubview:shieldGaugeBar];
        } else {
            shieldGaugeBar = nil;
        }
        
        // curtain
        {
            baseCurtain = [[UIView alloc] initWithFrame:baseFrame];
            [self addSubview:baseCurtain];
            [baseCurtain setUserInteractionEnabled:false];
        }
        
        //////////////////////////////////////////////////
        // left
        //////////////////////////////////////////////////
        
        float lbtnGap = 12;
        float lx = 10;
        float ly = baseFrame.size.height;
        
        // down camera
        {
            ly = ly - lbtnGap - CAMERA_ADJUST_BTN_SIZE;
            CGRect frame;
            frame.size.width = CAMERA_ADJUST_BTN_SIZE;
            frame.size.height = CAMERA_ADJUST_BTN_SIZE;
            frame.origin.x = lx;
            frame.origin.y = ly;
            
            ImageButtonView* backImgView = [[ImageButtonView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
            //UIImage* img = [UIImage imageNamed:@"checkmark.png"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"ic_up" ofType:@"png"];
            UIImage* img = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
            
            [backImgView setBackgroundColor:[UIColor whiteColor]];
            [backImgView setFrame:frame];
            [backImgView.layer setCornerRadius:8];
            [backImgView.layer setBorderColor:[UIColor colorWithHexString:@"#ffffff"].CGColor];
            [backImgView.layer setBorderWidth:0.5];
            
            [backImgView setImage:img];
            [backImgView setContentMode:UIViewContentModeScaleAspectFit];
            [backImgView setUserInteractionEnabled:YES];
            
            [baseView addSubview:backImgView];
            
            [backImgView setOnToutchBegan:^(ImageButtonView *target) {
                downCamera = true;
            }];
            [backImgView setOnToutchEnd:^(ImageButtonView *target) {
                downCamera = false;
            }];
        }
        
        // up camera
        {
            ly = ly - lbtnGap - CAMERA_ADJUST_BTN_SIZE;
            CGRect frame;
            frame.size.width = CAMERA_ADJUST_BTN_SIZE;
            frame.size.height = CAMERA_ADJUST_BTN_SIZE;
            frame.origin.x = lx;
            frame.origin.y = ly;
            
            ImageButtonView* backImgView = [[ImageButtonView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
            //UIImage* img = [UIImage imageNamed:@"checkmark.png"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"ic_down" ofType:@"png"];
            UIImage* img = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
            
            [backImgView setBackgroundColor:[UIColor whiteColor]];
            [backImgView setFrame:frame];
            [backImgView.layer setCornerRadius:8];
            [backImgView.layer setBorderColor:[UIColor colorWithHexString:@"#ffffff"].CGColor];
            [backImgView.layer setBorderWidth:0.5];
            
            [backImgView setImage:img];
            [backImgView setContentMode:UIViewContentModeScaleAspectFit];
            [backImgView setUserInteractionEnabled:YES];
            
            [baseView addSubview:backImgView];
            
            [backImgView setOnToutchBegan:^(ImageButtonView *target) {
                upCamera = true;
            }];
            [backImgView setOnToutchEnd:^(ImageButtonView *target) {
                upCamera = false;
            }];
        }
        
        // deploy all
        {
            ly = ly - lbtnGap - CAMERA_ADJUST_BTN_SIZE;
            CGRect frame;
            frame.size.width = CAMERA_ADJUST_BTN_SIZE;
            frame.size.height = CAMERA_ADJUST_BTN_SIZE;
            frame.origin.x = lx;
            frame.origin.y = ly;
            
            ImageButtonView* backImgView = [[ImageButtonView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
            //UIImage* img = [UIImage imageNamed:@"checkmark.png"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"Icon.1_51" ofType:@"png"];
            UIImage* img = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
            
            [backImgView setBackgroundColor:[UIColor whiteColor]];
            [backImgView setFrame:frame];
            [backImgView.layer setCornerRadius:8];
            [backImgView.layer setBorderColor:[UIColor colorWithHexString:@"#ffffff"].CGColor];
            [backImgView.layer setBorderWidth:0.5];
            
            [backImgView setImage:img];
            [backImgView setContentMode:UIViewContentModeScaleAspectFit];
            [backImgView setUserInteractionEnabled:YES];
            backImgView.tag = 0;
            
            [baseView addSubview:backImgView];
            
            [backImgView setOnTapAction:^(ImageButtonView *target) {
                if (!isPlaying || !hg::isControllable()) return;
                hg::FighterList list = hg::UserData::sharedUserData()->getReadyList();
                for (hg::FighterList::iterator it = list.begin(); it != list.end(); ++it) {
                    hg::FighterInfo* info = *it;
                    if (backImgView.tag == 0 ) {
                        if (!info->isOnBattleGround && !info->isPlayer && info->life > 0) {
                            info->isOnBattleGround = true;
                        }
                        NSString *path = [[NSBundle mainBundle] pathForResource:@"Icon.1_51_2" ofType:@"png"];
                        UIImage* img = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
                        [backImgView setImage:img];
                        backImgView.tag = 1;
                    } else {
                        if (!info->isOnBattleGround && !info->isPlayer && info->life > 0) {
                            info->isOnBattleGround = false;
                        }
                        NSString *path = [[NSBundle mainBundle] pathForResource:@"Icon.1_51" ofType:@"png"];
                        UIImage* img = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
                        [backImgView setImage:img];
                        backImgView.tag = 0;
                    }
                }
                hg::deployFriends();
            }];
        }
        
        [[OALSimpleAudio sharedInstance] playBg:BGM_BATTLE loop:true];
        
    }
    
}

- (void)updateGauge
{
    if (hpGaugeBar) {
        float lifeRatio = hg::getHPRatio();
        CGRect r = hpGaugeRect;
        r.size.height = lifeRatio * r.size.height;
        r.origin.y = hpGaugeRect.origin.y + (hpGaugeRect.size.height - r.size.height);
        [hpGaugeBar setFrame:r];
        if (lifeRatio <= 0.3) {
            [hpGaugeBar setBackgroundColor:[UIColor redColor]];
        } else if (lifeRatio <= 0.5) {
            [hpGaugeBar setBackgroundColor:[UIColor yellowColor]];
        } else {
            [hpGaugeBar setBackgroundColor:[UIColor greenColor]];
        }
    }
    if (shieldGaugeBar) {
        float lifeRatio = hg::getShieldRatio();
        CGRect r = shieldGaugeRect;
        r.size.height = lifeRatio * r.size.height;
        r.origin.y = shieldGaugeRect.origin.y + (shieldGaugeRect.size.height - r.size.height);
        [shieldGaugeBar setFrame:r];
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
