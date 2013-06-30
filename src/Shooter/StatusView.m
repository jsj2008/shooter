//
//  StatusView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/29.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIColor+MyCategory.h"
#import "StatusView.h"
#import "UserData.h"

@implementation StatusView

const int Height = 20;

- (id)init
{
    CGRect appFrame = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(0, 0, appFrame.size.height, Height);
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)loadUserInfo
{
    CGRect frame = self.frame;
    while ([self.subviews count] > 0)
    {
        [[self.subviews objectAtIndex:0] removeFromSuperview];
    }
    [self setBackgroundColor:[UIColor whiteColor]];
    hg::UserData* u = hg::UserData::sharedUserData();
    
    // money
    {
        UILabel* moneyLabel = [[[UILabel alloc] init] autorelease];
        UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:13];
        [moneyLabel setFont:font];
        [moneyLabel setText:[NSString stringWithFormat:@"%d Gold", u->getMoney()]];
        [moneyLabel setTextAlignment:NSTextAlignmentRight];
        [moneyLabel setFrame:CGRectMake(frame.size.width - 220, 0, 200, Height)];
        [moneyLabel setBackgroundColor:[UIColor clearColor]];
        [moneyLabel setTextColor:[UIColor colorWithHexString:@"#ddddff"]];
        [self addSubview:moneyLabel];
    }
    
    // design
    {
        [self.layer setBorderColor:[UIColor colorWithHexString:@"#ddddff"].CGColor];
        [self.layer setBorderWidth:2];
        [self setBackgroundColor:[UIColor colorWithHexString:@"#343488"]];
        [self setAlpha:0.6];
    }
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
