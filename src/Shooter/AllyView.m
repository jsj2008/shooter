//
//  AllyView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/09.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "Common.h"
#import "AllyView.h"
#import "AllyTableView.h"
#import "UserData.h"
#import "UIColor+MyCategory.h"
#import <QuartzCore/QuartzCore.h>
#import "StatusView.h"
#import "DialogView.h"
#import "AllyDetailView.h"

@interface AllyViewLabel : UILabel

@end

@implementation AllyViewLabel

@end

@interface AllyView()
{
    hg::FighterInfo* _fighterInfo;
    NSMutableArray* labels;
    UILabel* coinLabel;
    UIView* highlightView;
    AllyViewMode _mode;
    CGRect defaultFrame;
    UIView* baseView;
    CGRect mainFrame;
    UIView* backView;
    NSTimeInterval touchStart;
    bool isShowDetail;
}

@end

@implementation AllyView

- (id)initWithAllyViewMode:(AllyViewMode)mode WithFrame:(CGRect)frame WithFighterInfo:(hg::FighterInfo*)info
{
    self = [super initWithFrame:frame];
    if (self) {
        _mode = mode;
        labels = [[NSMutableArray alloc] init];
        defaultFrame = frame;
        self.frame = frame;
        
        mainFrame.size.width = self.frame.size.height;
        mainFrame.size.height = self.frame.size.width;
        mainFrame.origin.x = 0;
        mainFrame.origin.y = 0;
        
        backView = [[UIView alloc] initWithFrame:mainFrame];
        [backView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, 90*M_PI/180)];
        [backView setCenter:CGPointMake(mainFrame.size.height/2, mainFrame.size.width/2)];
        [self addSubview:backView];
        
        baseView = [[UIView alloc] initWithFrame:mainFrame];
        [baseView setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, 90*M_PI/180)];
        [baseView setCenter:CGPointMake(mainFrame.size.height/2, mainFrame.size.width/2)];
        [self addSubview:baseView];
        {
            // highlight タッチされたときのハイライト用
            CGRect f = defaultFrame;
            f.origin.x = 0; f.origin.y = 0;
            highlightView = [[UIView alloc] initWithFrame:f];
            [highlightView setBackgroundColor:[UIColor whiteColor]];
            [highlightView setAlpha:0];
            [highlightView setUserInteractionEnabled:NO];
            [self addSubview:highlightView];
        }
        [self.layer setCornerRadius:3];
        // touch
        {
            UITapGestureRecognizer *tr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(touchAlly:)] autorelease];
            [self addGestureRecognizer:tr];
        }
        [self setFighterInfo:info];
    }
    return self;
    
}

- (void) dealloc
{
    [backView release];
    [labels release];
    [highlightView release];
    [baseView release];
    [super dealloc];
}

- (void)reloadData
{
    [self setFighterInfo:_fighterInfo];
}

- (UILabel*)labelWithIndex:(int)index WithText:(NSString*)text
{
    UILabel* lb = [[[UILabel alloc] init] autorelease];
    UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:12];
    CGRect labelFrame = self.frame;
    labelFrame.size.width = mainFrame.size.width - 10;
    labelFrame.size.height = 16;
    labelFrame.origin.x = 10;
    labelFrame.origin.y = index * 10 + 5;
    [lb setFrame:labelFrame];
    [lb setTextAlignment:NSTextAlignmentLeft];
    [lb setFont:font];
    [lb setText:text];
    [lb setBackgroundColor:[UIColor clearColor]];
    [lb setUserInteractionEnabled:NO];
    [lb setTextColor:[UIColor colorWithHexString:@"#ffffff"]];
    //[lb setCenter:CGPointMake(self.frame.size.width/2 + 33 - (11*index), self.frame.size.height/2)];
    return lb;
}

