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
#import "HGBullet.h"
#import "PadView.h"
#import "TouchHandlerView.h"
#import <vector>

// game define
#define ENEMY_NUM 20
#define BULLET_NUM 2000
#define ZPOS_DIFF 0.1 // Z軸上でずらす量
#define FPS 20

@interface ViewController()
{
    
    HGLView* _glview;
    HGLObject3D* _baseRectObj3d;
    HGLObject3D* _droidObj3d;
#warning TODO: あとでテーブル化
    HGLTexture* _e_robo2Tex;
    HGLTexture* _waveringTex;
    HGLTexture* _spaceTex;
    
    HGLVector3 _cameraPosition;
    
    // flag
    bool fire;
    NSTimeInterval lastFireTime;
    float fireAspect;
    
    // game objects
    HGActor* _player;
    
    std::vector<HGBullet*> _bullets;
    std::vector<HGBullet*> _bulletsInActive;
    
    std::vector<HGActor*> _enemies;
    
    std::vector<HGActor*> _background;
    
    // game's main thread
    dispatch_queue_t _game_queue;
    
    // UI
    PadView* _leftPadView;
    PadView* _rightPadView;
    
    // 描画順を制御する
    float _fighterZ; // 機体用
#warning 弾用のZ軸変数
    
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
    // initialize utility program
    initSpriteIndexTable();
    
    // loading data
    _baseRectObj3d = HGLObjLoader::load(@"rect");
    //_droidObj3d = HGLObjLoader::load(@"droid");
    _e_robo2Tex = HGLTexture::createTextureWithAsset("e_robo2.png");
    _waveringTex = HGLTexture::createTextureWithAsset("divine.png");
    _waveringTex->useAsAlphaMap(true);
    _spaceTex = HGLTexture::createTextureWithAsset("space.png");
    
    // create players
    _player = new HGFighter();
    _player->setObject3D(_baseRectObj3d, _e_robo2Tex);
    _player->position.set(0, 0, 1);
    _player->setAspect(0);
    _fighterZ -= ZPOS_DIFF;
    fire = false;
    
    // create enemies
    _fighterZ = -0.5;
    for (int i = 0; i < ENEMY_NUM; ++i)
    {
        HGActor* t;
        if (1)
        //if (i % 2 == 0)
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
        t->setMoveAspect(90);
        t->setVelocity(0.05);
        _fighterZ += ZPOS_DIFF;
        if (_fighterZ >= 0)
        {
            _fighterZ = -0.5;
        }
        _enemies.push_back(t);
    }
    
    // create bullets
    for (int i = 0; i < BULLET_NUM; ++i)
    {
        HGBullet* t;
        //if (i == 0)
        t = new HGBullet();
        _bulletsInActive.push_back(t);
    }
    
    // create background
    for (int i = 0; i < 5; ++i)
    {
        for (int j = 0; j < 5; ++j)
        {
            HGActor* t = new HGActor();
            t->setObject3D(_baseRectObj3d, _spaceTex);
            t->scale.set(100, 100, 100);
            t->position.set(i * 100 - 250, j * 100 - 250, -1);
            t->textureRepeatNum = 10;
            _background.push_back(t);
        }
    }
    
    // camera
    _cameraPosition = HGLVector3(0,0,-30);
    
    // creating game thread
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
                if (!fire) _player->setAspect(degree);
                _player->setMoveAspect(degree);
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
        
        UIButton* fireBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        fireBtn.frame = frame;
        [fireBtn setTitle:@"Fire" forState:UIControlStateNormal];
        [fireBtn addTarget:self action:@selector(startFire) forControlEvents:UIControlEventTouchDown];
        [fireBtn addTarget:self action:@selector(stopFire) forControlEvents:UIControlEventTouchUpInside];
        [fireBtn addTarget:self action:@selector(stopFire) forControlEvents:UIControlEventTouchUpOutside];
        
        [_glview addSubview:fireBtn];
    }
    
}

- (void) startFire
{
    fire = true;
    fireAspect = _player->aspect * 180/M_PI;
}

- (void) stopFire
{
    fire = false;
}

- (void) fire
{
    if (!fire) return;
    NSDate* nowDt = [NSDate date];
    NSTimeInterval now = [nowDt timeIntervalSince1970];
    if (now - lastFireTime < 0.3) return;
    lastFireTime = now;
    if (_bulletsInActive.size() == 0) return;
    HGBullet* t = _bulletsInActive.back();
    t->setObject3D(_baseRectObj3d, _waveringTex);
    t->position.x = _player->position.x;
    t->position.y = _player->position.y;
    t->position.z = 0.5;
    t->setMoveAspect(fireAspect);
    t->setVelocity(0.8);
    t->scale.set(0.5, 0.5, 0.5);
    t->color = {1.0, 1.0, 1.0};
    _bulletsInActive.pop_back();
    _bullets.push_back(t);
    
}

// メイン処理
- (void)game_main
{
    @synchronized(self)
    {
        _player->move();
        [self fire];
        
        // move enemies
        for (std::vector<HGActor*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
        {
            HGActor* a = *itr;
            a->move();
        }
        
        // move bullets
        for (std::vector<HGBullet*>::iterator itr = _bullets.begin(); itr != _bullets.end(); ++itr)
        {
            HGBullet* a = *itr;
            a->move();
        }
        
        // カメラ位置
        _cameraPosition.x = _player->position.x * -1;
        _cameraPosition.y = _player->position.y * -1 + 13.5;
        
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
        
        // draw bg
        for (std::vector<HGActor*>::reverse_iterator itr = _background.rbegin(); itr != _background.rend(); ++itr)
        {
            HGActor* a = *itr;
            a->draw();
        }
        
        // draw enemies
        for (std::vector<HGActor*>::reverse_iterator itr = _enemies.rbegin(); itr != _enemies.rend(); ++itr)
        {
            HGActor* a = *itr;
            a->draw();
        }
        
        // draw bullets
        for (std::vector<HGBullet*>::reverse_iterator itr = _bullets.rbegin(); itr != _bullets.rend(); ++itr)
        {
            HGActor* a = *itr;
            a->draw();
        }
        
        // draw player
        _player->draw();
        
    }
}


@end
