//
//  AllyView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/09.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "AllyView.h"
#import "UIColor+MyCategory.h"
#import <QuartzCore/QuartzCore.h>

@interface AllyView()
{
    hg::FighterInfo* _fighterInfo;
    NSMutableArray* labels;
    UIView* highlightView;
    AllyViewMode _mode;
}

@end

@implementation AllyView

- (id)initWithAllyViewMode:(AllyViewMode)mode WithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _mode = mode;
        // Initialization code
        labels = [[NSMutableArray alloc] init];
    }
    return self;
    
}

- (void) dealloc
{
    [labels release];
    [super dealloc];
}

- (void)reloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setFighterInfo:_fighterInfo];
    });
}

- (void)setFighterInfo:(hg::FighterInfo*) info
{
    _fighterInfo = info;
    
    // initialize
    {
        [labels removeAllObjects];
        while ([self.subviews count] > 0)
        {
            [[self.subviews objectAtIndex:0] removeFromSuperview];
        }
    }
    [self setBackgroundColor:[UIColor colorWithHexString:@"#439400"]];
    // name
    {
        UILabel* lb = [[[UILabel alloc] init] autorelease];
        UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:12];
        CGRect labelFrame = self.frame;
        labelFrame.size.width = self.frame.size.height - 20;
        labelFrame.size.height = self.frame.size.width;
        [lb setFrame:labelFrame];
        [lb setTextAlignment:NSTextAlignmentLeft];
        [lb setFont:font];
        [lb setText:[NSString stringWithCString:info->name.c_str() encoding:NSUTF8StringEncoding]];
        [lb setBackgroundColor:[UIColor clearColor]];
        [lb setUserInteractionEnabled:NO];
        //[lb setAlpha:0.5];
        [lb setTextColor:[UIColor colorWithHexString:@"#a9f16c"]];
        [lb setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, 90*M_PI/180)];
        [lb setCenter:CGPointMake(self.frame.size.width/2 + 26, self.frame.size.height/2)];
        [self addSubview:lb];
        [labels addObject:lb];
    }
    // level
    {
        UILabel* lb = [[[UILabel alloc] init] autorelease];
        UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:12];
        CGRect labelFrame = self.frame;
        labelFrame.size.width = self.frame.size.height - 20;
        labelFrame.size.height = self.frame.size.width;
        [lb setFrame:labelFrame];
        [lb setTextAlignment:NSTextAlignmentLeft];
        [lb setFont:font];
        [lb setText: [NSString stringWithFormat:@"Lv %d", info->level]];
        [lb setBackgroundColor:[UIColor clearColor]];
        [lb setUserInteractionEnabled:NO];
        //[lb setAlpha:0.5];
        [lb setTextColor:[UIColor colorWithHexString:@"#a9f16c"]];
        [lb setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, 90*M_PI/180)];
        [lb setCenter:CGPointMake(self.frame.size.width/2 + 13, self.frame.size.height/2)];
        [self addSubview:lb];
        [labels addObject:lb];
    }
    // life
    {
        UILabel* lb = [[[UILabel alloc] init] autorelease];
        UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:12];
        CGRect labelFrame = self.frame;
        labelFrame.size.width = self.frame.size.height - 20;
        labelFrame.size.height = self.frame.size.width;
        [lb setFrame:labelFrame];
        [lb setTextAlignment:NSTextAlignmentLeft];
        [lb setFont:font];
        [lb setText: [NSString stringWithFormat:@"HP %d/%d", info->life, info->lifeMax]];
        [lb setBackgroundColor:[UIColor clearColor]];
        [lb setUserInteractionEnabled:NO];
        //[lb setAlpha:0.5];
        [lb setTextColor:[UIColor colorWithHexString:@"#a9f16c"]];
        [lb setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, 90*M_PI/180)];
        [lb setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
        [self addSubview:lb];
        [labels addObject:lb];
    }
    // power
    {
        UILabel* lb = [[[UILabel alloc] init] autorelease];
        UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:12];
        CGRect labelFrame = self.frame;
        labelFrame.size.width = self.frame.size.height - 20;
        labelFrame.size.height = self.frame.size.width;
        [lb setFrame:labelFrame];
        [lb setTextAlignment:NSTextAlignmentLeft];
        [lb setFont:font];
        [lb setText: [NSString stringWithFormat:@"Dmg %d/sec", info->power]];
        [lb setBackgroundColor:[UIColor clearColor]];
        [lb setUserInteractionEnabled:NO];
        [lb setTextColor:[UIColor colorWithHexString:@"#a9f16c"]];
        [lb setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, 90*M_PI/180)];
        [lb setCenter:CGPointMake(self.frame.size.width/2 - 13, self.frame.size.height/2)];
        [self addSubview:lb];
        [labels addObject:lb];
    }
    // shield
    {
        UILabel* lb = [[[UILabel alloc] init] autorelease];
        UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:12];
        CGRect labelFrame = self.frame;
        labelFrame.size.width = self.frame.size.height - 20;
        labelFrame.size.height = self.frame.size.width;
        [lb setFrame:labelFrame];
        [lb setTextAlignment:NSTextAlignmentLeft];
        [lb setFont:font];
        if (info->shieldMax>0)
        {
            [lb setText: [NSString stringWithFormat:@"Shield: %d", info->shieldMax]];
        }
        else
        {
            [lb setText: [NSString stringWithFormat:@"Shield: None"]];
        }
        [lb setBackgroundColor:[UIColor clearColor]];
        [lb setUserInteractionEnabled:NO];
        [lb setTextColor:[UIColor colorWithHexString:@"#a9f16c"]];
        [lb setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, 90*M_PI/180)];
        [lb setCenter:CGPointMake(self.frame.size.width/2 - 26, self.frame.size.height/2)];
        [self addSubview:lb];
        [labels addObject:lb];
    }
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
    if (info->isReady)
    {
        [self setBackgroundColor:[UIColor colorWithHexString:@"#6c006c"]];
        for (id obj in labels)
        {
            UILabel* l = (UILabel*)obj;
            [l setTextColor:[UIColor colorWithHexString:@"#d25fd2"]];
        }
    }
    if (info->isPlayer)
    {
        [self setBackgroundColor:[UIColor colorWithHexString:@"#a62f00"]];
        for (id obj in labels)
        {
            UILabel* l = (UILabel*)obj;
            [l setTextColor:[UIColor colorWithHexString:@"#ff9b73"]];
        }
    }
    [self.layer setCornerRadius:3];
    
    switch (_mode)
    {
        case AllyViewModeSelectAlly:
        {
            if (_fighterInfo->isPlayer)
            {
                [self setBackgroundColor:[UIColor colorWithHexString:@"#a62f00"] WithTextColor:[UIColor colorWithHexString:@"#ff9b73"]];
            }
            else if (_fighterInfo->isReady)
            {
                [self setBackgroundColor:[UIColor colorWithHexString:@"#6c006c"] WithTextColor:[UIColor colorWithHexString:@"#d25fd2"]];
            }
            else
            {
                [self setBackgroundColor:[UIColor colorWithHexString:@"#439400"] WithTextColor:[UIColor colorWithHexString:@"#a9f16c"]];
            }
            break;
        }
        case AllyViewModeFix:
        {
            if (_fighterInfo->life == _fighterInfo->lifeMax)
            {
                [self setBackgroundColor:[UIColor colorWithHexString:@"#439400"] WithTextColor:[UIColor colorWithHexString:@"#a9f16c"]];
            }
            else
            {
                [self setBackgroundColor:[UIColor colorWithHexString:@"#a62f00"] WithTextColor:[UIColor colorWithHexString:@"#ff9b73"]];
            }
            break;
        }
        default:
            assert(0);
    }
    
    // touch
    {
        UITapGestureRecognizer *tr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAlly:)] autorelease];
        [self addGestureRecognizer:tr];
    }
    
}

