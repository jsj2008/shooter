//
//  ImageButtonView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/22.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "ImageButtonView.h"

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
            highlightView = [[[UIView alloc] initWithFrame:f] autorelease];
            [highlightView setBackgroundColor:[UIColor whiteColor]];
            [highlightView setAlpha:0];
            [highlightView setUserInteractionEnabled:NO];
            [self addSubview:highlightView];
        }
    }
    return self;
}

- (void)dealloc
{
    if (onTap)[onTap release];
    [super dealloc];
}

- (void)setOnTapAction:(void(^)(ImageButtonView* target)) _onTap
{
    onTap = [_onTap copy];
    // touch
    {
        UITapGestureRecognizer *tr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)] autorelease];
        [self addGestureRecognizer:tr];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [UIView animateWithDuration:0.17 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(0.8, 0.8);
        [self setTransform:t];
        [highlightView setAlpha:0.3];
    } completion:^(BOOL finished) {
    }];
    if (onTouchBegan) {
        onTouchBegan(self);
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
    [UIView animateWithDuration:0.20 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
        [self setTransform:t];
    } completion:^(BOOL finished) {
    }];
    if (onTouchEnd) {
        onTouchEnd(self);
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [highlightView setAlpha:0];
    [UIView animateWithDuration:0.20 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
        [self setTransform:t];
    } completion:^(BOOL finished) {
    }];
    if (onTouchEnd) {
        onTouchEnd(self);
    }
}

- (void)onTap:(UIGestureRecognizer*)sender
{
    // 拡大アニメーションさせるので、トップに持ってくる
    [highlightView setAlpha:0];
    [self.superview bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.10 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.1, 1.1);
        [self setTransform:t];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.10 animations:^{
            [self setTransform:CGAffineTransformIdentity];
        }];
    }];
    
    // callback
    dispatch_async(dispatch_get_main_queue(), ^{
        onTap(self);
    });
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
