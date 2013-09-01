//
//  ImageButtonView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/22.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "MenuButton.h"
#import "UIColor+MyCategory.h"
#import "Common.h"
#import "ObjectAL.h"

@interface MenuButton()
{
    UIView* highlightView;
    UILabel* label;
    void (^onTap)(MenuButton* target);
}
@end

@implementation MenuButton

- (void)dealloc
{
    if (onTap)[onTap release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        CGRect frm = frame;
        //MenuButton* m = [[[MenuButton alloc] initWithFrame:frm] autorelease];
        MenuButton* m = self;
        [self setBackgroundColor:[UIColor colorWithHexString:@"#aaccff"]];
        // label
        {
            UILabel * l = [[[UILabel alloc] init] autorelease];
            UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:17];
            [l setFont:font];
            [l setTextColor:MAIN_FONT_COLOR];
            [l setText:@"Battle"];
            [l setTextAlignment:NSTextAlignmentCenter];
            [l setFrame:CGRectMake(0, 0, frm.size.width, frm.size.height)];
            [l setBackgroundColor:[UIColor clearColor]];
            label = l;
            [m addSubview:l];
        }
        // design
        {
            [m.layer setBorderColor:MAIN_BORDER_COLOR.CGColor];
            [m.layer setBorderWidth:2];
            //[m.layer setBackgroundColor:[UIColor colorWithHexString:@"#343488"].CGColor];
            [m.layer setBackgroundColor:[UIColor clearColor].CGColor];
            //[m setAlpha:0.6];
        }
    }
    return self;
}

- (void)setText:(NSString*)text
{
    [label setText:text];
}

- (void)setColor:(UIColor*)color
{
    [label setTextColor:color];
    [self.layer setBorderColor:color.CGColor];
}

- (void)setOnTapAction:(void(^)(MenuButton* target)) _onTap
{
    onTap = [_onTap copy];
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
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [highlightView setAlpha:0];
    [UIView animateWithDuration:0.20 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
        [self setTransform:t];
    } completion:^(BOOL finished) {
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [highlightView setAlpha:0];
    [UIView animateWithDuration:0.20 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
        [self setTransform:t];
    } completion:^(BOOL finished) {
    }];
}


- (void)onTap:(UIGestureRecognizer*)sender
{
    [[OALSimpleAudio sharedInstance] playEffect:SE_CLICK];
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
    onTap(self);
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
