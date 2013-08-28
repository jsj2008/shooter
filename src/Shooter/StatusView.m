//
//  StatusView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/29.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "Common.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+MyCategory.h"
#import "StatusView.h"
#import "UserData.h"
//#import "PlayerDetailView.h"

@interface StatusView()
{
    CGRect frame;
    UILabel* moneyLabel;
    UILabel* scoreLabel;
    UILabel* progressLabel;
    UILabel* stageLevelLabel;
    CGRect progressFrameFrame;
    UIView* progressBarLeft;
    CALayer* progressBarLayer;
    CGRect progressBarFrame;
    UIView* progressBase;
}
@end

@implementation StatusView

static StatusView* instance = NULL;
const float ProgressFrameHeight = 20;
const float ProgressFrameWidth = 160;
const float ProgressBarHeight = 12;
const float ProgressBarWidth = 146;

+ (id)CreateInstance
{
    if (instance)
    {
        [instance release];
        instance = nil;
    }
    return [self GetInstance];
}

+ (id)GetInstance
{
    if (instance == nil)
    {
        StatusView* s = [[StatusView alloc] init];
        instance = s;
    }
    return instance;
}

- (void)dealloc
{
    //[moneyLabel dealloc];
    if (progressBarLeft) {
        [progressBarLeft release];
    }
    if (moneyLabel) {
        [moneyLabel release];
    }
    if (progressLabel) {
        [progressLabel release];
    }
    if (stageLevelLabel) {
        [stageLevelLabel release];
    }
    if (progressBase) {
        [progressBase release];
    }
    if (progressBarLayer) {
        [progressBarLayer release];
    }
    [super dealloc];
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
        
        // bar
        /*
        {
            UIView* v = [[[UIView alloc] initWithFrame:CGRectMake(-10, 15, 150, 4)] autorelease];
            [v setBackgroundColor:[UIColor colorWithHexString:@"#cc44bb"]];
            [v.layer setCornerRadius:2];
            [self addSubview:v];
        }*/
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
            moneyLabel = [[UILabel alloc] init];
            UIFont* font = [UIFont fontWithName:@"HiraKakuProN-W6" size:11];
            [moneyLabel setFont:font];
            [moneyLabel setTextAlignment:NSTextAlignmentLeft];
            [moneyLabel setFrame:CGRectMake(26, 5, 200, 16)];
            [moneyLabel setBackgroundColor:[UIColor clearColor]];
            [moneyLabel setTextColor:MAIN_FONT_COLOR];
            [self addSubview:moneyLabel];
        }
        
        progressBase = [[UIView alloc] initWithFrame:frame];
        [self addSubview:progressBase];
        progressFrameFrame = CGRectMake(frame.size.width - ProgressFrameWidth - 10, 15, ProgressFrameWidth, ProgressFrameHeight);
        progressBarFrame = CGRectMake(frame.size.width - ProgressFrameWidth - 3, 20, ProgressBarWidth, ProgressBarHeight);
        
        // bar2
        /*
        {
            UIView* v = [[[UIView alloc] initWithFrame:CGRectMake(-10, 31, 150, 4)] autorelease];
            [v setBackgroundColor:[UIColor colorWithHexString:@"#44ccbb"]];
            [v.layer setCornerRadius:2];
            [progressBase addSubview:v];
        }*/
        
        // score
        {
            scoreLabel = [[UILabel alloc] init];
            UIFont* font = [UIFont fontWithName:@"HiraKakuProN-W6" size:11];
            [scoreLabel setFont:font];
            [scoreLabel setTextAlignment:NSTextAlignmentLeft];
            [scoreLabel setFrame:CGRectMake(26, 20, 200, 16)];
            [scoreLabel setBackgroundColor:[UIColor clearColor]];
            [scoreLabel setTextColor:MAIN_FONT_COLOR];
            [progressBase addSubview:scoreLabel];
        }
        
        // grade
        
        // progress bar background
        {
            UIView* view = [[[UIView alloc] initWithFrame:frame] autorelease];
            CAGradientLayer *pageGradient = [CAGradientLayer layer];
            pageGradient.frame = progressBarFrame;
            pageGradient.colors =
            [NSArray arrayWithObjects:
             // 赤から黒へグラデーションします。
             (id)[UIColor redColor].CGColor,
             (id)[UIColor blackColor].CGColor, nil];
            [view.layer insertSublayer:pageGradient atIndex:0];
            //[self addSubview:view];
            [progressBase addSubview:view];
            progressBarLeft = view;
            {
                CABasicAnimation *theAnimation;
                theAnimation=[CABasicAnimation animationWithKeyPath:@"colors"];
                theAnimation.duration=2.5;
                theAnimation.repeatCount=INT_MAX;
                theAnimation.autoreverses=YES;
                theAnimation.fromValue=
                [NSArray arrayWithObjects:
                 (id)[UIColor colorWithHexString:@"#880D00"].CGColor,
                 (id)[UIColor colorWithHexString:@"#200100"].CGColor, nil];
                theAnimation.toValue=
                [NSArray arrayWithObjects:
                 (id)[UIColor colorWithHexString:@"#f11400"].CGColor,
                 (id)[UIColor colorWithHexString:@"#880d00"].CGColor, nil];
                [pageGradient addAnimation:theAnimation forKey:@"progress anime"];
            }
        }
        
        // progress bar
        {
            UIView* view = [[[UIView alloc] initWithFrame:frame] autorelease];
            [progressBase addSubview:view];
            progressBarLeft = view;
            progressBarLayer = nil;
        }
        
        // progress frame
        {
            UIImage* img = [UIImage imageNamed:@"enemy_health_bar_foreground_001.png"];
            UIImageView* imgView = [[[UIImageView alloc] initWithImage:img] autorelease];
            [imgView setFrame:progressFrameFrame];
            //[self addSubview:imgView];
            [progressBase addSubview:imgView];
        }
        
        // progress label
        {
            progressLabel = [[UILabel alloc] init];
            UIFont* font = [UIFont fontWithName:@"Arial-BoldMT" size:12];
            [progressLabel setFont:font];
            [progressLabel setTextAlignment:NSTextAlignmentRight];
            [progressLabel setFrame:CGRectMake(progressBarFrame.origin.x, progressBarFrame.origin.y, progressBarFrame.size.width, progressBarFrame.size.height)];
            [progressLabel setBackgroundColor:[UIColor clearColor]];
            [progressLabel setTextColor:[UIColor colorWithHexString:@"#ffffff"]];
            [progressLabel setText:@"100%"];
            //[self addSubview:progressLabel];
            [progressBase addSubview:progressLabel];
        }
        
        // stage Level Label
        {
            stageLevelLabel = [[UILabel alloc] init];
            //UIFont* font = [UIFont fontWithName:@"Mutsuki" size:15];
            //[stageLevelLabel setFont:font];
            UIFont* font = [UIFont fontWithName:@"HiraKakuProN-W6" size:11];
            [stageLevelLabel setFont:font];
            [stageLevelLabel setTextAlignment:NSTextAlignmentLeft];
            //[stageLevelLabel setFrame:CGRectMake(frame.size.width - 200, 5, 200, StatusViewHeight)];
            [stageLevelLabel setAdjustsFontSizeToFitWidth:YES];
            [stageLevelLabel setFrame:CGRectMake(progressBarFrame.origin.x + 10, 5, 200, StatusViewHeight)];
            [stageLevelLabel setBackgroundColor:[UIColor clearColor]];
            [stageLevelLabel setTextColor:MAIN_FONT_COLOR];
            //[self addSubview:stageLevelLabel];
            [progressBase addSubview:stageLevelLabel];
        }
        
    }
    instance = self;
    return self;
}
- (void)hideProgress
{
    [UIView animateWithDuration:0.1 animations:^{
        [progressBase setAlpha:0.3];
    }];
}
- (void)showProgress
{
    [UIView animateWithDuration:0.1 animations:^{
        [progressBase setAlpha:1];
    }];
}

