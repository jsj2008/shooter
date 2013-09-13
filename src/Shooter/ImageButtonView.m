//
//  ImageButtonView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/22.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "Common.h"
#import "ImageButtonView.h"
#import "ObjectAL.h"

@interface ImageButtonView()
{
    UIView* highlightView;
    void (^onTap)(ImageButtonView* target);
    void (^onTouchBegan)(ImageButtonView* target);
    void (^onTouchEnd)(ImageButtonView* target);
}
@end

@implementation ImageButtonView

- (id)init
{
    self = [super init];
    if (self)
    {
        onTouchBegan = nil;
        onTouchEnd = nil;
        {
            // highlight タッチされたときのハイライト用
            CGRect f = self.frame;
            f.origin.x = 0; f.origin.y = 0;
            highlightView = [[UIView alloc] initWithFrame:f];
            [highlightView setBackgroundColor:[UIColor whiteColor]];
            [highlightView setAlpha:0];
            [highlightView setUserInteractionEnabled:NO];
            [self addSubview:highlightView];
        }
    }
    return self;
}


- (void)setOnTapAction:(void(^)(ImageButtonView* target)) _onTap
{
    onTap = [_onTap copy];
    // touch
    {
        UITapGestureRecognizer *tr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [self addGestureRecognizer:tr];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    __weak ImageButtonView* self_ = self;
    __weak UIView* hv_ = highlightView;
#if IS_BUTTON_ANIME
    [UIView animateWithDuration:0.17 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(0.8, 0.8);
        [self_ setTransform:t];
        [hv_ setAlpha:0.3];
    } completion:^(BOOL finished) {
    }];
#endif
    if (onTouchBegan) {
        onTouchBegan(self_);
    }
}


- (void)setOnToutchBegan:(void(^)(ImageButtonView* target)) _callback
{
    onTouchBegan = [_callback copy];
}

- (void)setOnToutchEnd:(void(^)(ImageButtonView* target)) _callback
{
    onTouchEnd = [_callback copy];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [highlightView setAlpha:0];
    __weak ImageButtonView* self_ = self;
#if IS_BUTTON_ANIME
    [UIView animateWithDuration:0.20 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
        [self_ setTransform:t];
    } completion:^(BOOL finished) {
    }];
#endif
    if (onTouchEnd) {
        onTouchEnd(self);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [highlightView setAlpha:0];
    __weak ImageButtonView* self_ = self;
#if IS_BUTTON_ANIME
    [UIView animateWithDuration:0.20 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
        [self_ setTransform:t];
    } completion:^(BOOL finished) {
    }];
#endif
    if (onTouchEnd) {
        onTouchEnd(self);
    }
}

- (void)onTap2
{
    __weak ImageButtonView* self_ = self;
    [UIView animateWithDuration:0.10 animations:^{
        [self_ setTransform:CGAffineTransformIdentity];
    } completion:^(BOOL finished) {
        onTap(self_);
    }];
    
}

- (void)onTap:(UIGestureRecognizer*)sender
{
    [[OALSimpleAudio sharedInstance] playEffect:SE_CLICK];
    // 拡大アニメーションさせるので、トップに持ってくる
    [highlightView setAlpha:0];
    //[self.superview bringSubviewToFront:self];
    
    __weak ImageButtonView* self_ = self;
#if IS_BUTTON_ANIME
    [UIView animateWithDuration:0.10 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.1, 1.1);
        [self_ setTransform:t];
    } completion:^(BOOL finished) {
        [self_ onTap2];
    }];
#else
    onTap(self_);
#endif
    
    /*
     // callback
     dispatch_async(dispatch_get_main_queue(), ^{
     onTap(self);
     });*/
}


/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end

