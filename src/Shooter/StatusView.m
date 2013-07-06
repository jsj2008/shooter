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

@interface StatusView()
{
    CGRect frame;
}
@end

@implementation StatusView

static StatusView* instance = NULL;

+ (id)GetInstance
{
    assert(instance != NULL);
    return instance;
}

- (id)init
{
    
    CGRect appFrame = [UIScreen mainScreen].bounds;
    frame = CGRectMake(0, 0, appFrame.size.height, StatusViewHeight);
    CGRect f = frame;
    f.origin.y = frame.size.height * -1;
    self = [super initWithFrame:f];
    if (self) {
        // Initialization code
        [UIView animateWithDuration:0.5 animations:^{
            [self setFrame:frame];
        }];
    }
    instance = self;
    return self;
}

- (void)loadUserInfo
{
    while ([self.subviews count] > 0)
    {
        [[self.subviews objectAtIndex:0] removeFromSuperview];
    }
    [self setBackgroundColor:[UIColor clearColor]];
    hg::UserData* u = hg::UserData::sharedUserData();
    
    // bar
    {
        UIView* v = [[UIView alloc] initWithFrame:CGRectMake(-10, StatusViewHeight - 4, 180, 6)];
        [v setBackgroundColor:[UIColor colorWithHexString:@"#cc44bb"]];
        [v.layer setCornerRadius:2];
        [self addSubview:v];
    }
    
    // money icon
    {
        CGRect f = CGRectMake(10, 0, 20, 20);
        UIImage* img = [[UIImage imageNamed:@"goldCoin5.png"] autorelease];
        UIImageView* iv = [[[UIImageView alloc] initWithFrame:f] autorelease];
        [iv setImage:img];
        [self addSubview:iv];
    }
    
    // money
    {
        UILabel* moneyLabel = [[[UILabel alloc] init] autorelease];
        UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:15];
        [moneyLabel setFont:font];
        [moneyLabel setText:[NSString stringWithFormat:@"%d Gold", u->getMoney()]];
        [moneyLabel setTextAlignment:NSTextAlignmentLeft];
        [moneyLabel setFrame:CGRectMake(26, 0, 200, StatusViewHeight)];
        [moneyLabel setBackgroundColor:[UIColor clearColor]];
        [moneyLabel setTextColor:[UIColor colorWithHexString:@"#ddddff"]];
        [self addSubview:moneyLabel];
    }
    
    // design
    {
        /*
        [self.layer setBorderColor:[UIColor colorWithHexString:@"#ddddff"].CGColor];
        [self.layer setBorderWidth:2];
        [self.layer setCornerRadius:8];
        [self setBackgroundColor:[UIColor colorWithHexString:@"#343488"]];
        //[self setAlpha:0.6];
         */
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
