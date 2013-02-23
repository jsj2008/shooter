//
//  ViewController.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "ViewController.h"
#import "HGLView.h"
#import "HGUtil.h"
#import "HGLObject3D.h"
#import "HGLObjLoader.h"
#import "HGLVector3.h"
#import "HGActor.h"
#import "HGFighter.h"
#import "PadView.h"
#import "TouchHandlerView.h"
#import <vector>

// game define
#define ENEMY_NUM 20
#define ZPOS_DIFF 0.1 // Z軸上でずらす量
#define FPS 40

@interface ViewController()
{
    
    HGLView* _glview;
    HGLObject3D* _baseRectObj3d;
    HGLObject3D* _droidObj3d;
    HGLTexture* _e_robo2Tex;
    //HGLObject3D* _playerObj3d;
    //HGLObject3D* _enemyObj3d;
    //HGLTexture* _playerTexture;
    
    HGLVector3 _cameraPosition;
    
    HGActor* _player;
    std::vector<HGActor*> _enemies;
    
    dispatch_queue_t _game_queue;
    
    PadView* _leftPadView;
    PadView* _rightPadView;
    
    // 視点行列
    GLKMatrix4 _viewMatrix;
    
    // 描画順を制御する
    float _fighterZ; // 機体用
    
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
    // 3d描画用ビューを初期化
    // 最初にこれを行う必要がある
    CGRect frame = [[UIScreen mainScreen] bounds];
    _glview = [[HGLView alloc] initWithFrame:frame WithRenderBlock:^{
        [self render];
    }];
    self.view = _glview;
    
    _leftPadView = nil;
    _rightPadView = nil;
    
    [self setupGame];
    
    [_glview start];
}

- (void)setupGame
{
#warning 後でdelete
    // ユーティリティ初期化
    initSpriteIndexTable();
    
    // 素材ロード
    _baseRectObj3d = HGLObjLoader::load(@"rect");
    
    // エンティティ作成
    _e_robo2Tex = HGLTexture::createTextureWithAsset("e_robo2.png");
    _player = new HGFighter();
    _player->setObject3D(_baseRectObj3d, _e_robo2Tex);
    _player->position.set(0, 0, 0);
    _player->setAspect(0);
    _fighterZ -= ZPOS_DIFF;
    
    _droidObj3d = HGLObjLoader::load(@"droid");
    for (int i = 0; i < ENEMY_NUM; i++)
    {
        HGActor* t;
        //if (i == 0)
        if (i % 2 == 0)
        {
            t = new HGFighter();
            t->setObject3D(_baseRectObj3d, _e_robo2Tex);
        }
        else
        {
            t = new HGActor();
            t->setObject3D(_droidObj3d);
            t->rotate.x = 45;
        }
        t->position.x = (i*2) + -2;
        t->position.y = 1;
        t->position.z = _fighterZ;
        t->setAspect(90);
        t->setVelocity(0.05);
        _fighterZ -= ZPOS_DIFF;
        _enemies.push_back(t);
    }
    _cameraPosition = HGLVector3(0,0,-20);
    
    // ゲームスレッド作成
    _game_queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
    dispatch_async(_game_queue, ^{
        while (1)
        {
            [self game_main];
#warning 処理落ち対策
            [NSThread sleepForTimeInterval:(1.0/FPS)];
        }
    });
    
    // タッチイベント(左)
    {
        CGRect winframe = [UIScreen mainScreen].bounds;
        CGRect frame = winframe;
        frame.size.width = 110;
        frame.size.height = 110;
        frame.origin.x = 0;
        frame.origin.y = winframe.size.height - frame.size.height;
        _leftPadView = [[[PadView alloc] initWithFrame:frame WithOnTouchBlock:^(int degree, float power) {
            // プレイヤーを動かす
            if (power > 0)
            {
                _player->setAspect(degree);
            }
            _player->setVelocity(0.6*power);
            
        }] autorelease];
        [_glview addSubview:_leftPadView];
    }
    
    // タッチイベント(右)
    {
        CGRect winframe = [UIScreen mainScreen].bounds;
        CGRect frame = winframe;
        frame.size.width = 110;
        frame.size.height = 110;
        frame.origin.x = winframe.size.width - frame.size.width;
        frame.origin.y = winframe.size.height - frame.size.height;
        _rightPadView = [[[PadView alloc] initWithFrame:frame WithOnTouchBlock:^(int degree, float power) {
#warning TODO
        }] autorelease];
        [_glview addSubview:_rightPadView];
    }
    
}

// メイン処理
- (void)game_main
{
    @synchronized(self)
    {
        _player->move();
        for (std::vector<HGActor*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
        {
            HGActor* a = *itr;
            a->move();
        }
        // カメラ位置
        _cameraPosition.x = _player->position.x * -1;
        _cameraPosition.y = _player->position.y * -1 + 4.5;
        // 描画
        [_glview draw];
    }
}


// 描画処理
- (void)render
{
    @synchronized(self)
    {
        _glview.cameraRotateRadian = -15 * M_PI/180;
        _glview.cameraRotate = HGLVector3(1, 0, 0);
        _glview.cameraPosition = _cameraPosition;
        [_glview updateCamera];
        
        for (std::vector<HGActor*>::reverse_iterator itr = _enemies.rbegin(); itr != _enemies.rend(); ++itr)
        {
            HGActor* a = *itr;
            a->draw();
        }
        _player->draw();
    }
}


@end
