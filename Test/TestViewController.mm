//
//  ViewController.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "TestViewController.h"
#import "HGLView.h"
#import "HGUtil.h"
#import "HGLObject3D.h"
#import "HGLObjLoader.h"
#import "HGLVector3.h"
#import "HGActor.h"
#import "HGFighter.h"
#import "HGBullet.h"
#import "HGObject.h"
#import "PadView.h"
#import "TouchHandlerView.h"
#import <vector>
#import "Common.h"

#define ZPOS -7

@interface TestViewController()
{
    
    HGLView* _glview;
    HGLVector3 _cameraPosition;
    
    // flag
    bool fire;
    NSTimeInterval lastFireTime;
    float fireAspect;
    
    // game objects
    HGFighter* _player;
    
    std::vector<HGBullet*> _bullets;
    std::vector<HGBullet*> _bulletsInActive;
    std::vector<HGFighter*> _enemies;
    std::vector<HGObject*> _background;
    //std::vector<HGObject*> _background2;
    
    HGLObject3D* skybox;
    
    // game's main thread
    dispatch_queue_t _game_queue;
    
    // UI
    PadView* _leftPadView;
    PadView* _rightPadView;
    
    
#warning 弾用のZ軸変数
    
}
@end

@implementation TestViewController

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
    HGLoadData();
    
    // skybox
    /*
    skybox = HGLObjLoader::load(@"sphere");
    skybox->getMesh(0)->texture = HGLTexture::createTextureWithAsset("space2.png");
    skybox->useLight = 0;
    skybox->scale.set(80, 80, 80);
    skybox->rotate.set(-90*M_PI/180, 0, 0);
     */
    
    // create players
    _player = new HGFighter();
    _player->init(HG_FIGHTER_N1);
    _player->position.set(0, 0, ZPOS);
    _player->setAspect(0);
    fire = false;
    
    // create enemies
    for (int i = 0; i < ENEMY_NUM; ++i)
    {
        HGFighter* t;
        t = new HGFighter();
        t->init(HG_FIGHTER_N1);
        t->position.x = (i*2) + -2;
        t->position.y = 1;
        t->position.z = ZPOS;
        t->setAspect(90);
        t->setMoveAspect(90);
        t->setVelocity(0.05);
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
#define SKYBOX_SCALE 2
    for (int i = 3; i < 3; ++i)
    {
        HGObject* t = new HGObject();
        t->init(HG_OBJECT_SPACE1);
        t->scale.set(SKYBOX_SCALE, SKYBOX_SCALE, SKYBOX_SCALE);
        switch (i) {
            case 0:
                t->anime1.texture = *HGLTexture::createTextureWithAsset("galaxy-X.png");
                t->position.set(-1*SKYBOX_SCALE/2, 0, ZPOS);
                t->rotate.set(0, 90*M_PI/180, 0);
                break;
            case 1:
                t->anime1.texture = *HGLTexture::createTextureWithAsset("galaxy+X.png");
                t->position.set(SKYBOX_SCALE/2, 0, ZPOS);
                t->rotate.set(0, -90*M_PI/180, 0);
                break;
            case 2:
                t->anime1.texture = *HGLTexture::createTextureWithAsset("galaxy-Y.png");
                t->position.set(0, 0, ZPOS);
                //t->rotate.set(90*M_PI/180, 0, 0);
            case 3:
                //
                t->anime1.texture = *HGLTexture::createTextureWithAsset("galaxy+Y.png");
                t->position.set(0, SKYBOX_SCALE/2, ZPOS);
                t->rotate.set(-90*M_PI/180, 0, 0);
            case 4:
                t->anime1.texture = *HGLTexture::createTextureWithAsset("galaxy-Z.png");
                t->position.set(0, 0, -1*SKYBOX_SCALE/2 + ZPOS);
                //t->rotate.set(-90*M_PI/180, 0, 0);
            case 5:
                t->anime1.texture = *HGLTexture::createTextureWithAsset("galaxy+Z.png");
                t->position.set(0, 0, 1*SKYBOX_SCALE/2 + ZPOS);
                //t->rotate.set(90*M_PI/180, 0, 0);
                break;
            default:
                break;
        }
        _background.push_back(t);
    }
    
    /*
    for (int i = 0; i < 5; ++i)
    {
        for (int j = 0; j < 5; ++j)
        {
            HGObject* t = new HGObject();
            t->init(HG_OBJECT_SPACE1);
            t->scale.set(100, 100, 100);
            t->position.set(i * 100 - 250, j * 100 - 250, -70);
            _background.push_back(t);
        }
    }*/
    
    // create background2
    /*
    for (int i = 0; i < 5; ++i)
    {
        for (int j = 0; j < 5; ++j)
        {
            HGObject* t = new HGObject();
            t->init(HG_OBJECT_SPACE1);
            t->scale.set(100, 100, 100);
            t->position.set(i * 100 - 250, j * 100 - 250, -70);
            _background2.push_back(t);
        }
    }*/
    
    // camera
    _cameraPosition = HGLVector3(0,0,0);
    
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
            [self game_main];
            nowDt = [NSDate date];
            end = [nowDt timeIntervalSince1970];
            sleep = base_sleep - (end - start);
            //LOG(@"%ld:%f", _bullets.size(), sleep);
            if (sleep > 0)
            {
                [NSThread sleepForTimeInterval:sleep];
            }
            
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
            _player->setVelocity(0.4*power);
            
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
    fireAspect = _player->aspect;
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
    if (now - lastFireTime < 0.1) return;
    lastFireTime = now;
    if (_bulletsInActive.size() == 0) return;
    HGBullet* t = _bulletsInActive.back();
    t->position.x = _player->position.x;
    t->position.y = _player->position.y;
    t->position.z = _player->position.z;
    t->setMoveAspect(fireAspect);
    
    if (0)
    {
        t->init(HG_BULLET_N2);
    }
    else
    {
        t->init(HG_BULLET_N1);
    }
    _bulletsInActive.pop_back();
    _bullets.push_back(t);
    
}

