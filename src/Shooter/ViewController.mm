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
    
    // OpenGL
    HGLView* _glview;
    
    //HGGame::t_keystate keystate;
    hg::t_keyState keyState;
    
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
    
    // setup game
    //HGGame::initialize();
    hg::initialize();
    
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
                    hg::update(&keyState);
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
        frame.size.width = 110;
        frame.size.height = 110;
        frame.origin.x = 0;
        frame.origin.y = aframe.size.width - frame.size.height;
        _leftPadView = [[[PadView alloc] initWithFrame:frame WithOnTouchBlock:^(int degree, float power) {
            //HGGame::onMoveLeftPad(degree, power);
            hg::onMoveLeftPad(degree, power);
        }] autorelease];
        [_glview addSubview:_leftPadView];
    }
    
    // タッチイベント(右)
    {
        CGRect aframe = [UIScreen mainScreen].applicationFrame;
        CGRect frame = CGRectMake(0, 0, aframe.size.height, aframe.size.width);
        frame.size.width = 110;
        frame.size.height = 110;
        frame.origin.x = aframe.size.height - frame.size.width;
        frame.origin.y = aframe.size.width - frame.size.height;
        
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
    //keystate.fire = 1;
    keyState.fire = 1;
}

- (void) stopFire
{
    //keystate.fire = 0;
    keyState.fire = 0;
}


@end