- (void)touchAlly:(UIGestureRecognizer*)sender
{
    // 拡大アニメーションさせるので、トップに持ってくる
    [highlightView setAlpha:0];
    [self.superview.superview bringSubviewToFront:self.superview];
    [self.superview bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.10 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.1, 1.1);
        [self setTransform:t];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.10 animations:^{
            [self setTransform:CGAffineTransformIdentity];
        }];
    }];
    
    switch (_mode)
    {
        ////////////////////
        // Ally Select
        case AllyViewModeSelectAlly:
        {
            if (_fighterInfo->isPlayer)
            {
                return;
            }
            _fighterInfo->isReady = !_fighterInfo->isReady;
            if (_fighterInfo->isReady)
            {
                [self setBackgroundColor:[UIColor colorWithHexString:@"#6c006c"] WithTextColor:[UIColor colorWithHexString:@"#d25fd2"]];
            }
            else
            {
                [self setBackgroundColor:[UIColor colorWithHexString:@"#439400"] WithTextColor:[UIColor colorWithHexString:@"#a9f16c"]];
            }
            break;
        }
        ////////////////////
        // Fix Ally
        case AllyViewModeFix:
        {
            _fighterInfo->life = _fighterInfo->lifeMax;
            [self reloadData];
            break;
        }
            break;
        default:
            assert(0);
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor WithTextColor:(UIColor *)textColor
{
    [self setBackgroundColor:backgroundColor];
    for (id obj in labels)
    {
        UILabel* l = (UILabel*)obj;
        [l setTextColor:textColor];
    }
}

- (hg::FighterInfo*) getFighterinfo
{
    return _fighterInfo;
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

- (void)onTouchAnime
{
    // 拡大アニメーションさせるので、トップに持ってくる
    [highlightView setAlpha:0];
    [self.superview.superview bringSubviewToFront:self.superview];
    [self.superview bringSubviewToFront:self];
    
    [UIView animateWithDuration:0.10 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.1, 1.1);
        [self setTransform:t];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.10 animations:^{
            [self setTransform:CGAffineTransformIdentity];
        }];
    }];
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