- (void)loadUserInfo
{
    hg::UserData* u = hg::UserData::sharedUserData();
    [moneyLabel setText:[NSString stringWithFormat:@"%ld Gold", u->getMoney()]];
    [scoreLabel setText:[NSString stringWithFormat:@"%ld Pt", u->getTotalScore()]];
    
    double clearRatio = u->getCurrentClearRatio();
    {
        if (progressBarLayer) {
            [progressBarLayer removeFromSuperlayer];
            [progressBarLayer release];
            progressBarLayer = nil;
        }
        CAGradientLayer *pageGradient = [CAGradientLayer layer];
        pageGradient.frame = progressBarFrame;
        pageGradient.colors =
        [NSArray arrayWithObjects:
         // 赤から黒へグラデーションします。
         (id)[UIColor greenColor].CGColor,
         (id)[UIColor blackColor].CGColor, nil];
        [progressBarLeft.layer insertSublayer:pageGradient atIndex:0];
        {
            CABasicAnimation *theAnimation;
            theAnimation=[CABasicAnimation animationWithKeyPath:@"colors"];
            theAnimation.duration=2.5;
            theAnimation.repeatCount=INT_MAX;
            theAnimation.autoreverses=YES;
            theAnimation.fromValue=
            [NSArray arrayWithObjects:
             (id)[UIColor colorWithHexString:@"#0D8800"].CGColor,
             (id)[UIColor colorWithHexString:@"#012000"].CGColor, nil];
            theAnimation.toValue=
            [NSArray arrayWithObjects:
             (id)[UIColor colorWithHexString:@"#14f100"].CGColor,
             (id)[UIColor colorWithHexString:@"#0d8800"].CGColor, nil];
            [pageGradient addAnimation:theAnimation forKey:@"progress anime"];
        }
        progressBarLayer = pageGradient;
        [progressBarLayer retain];
        
        CGRect f = progressBarLayer.frame;
        f.size.width = clearRatio * ProgressBarWidth;
        progressBarLayer.frame = f;
    }
    {
        [progressLabel setText:[NSString stringWithFormat:@"%d%%", (int)(clearRatio*100)]];
    }
    {
        hg::StageInfo stage_info = hg::UserData::sharedUserData()->getStageInfo();
        NSString* stage_name = [NSString stringWithCString:stage_info.stage_name.c_str() encoding:NSUTF8StringEncoding];
        [stageLevelLabel setText: stage_name];
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
