//
//  AllyDetailView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/07/21.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "Common.h"
#import "AllyDetailView.h"
#import "UIColor+MyCategory.h"
#import "ObjectAL.h"
#import <QuartzCore/QuartzCore.h>
#import "ImageButtonView.h"
#import "MenuButton.h"
#import "DialogView.h"
#import "StatusView.h"
#import "AllyTableView.h"

@interface AllyDetailView()
{
    bool isUsers_;
    hg::FighterInfo* _fighterInfo;
}
@property(weak)UIView* curtain;
@property(weak)UIView* baseView;
@property(weak)UITextField* nameTextField;
@end

@implementation AllyDetailView

- (id)initWithFighterInfo:(hg::FighterInfo*)fighterInfo isUsers:(bool)_isUsers
{
    self = [super init];
    if (self) {
        assert(fighterInfo != NULL);
        _fighterInfo = fighterInfo;
        isUsers_ = _isUsers;
    }
    return self;
}

-(void)dealloc
{
    //[_curtain release];
    //[_baseView release];
    if (_nameTextField) {
        //[_nameTextField release];
    }
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
        UITapGestureRecognizer *tr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBackground:)];
        [curtain addGestureRecognizer:tr];
        self.curtain = curtain;
    }
    
    // base
    {
        CGRect frm = CGRectMake(0, 0, 250, 280);
        UIView* base = [[UIView alloc] initWithFrame:frm];
        [base setBackgroundColor:[UIColor blackColor]];
        [base setUserInteractionEnabled:YES];
        [self addSubview:base];
        self.baseView = base;
        [self.baseView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [self.baseView.layer setBorderWidth:1];
        [self.baseView.layer setBorderColor:MAIN_BORDER_COLOR.CGColor];
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
    if (!isUsers_){
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithCString:info->name.c_str() encoding:NSUTF8StringEncoding]];
        [self.baseView addSubview:lb];
    } else {
        // delete data button
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithCString:info->name.c_str() encoding:NSUTF8StringEncoding]];
        CGRect frame = lb.frame;
        frame.size.height = 15;
        frame.size.width = 150;
        UITextField* tf = [[UITextField alloc] initWithFrame:lb.frame];
        [tf setBackgroundColor:[UIColor grayColor]];
        //[tf setBackgroundColor:[UIColor whiteColor]];
        [tf setBorderStyle:UITextBorderStyleLine];
        [tf setTextColor:MAIN_FONT_COLOR];
        [tf setFont:lb.font];
        [tf setText:STR2NSSTR(info->name)];
        [self.baseView addSubview:tf];
        self.nameTextField = tf;
    }
    
    // level
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:NSLocalizedString(@"Level %d", nil), info->level]];
        [self.baseView addSubview:lb];
    }
    // exp
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:NSLocalizedString(@"Exp %ld/%ld", nil), info->exp, info->expNext]];
        [self.baseView addSubview:lb];
    }
    // life
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:NSLocalizedString(@"HP %d/%d", nil), info->life, info->lifeMax]];
        [self.baseView addSubview:lb];
    }
    // shield
    {
        labelIndex++;
        NSString* text = nil;
        if (info->shieldMax>0)
        {
            text = [NSString stringWithFormat:NSLocalizedString(@"Shield %d/%d", nil), info->shield, info->shieldMax];
        }
        else
        {
            text = [NSString stringWithFormat:NSLocalizedString(@"No Shield", nil)];
        }
        UILabel* lb = [self labelWithIndex:labelIndex WithText:text];
        [self.baseView addSubview:lb];
    }
    // damage per sec
    {
        labelIndex++;
        double dmg = hg::UserData::sharedUserData()->getDamagePerSecond(info);
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:NSLocalizedString(@"Attack %.2lf/sec", nil), dmg]];
        [self.baseView addSubview:lb];
    }
    // speed
    {
        labelIndex++;
        double val = info->speed * 2 * 60 * 60;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:NSLocalizedString(@"Speed %.2lf Km/h", nil), val]];
        [self.baseView addSubview:lb];
    }
    // teq
    {
        labelIndex++;
        int val = info->cpu_lv;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:NSLocalizedString(@"Teqnique %d Lv", nil), val]];
        [self.baseView addSubview:lb];
    }
    // value
    {
        labelIndex++;
        int val = hg::UserData::sharedUserData()->getCost(info);
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:NSLocalizedString(@"Value %d gold", nil), val]];
        [self.baseView addSubview:lb];
    }
    /*
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
     }*/
    // total kill
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:NSLocalizedString(@"Total kill %d", nil), info->killCnt]];
        [self.baseView addSubview:lb];
    }
    // total die
    {
        labelIndex++;
        UILabel* lb = [self labelWithIndex:labelIndex WithText:[NSString stringWithFormat:NSLocalizedString(@"Total dead %d", nil), info->dieCnt]];
        [self.baseView addSubview:lb];
    }
    
    // sell button
    if (isUsers_)
    {
        float w = (self.baseView.frame.size.width - 10) / 2;
        float h = 30;
        float x = self.baseView.frame.size.width/2 - w/2;
        float y = self.baseView.frame.size.height - h - 5;
        
        // delete data button
        {
            CGRect frm = CGRectMake(x, y, w, h);
            MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
            [m setBackgroundColor:[UIColor whiteColor]];
            [m setText:NSLocalizedString(@"Sell", nil)];
            [m setColor:[UIColor blackColor]];
            [m setBackgroundColor:[UIColor whiteColor]];
            [self.baseView addSubview:m];
            [m setOnTapAction:^(MenuButton *target) {
                
                hg::UserData* u = hg::UserData::sharedUserData();
                int cost = u->getSellValue(_fighterInfo);
                NSString* msg = [NSString stringWithFormat:NSLocalizedString(@"Are you sure to sell this for %d Gold?", nil), cost];
                DialogView* dialog = [[DialogView alloc] initWithMessage:msg];
                [dialog addButtonWithText:NSLocalizedString(@"Sell", nil) withAction:^{
                    u->sell(_fighterInfo);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[StatusView GetInstance] loadUserInfo];
                    });
                    [self closeThis];
                    [AllyTableView ReloadData];
                }];
                [dialog addButtonWithText:NSLocalizedString(@"Cancel", nil) withAction:^{
                    // nothing
                }];
                [dialog show];
            }];
        }
        
    }
}

