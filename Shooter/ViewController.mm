//
//  ViewController.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "ViewController.h"
#import "HGLView.h"
#import "HGLObject3D.h"
#import "HGLObjLoader.h"
#import "HGLVector3.h"
#import "HGActor.h"
#import "PadView.h"
#import "TouchHandlerView.h"
#import <vector>

// game define
#define ENEMY_NUM 3

@interface ViewController()
{
    
HGLView* _glview;
HGLObject3D* _playerObj3d;
HGLObject3D* _enemyObj3d;
HGLVector3 _cameraPosition;
    
HGActor* _player;
std::vector<HGActor*> _enemies;
    
dispatch_queue_t _game_queue;
    
PadView* _leftPadView;
PadView* _rightPadView;
    
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
    // エンティティ作成
    _playerObj3d = HGLObjLoader::load(@"floor");
    _player = new HGActor();
    _player->object3d = _playerObj3d;
    _player->position.set(0, 0, 0);
    _player->setAspect(0);
    //_player->setVelocity(0.1);
    
    _enemyObj3d = HGLObjLoader::load(@"droid");
    for (int i = 0; i < ENEMY_NUM; i++)
    {
        HGActor* t = new HGActor();
        t->object3d = _enemyObj3d;
        t->position.x = (i*2) + -2;
        t->position.y = 1;
        t->setAspect(90);
        t->setVelocity(0.05);
        _enemies.push_back(t);
    }
    _cameraPosition = HGLVector3(0,0,-15);
    
    // ゲームスレッド作成
    _game_queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
    dispatch_async(_game_queue, ^{
        while (1)
        {
            [self game_main];
            [NSThread sleepForTimeInterval:0.05f];
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
            // タッチ
            //NSLog(@"touch degree:%d pow:%f", degree, power);
            // プレイヤーを動かす
            _player->setAspect(degree);
            _player->setVelocity(0.8*power);
            
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
            // タッチ
            //NSLog(@"touch degree:%d pow:%f", degree, power);
        }] autorelease];
        [_glview addSubview:_rightPadView];
    }
    
    /*
    // タッチハンドラ
    TouchHandlerView* handlerView = [[[TouchHandlerView alloc] initWithHandler:^UIView *(CGPoint point, UIEvent *event) {
        if (_leftPadView && [_leftPadView pointInside:point withEvent:event]) {
            return _leftPadView;
        }
        if (_rightPadView && [_rightPadView pointInside:point withEvent:event]) {
            return _rightPadView;
        }
        return nil;
    }] autorelease];
    [_glview addSubview:handlerView];*/
    
}

// メイン処理
- (void)game_main
{
    _player->move();
    for (std::vector<HGActor*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
    {
        HGActor* a = *itr;
        a->move();
    }
}


// 描画処理
- (void)render
{
    [_glview setCamera:&_cameraPosition];
    _player->draw();
    for (std::vector<HGActor*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
    {
        HGActor* a = *itr;
        a->draw();
    }
}


@end