- (void)setFighterInfo:(hg::FighterInfo*) info
{
    
    if (info == NULL)
    {
        NSLog(@"no info!!(AllyView->setFighterInfo)");
        return;
    }
    _fighterInfo = info;
    
    // initialize
    {
        [labels removeAllObjects];
        while ([baseView.subviews count] > 0)
        {
            [[baseView.subviews objectAtIndex:0] removeFromSuperview];
        }
    }
    [self setBackgroundColor:[UIColor colorWithHexString:@"#4ae83a"]];
    
    // life
    {
        CGRect frame = defaultFrame;
        frame.origin.x = 2;
        frame.origin.y = 10;
        frame.size.height = frame.size.height - 20;
        frame.size.width = 2;
        // life base
        UIView* lifeBar = [[UIView alloc] initWithFrame:frame];
        lifeBar.layer.masksToBounds = YES;
        [lifeBar setBackgroundColor:[UIColor colorWithHexString:@"#d8005f"]];
        [lifeBar setAlpha:1];
        [lifeBar.layer setCornerRadius:3];
        [self addSubview:lifeBar];
        // rest life
        double lifeRatio = (double)info->life/(double)info->lifeMax;
        frame.size.height *= lifeRatio;
        UIView* life = [[UIView alloc] initWithFrame:frame];
        life.layer.masksToBounds = YES;
        [life setBackgroundColor:[UIColor colorWithHexString:@"#87ea00"]];
        [life setAlpha:1];
        [life.layer setCornerRadius:3];
        [self addSubview:life];
    }
    // shield
    if (_fighterInfo->shieldMax > 0)
    {
        CGRect frame = defaultFrame;
        frame.origin.x = 5;
        frame.origin.y = 10;
        frame.size.height -= 20;
        frame.size.width = 2;
        // life base
        UIView* lifeBar = [[UIView alloc] initWithFrame:frame];
        lifeBar.layer.masksToBounds = YES;
        [lifeBar setBackgroundColor:[UIColor colorWithHexString:@"#d8005f"]];
        [lifeBar setAlpha:1];
        [lifeBar.layer setCornerRadius:3];
        [self addSubview:lifeBar];
        // rest life
        double lifeRatio = (double)info->shield/(double)info->shieldMax;
        frame.size.height *= lifeRatio;
        UIView* life = [[UIView alloc] initWithFrame:frame];
        life.layer.masksToBounds = YES;
        [life setBackgroundColor:[UIColor colorWithHexString:@"#6a48d7"]];
        [life setAlpha:1];
        [life.layer setCornerRadius:3];
        [self addSubview:life];
    }
    
    // name
    {
        UILabel* lb = [self labelWithIndex:0 WithText:[NSString stringWithCString:info->name.c_str() encoding:NSUTF8StringEncoding]];
        [baseView addSubview:lb];
        [labels addObject:lb];
    }
    // level
    {
        UILabel* lb = [self labelWithIndex:1 WithText:[NSString stringWithFormat:@"Level %d", info->level]];
        [baseView addSubview:lb];
        [labels addObject:lb];
    }
    // life
    {
        UILabel* lb = [self labelWithIndex:2 WithText:[NSString stringWithFormat:@"HP %d/%d", info->life, info->lifeMax]];
        [baseView addSubview:lb];
        [labels addObject:lb];
    }
    // shield
    {
        NSString* text = nil;
        if (info->shieldMax>0)
        {
            text = [NSString stringWithFormat:@"Shield %d/%d", info->shield, info->shieldMax];
        }
        else
        {
            text = [NSString stringWithFormat:@"No Shield"];
        }
        UILabel* lb = [self labelWithIndex:3 WithText:text];
        [baseView addSubview:lb];
        [labels addObject:lb];
    }
    switch(_mode)
    {
        case AllyViewModeFix:
        {
            int cost = hg::UserData::sharedUserData()->getRepairCost(info);
            if (cost >= 0)
            {
                NSString* text = [NSString stringWithFormat:@"%d", cost];
                UILabel* lb = [self labelWithIndex:4 WithText:text];
                CGRect f = lb.frame;
                // money icon
                {
                    f.origin.x -= 2;
                    CGRect coinf = f;
                    coinf.size.width = coinf.size.height = 16;
                    UIImage* img = [UIImage imageNamed:@"goldCoin5.png"];
                    UIImageView* iv = [[[UIImageView alloc] initWithFrame:coinf] autorelease];
                    [iv setImage:img];
                    [baseView addSubview:iv];
                }
                f.origin.x += 16;
                [lb setFrame:f];
                [baseView addSubview:lb];
                coinLabel = lb;
                if (hg::UserData::sharedUserData()->getMoney() < cost)
                {
                    [coinLabel setTextColor:[UIColor redColor]];
                }
                else
                {
                    [coinLabel setTextColor:[UIColor whiteColor]];
                }
            }
            break;
        }
        case AllyViewModeShop:
        {
            int cost = hg::UserData::sharedUserData()->getBuyCost(info);
            if (cost >= 0)
            {
                NSString* text = [NSString stringWithFormat:@"%d", cost];
                UILabel* lb = [self labelWithIndex:4 WithText:text];
                CGRect f = lb.frame;
                // money icon
                {
                    f.origin.x -= 2;
                    CGRect coinf = f;
                    coinf.size.width = coinf.size.height = 16;
                    UIImage* img = [UIImage imageNamed:@"goldCoin5.png"];
                    UIImageView* iv = [[[UIImageView alloc] initWithFrame:coinf] autorelease];
                    [iv setImage:img];
                    [baseView addSubview:iv];
                }
                f.origin.x += 16;
                [lb setFrame:f];
                [baseView addSubview:lb];
                coinLabel = lb;
                if (hg::UserData::sharedUserData()->getMoney() < cost)
                {
                    [coinLabel setTextColor:[UIColor redColor]];
                }
                else
                {
                    [coinLabel setTextColor:[UIColor whiteColor]];
                }
            }
            break;
        }
        case AllyViewModeSell:
        {
            int cost = hg::UserData::sharedUserData()->getSellValue(info);
            if (cost >= 0)
            {
                NSString* text = [NSString stringWithFormat:@"+%d", cost];
                UILabel* lb = [self labelWithIndex:4 WithText:text];
                CGRect f = lb.frame;
                // money icon
                {
                    f.origin.x -= 2;
                    CGRect coinf = f;
                    coinf.size.width = coinf.size.height = 16;
                    UIImage* img = [UIImage imageNamed:@"goldCoin5.png"];
                    UIImageView* iv = [[[UIImageView alloc] initWithFrame:coinf] autorelease];
                    [iv setImage:img];
                    [baseView addSubview:iv];
                }
                f.origin.x += 16;
                [lb setFrame:f];
                [baseView addSubview:lb];
                coinLabel = lb;
                if (hg::UserData::sharedUserData()->getMoney() < cost)
                {
                    [coinLabel setTextColor:[UIColor redColor]];
                }
                else
                {
                    [coinLabel setTextColor:[UIColor whiteColor]];
                }
            }
            break;
        }
        default:
            break;
    }
    
    [self setShowColor:[UIColor colorWithHexString:@"#269926"]];
    
    switch (_mode)
    {
        case AllyViewModeSelectAlly:
        {
            do
            {
                if (_fighterInfo->isPlayer)
                {
                    break;
                }
                if (_fighterInfo->isReady)
                {
                    [self setShowColor:[UIColor colorWithHexString:@"#6a48d7"]];
                }
                else
                {
                    [self setShowColor:[UIColor colorWithHexString:@"#888888"]];
                }
            } while(0);
            break;
        }
        case AllyViewModeDeployAlly:
        {
            if (_fighterInfo->isOnBattleGround)
            {
                [self setShowColor:[UIColor colorWithHexString:@"#269926"]];
            }
            else
            {
                [self setShowColor:[UIColor colorWithHexString:@"#6a48d7"]];
            }
            break;
        }
        case AllyViewModeShop:
        {
            break;
        }
        case AllyViewModeFix:
        case AllyViewModeSell:
        case AllyViewModeSelectPlayer:
        {
            if (_fighterInfo->isPlayer)
            {
                [self setShowColor:[UIColor colorWithHexString:@"#269926"]];
            }
            else if (_fighterInfo->isReady)
            {
                [self setShowColor:[UIColor colorWithHexString:@"#6a48d7"]];
            }
            else
            {
                [self setShowColor:[UIColor colorWithHexString:@"#888888"]];
            }
            break;
        }
        default:
            break;
    }
    
    
}