- (void)closeThis
{
    // close
    [_curtain removeFromSuperview];
    [UIView animateWithDuration:0.2 animations:^{
        [self.baseView setTransform:CGAffineTransformMakeScale(2, 0)];
    } completion:^(BOOL finished) {
        if (_nameTextField) {
            NSString* name = [_nameTextField text];
            std::string n = NSSTR2STR(name);
            if (n != "") {
                _fighterInfo->name = n;
                [AllyTableView ReloadData];
            }
        }
        [self removeFromSuperview];
    }];
}

- (void)onTapBackground:(UIGestureRecognizer*)sender
{
    [[OALSimpleAudio sharedInstance] playEffect:SE_CLICK];
    [self closeThis];
}

- (UILabel*)labelWithIndex:(int)index WithText:(NSString*)text
{
    UILabel* lb = [[UILabel alloc] init];
    //UIFont* font = [UIFont fontWithName:@"HiraKakuProN-W6" size:12];
    UIFont* font = [[lb font] fontWithSize:12];
    CGRect labelFrame;
    labelFrame.size.width = self.baseView.frame.size.width - 10;
    labelFrame.size.height = 20;
    labelFrame.origin.x = 10;
    labelFrame.origin.y = index * 18 + 10;
    [lb setFrame:labelFrame];
    [lb setTextAlignment:NSTextAlignmentLeft];
    [lb setFont:font];
    [lb setText:text];
    [lb setBackgroundColor:[UIColor clearColor]];
    [lb setUserInteractionEnabled:NO];
    [lb setTextColor:MAIN_FONT_COLOR];
    return lb;
}


@end