// メイン処理
- (void)game_main
{
    @synchronized(self)
    {
        _player->update();
        
        [self fire];
        
        // カメラ位置
        _cameraPosition.x = _player->position.x * -1;
        //_cameraPosition.y = _player->position.y * -1 + 5.5;
        _cameraPosition.y = _player->position.y * -1;
        _cameraPosition.z = 0;
    }
    
    // move bg
    //skybox->rotate.x += 0.003;
    //skybox->rotate.y += 0.002;
    //skybox->rotate.z += 0.001;
    for (std::vector<HGObject*>::reverse_iterator itr = _background.rbegin(); itr != _background.rend(); ++itr)
    {
        HGObject* a = *itr;
        //a->rotate.x += 0.01;
        a->update();
    }
    /*
    for (std::vector<HGObject*>::reverse_iterator itr = _background2.rbegin(); itr != _background2.rend(); ++itr)
    {
        HGObject* a = *itr;
        a->update();
    }*/
    
    // move enemies
    for (std::vector<HGFighter*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
    {
        HGFighter* a = *itr;
        a->update();
    }
    
    // move bullets
    for (std::vector<HGBullet*>::iterator itr = _bullets.begin(); itr != _bullets.end(); ++itr)
    {
        HGBullet* a = *itr;
        a->update();
    }
    
    // enemy with bullet
    for (std::vector<HGFighter*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
    {
        HGFighter* a = *itr;
        for (std::vector<HGBullet*>::iterator itr2 = _bullets.begin(); itr2 != _bullets.end(); ++itr2)
        {
            HGBullet* b = *itr2;
            if (a->isCollideWith(b))
            {
                NSLog(@"hit");
            }
        }
        
    }
    
    // 描画
    [_glview draw];
}


// 描画処理
static HGLVector3 testRotate;
- (void)render
{
    @synchronized(self)
    {
        glDisable(GL_DEPTH_TEST); // 2D Gameではスプライトの重なりができなくなるのでOFF
        //_glview.cameraRotate = HGLVector3(-22 * M_PI/180, 0, 0);
        //test
        /*
        if (1)
        {
            testRotate.x += 0.1;
            //testRotate.y += 0.15;
            //testRotate.z += 0.2;
            _glview.cameraRotate = testRotate;
            _cameraPosition.z = -20;
        }*/
        
        _glview.cameraPosition = HGLVector3(0,0,-1);
        //_glview.cameraRotate = HGLVector3(0,0,-1);
        [_glview updateCamera];
        
        //skybox->draw();
        //skybox->position = _player->position;
        
        // draw bg
        for (std::vector<HGObject*>::reverse_iterator itr = _background.rbegin(); itr != _background.rend(); ++itr)
        {
            HGObject* a = *itr;
            a->rotate.y += 0.04;
            a->draw();
        }
        // draw bg
        /*
        for (std::vector<HGObject*>::reverse_iterator itr = _background.rbegin(); itr != _background.rend(); ++itr)
        {
            HGObject* a = *itr;
            a->draw();
        }*/
        /*
        for (std::vector<HGObject*>::reverse_iterator itr = _background2.rbegin(); itr != _background2.rend(); ++itr)
        {
            HGObject* a = *itr;
            a->draw();
        }*/
        
        // draw enemies
        for (std::vector<HGFighter*>::reverse_iterator itr = _enemies.rbegin(); itr != _enemies.rend(); ++itr)
        {
            HGFighter* a = *itr;
            a->draw();
#if IS_DEBUG_COLLISION
            a->drawCollision();
#endif
        }
        
        // draw bullets
        for (std::vector<HGBullet*>::reverse_iterator itr = _bullets.rbegin(); itr != _bullets.rend(); ++itr)
        {
            HGBullet* a = *itr;
            a->draw();
#if IS_DEBUG_COLLISION
            a->drawCollision();
#endif
        }
    
        // draw player
        _player->draw();
#if IS_DEBUG_COLLISION
            _player->drawCollision();
#endif
    }
}


@end
