//
//  AllyDetailView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/07/21.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "AllyDetailView.h"
#import "UIColor+MyCategory.h"
#import <QuartzCore/QuartzCore.h>

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
        [base setBackgroundColor:[UIColor blackColor]];
        [base setUserInteractionEnabled:NO];
        [self addSubview:base];
        self.baseView = base;
        [self.baseView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [self.baseView.layer setBorderWidth:1];
        [self.baseView.layer setBorderColor:[UIColor colorWithHexString:@"#87ea00"].CGColor];
    }
    
    // animation
    [self.baseView setAlpha:0];
    [self.baseView setTransform:CGAffineTransformMakeScale(2, 0)];
    [UIView animateWithDuration:0.2 animations:^{
        [self.baseView setAlpha:1];
        [self.baseView setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    }completion:^(BOOL finished) {
        //[_curtain setAlpha:0.2];
    }];
    
    // rotate
    [self setTransform:CGAffineTransformMakeRotation(-90*M_PI/180)];
    
    // ==================================================
    // set data
    // ==================================================
    hg::FighterInfo* info = _fighterInfo;
    int labelIndex = -1;
    // name
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithCString:info->name.c_str() encoding:NSUTF8StringEncoding]];
        [self.baseView addSubview:lb];
    }
    // level
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:@"Level %d", info->level]];
        [self.baseView addSubview:lb];
    }
    // exp
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:@"Exp %ld/%ld", info->exp, info->expNext]];
        [self.baseView addSubview:lb];
    }
    // life
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:@"HP %d/%d", info->life, info->lifeMax]];
        [self.baseView addSubview:lb];
    }
    // shield
    {
        labelIndex++;
        NSString* text = nil;
        if (info->shieldMax>0)
        {
            text = [NSString stringWithFormat:@"Shield %d/%d", info->shield, info->shieldMax];
        }
        else
        {
            text = [NSString stringWithFormat:@"No Shield"];
        }
        UILabel* lb = [self labelWithIndex:labelIndex WithText:text];
        [self.baseView addSubview:lb];
    }
    // damage per sec
    {
        labelIndex++;
        double dmg = hg::UserData::sharedUserData()->getDamagePerSecond(info);
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:@"Damage %.02f/sec", dmg]];
        [self.baseView addSubview:lb];
    }
    // speed
    {
        labelIndex++;
        double val = info->speed * 2 * 60 * 60;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:@"Speed %.02f Km/h", val]];
        [self.baseView addSubview:lb];
    }
    // value
    {
        labelIndex++;
        int val = hg::UserData::sharedUserData()->getCost(info);
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:@"Value %d gold", val]];
        [self.baseView addSubview:lb];
    }
    // kill
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:@"Kill %d", info->killCnt]];
        [self.baseView addSubview:lb];
    }
    // die
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:@"Dead %d", info->dieCnt]];
        [self.baseView addSubview:lb];
    }
    // total kill
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:@"Total kill %d", info->killCnt]];
        [self.baseView addSubview:lb];
    }
    // total die
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:@"Total dead %d", info->dieCnt]];
        [self.baseView addSubview:lb];
    }
}

- (void)onTapBackground:(UIGestureRecognizer*)sender
{
    // close
    [_curtain removeFromSuperview];
    [UIView animateWithDuration:0.2 animations:^{
        [self.baseView setTransform:CGAffineTransformMakeScale(2, 0)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (UILabel*)labelWithIndex:(int)index WithText:(NSString*)text
{
    UILabel* lb = [[[UILabel alloc] init] autorelease];
    UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:12];
    CGRect labelFrame;
    labelFrame.size.width = self.baseView.frame.size.width - 10;
    labelFrame.size.height = 16;
    labelFrame.origin.x = 10;
    labelFrame.origin.y = index * 12 + 10;
    [lb setFrame:labelFrame];
    [lb setTextAlignment:NSTextAlignmentLeft];
    [lb setFont:font];
    [lb setText:text];
    [lb setBackgroundColor:[UIColor clearColor]];
    [lb setUserInteractionEnabled:NO];
    [lb setTextColor:[UIColor colorWithHexString:@"#87ea00"]];
    return lb;
}


@end
