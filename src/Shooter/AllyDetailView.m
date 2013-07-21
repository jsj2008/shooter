//
//  AllyDetailView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/07/21.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "AllyDetailView.h"

@interface AllyDetailView()
{
    hg::FighterInfo* _fighterInfo;
}
@property(assign)UIView* curtain;
@property(assign)UIView* baseView;
@end

@implementation AllyDetailView

- (id)initWithFighterInfo:(hg::FighterInfo*)fighterInfo
{
    self = [super init];
    if (self) {
        assert(fighterInfo != NULL);
        _fighterInfo = fighterInfo;
    }
    return self;
}

-(void)dealloc
{
    [_curtain release];
    [_baseView release];
    [super dealloc];
}

- (void)show
{
    // design
    [self setBackgroundColor:[UIColor clearColor]];
    
    // add subview
    UIView* rootView = [[UIApplication sharedApplication].keyWindow viewForBaselineLayout];
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(0, 0, screenFrame.size.height, screenFrame.size.width);
    
    [self setFrame:frame];
    [self setCenter:CGPointMake(frame.size.height/2, frame.size.width/2)];
    [rootView addSubview:self];
    
    // curtain
    {
        CGRect frm = CGRectMake(0, 0, frame.size.width, frame.size.height);
        UIView* curtain = [[UIView alloc] initWithFrame:frm];
        [curtain setBackgroundColor:[UIColor blackColor]];
        [curtain setAlpha:0.5];
        [self addSubview:curtain];
        UITapGestureRecognizer *tr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBackground:)] autorelease];
        [curtain addGestureRecognizer:tr];
        self.curtain = curtain;
    }
    
    // base
    {
        CGRect frm = CGRectMake(0, 0, 250, 280);
        UIView* base = [[UIView alloc] initWithFrame:frm];
        [base setBackgroundColor:[UIColor greenColor]];
        [base setUserInteractionEnabled:NO];
        [self addSubview:base];
        self.baseView = base;
        [self.baseView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
    }
    
    // animation
    [self.baseView setAlpha:0];
    [self.baseView setTransform:CGAffineTransformMakeScale(1.5, 0)];
    [UIView animateWithDuration:0.2 animations:^{
        [self.baseView setAlpha:1];
        [self.baseView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    }completion:^(BOOL finished) {
        //[_curtain setAlpha:0.2];
    }];
    
    // rotate
    [self setTransform:CGAffineTransformMakeRotation(-90*M_PI/180)];
    
}

- (void)onTapBackground:(UIGestureRecognizer*)sender
{
    // close
    [_curtain removeFromSuperview];
    [UIView animateWithDuration:0.2 animations:^{
        [self.baseView setTransform:CGAffineTransformMakeScale(1.5, 0)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