- (void)touchAlly:(UIGestureRecognizer*)sender
{
    if (isShowDetail)
    {
        return;
    }
    // 拡大アニメーションさせるので、トップに持ってくる
    [highlightView setAlpha:0];
    if (self.superview)
    {
        if (self.superview.superview)
        {
            [self.superview.superview bringSubviewToFront:self.superview];
        }
        [self.superview bringSubviewToFront:self];
    }
    
    [UIView animateWithDuration:0.10 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.1, 1.1);
        [self setTransform:t];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.10 animations:^{
            [self setTransform:CGAffineTransformIdentity];
        } completion:^(BOOL finished) {
            //[self reloadData];
        }];
    }];
    
    switch (_mode)
    {
        ////////////////////
        // Ally Select
        case AllyViewModeDeployAlly:
        {
            if (_fighterInfo->isPlayer)
            {
                return;
            }
            _fighterInfo->isOnBattleGround = !_fighterInfo->isOnBattleGround;
            break;
        }
        case AllyViewModeSelectAlly:
        {
            if (_fighterInfo->isPlayer)
            {
                return;
            }
            if (_fighterInfo->isReady)
            {
                hg::UserData::sharedUserData()->setUnReady(_fighterInfo);
            }
            else
            {
                hg::UserData::sharedUserData()->setReady(_fighterInfo);
            }
            break;
        }
        ////////////////////
        // Fix Ally
        case AllyViewModeFix:
        {
            hg::UserData* u = hg::UserData::sharedUserData();
            int cost = u->getRepairCost(_fighterInfo);
            // check money
            if (_fighterInfo->life >= _fighterInfo->lifeMax)
            {
                DialogView* dialog = [[[DialogView alloc] initWithMessage:@"You don't need to repair this."] autorelease];
                [dialog addButtonWithText:@"OK" withAction:^{
                    // nothing
                }];
                [dialog show];
                
            }
            else if (u->getMoney() >= cost)
            {
                // fix
                u->addMoney(-1 * u->getRepairCost(_fighterInfo));
                _fighterInfo->life = _fighterInfo->lifeMax;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[StatusView GetInstance] loadUserInfo];
                });
            }
            else
            {
                DialogView* dialog = [[[DialogView alloc] initWithMessage:@"You need more gold."] autorelease];
                [dialog addButtonWithText:@"OK" withAction:^{
                    // nothing
                }];
                [dialog show];
            }
            
            break;
        }
        ////////////////////
        // buy fighter
        case AllyViewModeShop:
        {
            hg::UserData* u = hg::UserData::sharedUserData();
            int cost = u->getBuyCost(_fighterInfo);
            // check money
            if (u->getMoney() >= cost)
            {
                // buy
                NSString* msg = [NSString stringWithFormat:@"It Costs %d gold. Are you sure to buy this?", cost];
                DialogView* dialog = [[[DialogView alloc] initWithMessage:msg] autorelease];
                [dialog addButtonWithText:@"Buy" withAction:^{
                    u->buy(_fighterInfo);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [[StatusView GetInstance] loadUserInfo];
                    });
                    [AllyTableView ReloadData];
                }];
                [dialog addButtonWithText:@"Cancel" withAction:^{
                    // nothing
                }];
                [dialog show];
            }
            else
            {
                DialogView* dialog = [[[DialogView alloc] initWithMessage:@"You need more gold."] autorelease];
                [dialog addButtonWithText:@"OK" withAction:^{
                    // nothing
                }];
                [dialog show];
            }
            break;
        }
        ////////////////////
        // sell fighter
        case AllyViewModeSell:
        {
            hg::UserData* u = hg::UserData::sharedUserData();
            int cost = u->getSellValue(_fighterInfo);
            NSString* msg = [NSString stringWithFormat:@"Are you sure to sell this for %d Gold?", cost];
            DialogView* dialog = [[[DialogView alloc] initWithMessage:msg] autorelease];
            [dialog addButtonWithText:@"Sell" withAction:^{
                u->sell(_fighterInfo);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[StatusView GetInstance] loadUserInfo];
                });
                [AllyTableView ReloadData];
            }];
            [dialog addButtonWithText:@"Cancel" withAction:^{
                // nothing
            }];
            [dialog show];
            break;
        }
            ////////////////////
        // select fighter
        case AllyViewModeSelectPlayer:
        {
            hg::UserData* u = hg::UserData::sharedUserData();
            hg::FighterList fList = u->getFighterList();
            for (hg::FighterList::iterator it = fList.begin(); it != fList.end(); it++)
            {
                hg::FighterInfo* tmp = *it;
                if (tmp != _fighterInfo)
                {
                    tmp->isPlayer = false;
                }
                else
                {
                    _fighterInfo->isPlayer = true;
                    /*
                    if (_fighterInfo->isReady)
                    {
                        hg::UserData::sharedUserData()->setUnReady(_fighterInfo);
                    }*/
                }
            }
            [AllyTableView ReloadData];
            break;
        }
        default:
            assert(0);
    }
    [AllyTableView ReloadData];
}

- (void)setShowColor:(UIColor *)color
{
    //UIColor* lifeColor = [UIColor colorWithHexString:@"#269926"];
    UIColor* lifeColor = MAIN_FONT_COLOR;
    if (_fighterInfo->life == 0)
    {
        lifeColor = [UIColor colorWithHexString:@"#ff4040"];
    }
    else if ((double)_fighterInfo->life/(double)_fighterInfo->lifeMax<=0.5)
    {
        lifeColor = [UIColor colorWithHexString:@"#ffde40"];
    }
    [self setBackgroundColor:lifeColor];
    [self setBackgroundColor:[UIColor clearColor]];
    [self.layer setBorderColor:color.CGColor];
    [self.layer setBorderWidth:1];
    [backView setBackgroundColor:color];
    [backView setAlpha:0.5];
    for (id obj in labels)
    {
        UILabel* l = (UILabel*)obj;
        [l setTextColor:lifeColor];
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
        if (touchStart)
        {
            NSLog(@"show detail!");
            isShowDetail = true;
            AllyDetailView* adv = [[[AllyDetailView alloc] initWithFighterInfo:_fighterInfo] autorelease];
            [adv show];
        }
    }];
    isShowDetail = false;
    touchStart = [[NSDate date] timeIntervalSince1970];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchStart = 0;
    [highlightView setAlpha:0];
    [UIView animateWithDuration:0.20 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
        [self setTransform:t];
    } completion:^(BOOL finished) {
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    touchStart = 0;
    [highlightView setAlpha:0];
    [UIView animateWithDuration:0.20 animations:^{
        CGAffineTransform t = CGAffineTransformMakeScale(1.0, 1.0);
        [self setTransform:t];
    } completion:^(BOOL finished) {
    }];
}


@end
