//
//  ClearView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/08/25.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "ReportView.h"
#import "RRSGlowLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "DialogView.h"
#import "ImageButtonView.h"
#import "UIColor+MyCategory.h"
#import "Common.h"
#import "UserData.h"
#import "GlowLabel.h"
#import <sstream>
#import <stdlib.h>
#import "MainViewController.h"

@interface ReportView ()
{
    // action
    void (^onEndAction)();
    CGRect mainFrame;
    UITableView* tableView;
    CGSize rowSize;
    ReportMessageList reportMessageList;
}

@property(assign)CAEmitterLayer* emitterLayer;
@end

@implementation ReportView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAlpha:0];
        [UIView animateWithDuration:0.5 animations:^{
            [self setAlpha:1];
        }];
        mainFrame = frame;
        
        // back image
        float width = frame.size.width;
        //float height = width * (float)(512.0/512.0);
        float height = frame.size.height;
        float x = 0;
        float y = 0;
        //UIImage *img = [UIImage imageNamed:@"report_background.jpg"];
        //UIImage *img = [UIImage imageNamed:@"metal_back2.jpg"];
        /*
        NSString *path = [[NSBundle mainBundle] pathForResource:@"metal_back2" ofType:@"png"];
        UIImage* img = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
        UIImageView* backView = [[[UIImageView alloc] initWithFrame:CGRectMake(x,y,width,height)] autorelease];
        [backView setImage:img];
        [backView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [backView setUserInteractionEnabled:true];
        [self addSubview:backView];*/
        
        /*
        // tap
        {
            double delayInSeconds = 3.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                UITapGestureRecognizer *tr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)] autorelease];
                [backView addGestureRecognizer:tr];
            });
        }*/
        
        // title
        {
            float height = 60;
            float width = mainFrame.size.width;
            float x = 0;
            float y = 0;
            RRSGlowLabel* lbl = [[[RRSGlowLabel alloc] init] autorelease];
            [lbl setGlowAmount:10];
            [lbl setGlowColor:[UIColor colorWithHexString:@"ffffff"]];
            UIFont* font = [UIFont fontWithName:@"HiraKakuProN-W6" size:40];
            [lbl setFont:font];
            [lbl setText:NSLocalizedString(@"Battle Result", nil)];
            [lbl setFrame:CGRectMake(x, y, width, height)];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setTextColor:[UIColor colorWithHexString:@"#F7F7F7"]];
            [self addSubview:lbl];
            /*
            float height = 60;
            float width = height*(288/94);
            float x = mainFrame.size.width/2 - width/2;
            float y = 5;
            UIImage *img = [UIImage imageNamed:@"result.png"];
            UIImageView* imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(x,y,width,height)] autorelease];
            [imgView setImage:img];
            [imgView setFrame:CGRectMake(x, y, width, height)];
            [self addSubview:imgView];
             */
        }
        
        float adheight = 0;
        
        // admob
        if (IS_REPORT_VIEW_ADMOB)
        {
            // admob
            GADBannerView* ad = [MainViewController CreateGADBannerView];
            [self addSubview:ad];
            CGRect r = ad.frame;
            r.origin.x = mainFrame.size.width/2 - r.size.width/2;
            r.origin.y = mainFrame.size.height - r.size.height;
            [ad setFrame:r];
            adheight = r.size.height;
        }
        
        // table
        float row_height = 25;
        rowSize.height = row_height;
        rowSize.width = mainFrame.size.width - 30;
        CGRect scrollFrame = CGRectMake(15, 55, rowSize.width, mainFrame.size.height - 75 - (adheight + 5));
        UITableView* tbv = [[UITableView alloc] initWithFrame:scrollFrame];
        [tbv setBackgroundColor:[UIColor clearColor]];
        [tbv setRowHeight:row_height];
        [tbv setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [tbv setEditing:false];
        [tbv setTableHeaderView:nil];
        [tbv setTableFooterView:nil];
        tbv.indicatorStyle = UIScrollViewIndicatorStyleBlack;
        tbv.delegate = self;
        tbv.dataSource = self;
        [tbv setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
        [tbv setPagingEnabled:NO];
        tableView = tbv;
        [self addSubview:tbv];
        
        // init messages
        reportMessageList.clear();
        hg::BattleResult battleResult = hg::UserData::sharedUserData()->getLatestBattleResult();
        {
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Result", nil)),
                ""
            };
            if (battleResult.isWin) {
                r.message = NSSTR2STR(NSLocalizedString(@"WIN", nil));
            } else if (battleResult.isRetreat) {
                r.message = NSSTR2STR(NSLocalizedString(@"RETREAT", nil));
            } else {
                r.message = NSSTR2STR(NSLocalizedString(@"LOSE", nil));
            }
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            if (battleResult.battleScore > 0) {
                ss << "+";
            }
            ss << battleResult.battleScore << NSSTR2STR(NSLocalizedString(@" Pt", nil));
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Score", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss <<  battleResult.earnedMoney << NSSTR2STR(NSLocalizedString(@" Gold", nil));
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Reward", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << battleResult.allShotMoney << NSSTR2STR(NSLocalizedString(@" Gold", nil));
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Ammo Cost", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            if (battleResult.finalIncome >= 0) {
                ss << "+" << battleResult.finalIncome << NSSTR2STR(NSLocalizedString(@" Gold", nil));
            }
            else {
                ss << battleResult.finalIncome << NSSTR2STR(NSLocalizedString(@" Gold", nil));
            }
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Total Balance", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << battleResult.killedEnemy;
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Destroyed Enemy", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << battleResult.killedFriend;
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Destroyed Friend", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << battleResult.myShot;
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Ammo Used", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << battleResult.myHit;
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Hits", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::string msg = "-";
            if (battleResult.myShot > 0) {
                char ch[100];
                sprintf(ch, "%0.2f%%", ((float)battleResult.myHit/(float)battleResult.myShot*100.0));
                msg = std::string(ch);
            }
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Hit Ratio", nil)),
                msg
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << battleResult.allShot;
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Team Ammo Used", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << battleResult.allHit;
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Team Hits", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::string msg = "-";
            if (battleResult.allShot > 0) {
                char ch[100];
                sprintf(ch, "%0.2f%%", ((float)battleResult.allHit/(float)battleResult.allShot*100.0));
                msg = std::string(ch);
            }
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Team Hit Ratio", nil)),
                msg
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << battleResult.enemyShot;
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Enemy's Ammo Used", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << battleResult.enemyHit;
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Enemy's Total Hits", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::string msg = "-";
            if (battleResult.enemyShot > 0) {
                char ch[100];
                sprintf(ch, "%0.2f%%", ((float)battleResult.enemyHit/(float)battleResult.enemyShot*100.0));
                msg = std::string(ch);
            }
            ReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Enemy's Hit Ratio", nil)),
                msg
            };
            reportMessageList.push_back(r);
        }
        // 戻るボタン
        {
            ImageButtonView* backImgView = [[[ImageButtonView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)] autorelease];
            //UIImage* img = [UIImage imageNamed:@"checkmark.png"];
            NSString *path = [[NSBundle mainBundle] pathForResource:ICON_CHECK ofType:@"png"];
            UIImage* img = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
            
            [backImgView setBackgroundColor:[UIColor whiteColor]];
            [backImgView setFrame:CGRectMake(mainFrame.size.width - 76, mainFrame.size.height - 84, 66, 66)];
            [backImgView.layer setCornerRadius:8];
            [backImgView.layer setBorderColor:[UIColor colorWithHexString:@"#ffffff"].CGColor];
            [backImgView.layer setBorderWidth:0.5];
            
            [backImgView setImage:img];
            [backImgView setContentMode:UIViewContentModeScaleAspectFit];
            [backImgView setUserInteractionEnabled:YES];
            
            [self addSubview:backImgView];
            
            [backImgView setOnTapAction:^(ImageButtonView *target) {
                [self setUserInteractionEnabled:FALSE];
                [UIView animateWithDuration:0.3 animations:^{
                    [self setAlpha:0];
                }];
                onEndAction();
            }];
        }
        // cover
        {
            UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [v setBackgroundColor:[UIColor blackColor]];
            [v setUserInteractionEnabled:YES];
            [self addSubview:v];
            [UIView animateWithDuration:0.7 animations:^{
                [v setAlpha:0];
            } completion:^(BOOL finished) {
                [v removeFromSuperview];
            }];
        }
        
        [self setBackgroundColor:[UIColor blackColor]];

    }
    return self;
}

- (UILabel*)createLabel
{
    UILabel* lbl = [[[UILabel alloc] init] autorelease];
    //UIFont* font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16];
    UIFont* font = [UIFont systemFontOfSize:16];
    [lbl setFont:font];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:MAIN_FONT_COLOR];
    [lbl setAdjustsFontSizeToFitWidth:YES];
    /*
    [lbl setTransform:CGAffineTransformTranslate(CGAffineTransformIdentity, 1, 0)];
    [UIView animateWithDuration:0.3 animations:^{
        [lbl setTransform:CGAffineTransformTranslate(CGAffineTransformIdentity, 1, 1)];
    }];*/
    return lbl;
}

- (void)onTap:(UIGestureRecognizer*)sender
{
    [self setUserInteractionEnabled:false];
    [UIView animateWithDuration:0.5 animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        if (onEndAction) {
            onEndAction();
        }
    }];
}

- (void)dealloc
{
    if (onEndAction) [onEndAction release];
    if(tableView)
    {
        [tableView release];
        tableView = nil;
    }
    [super dealloc];
}

- (void) setOnEndAction:(void(^)(void))action
{
    onEndAction = [action copy];
}

/*
 ロード時に呼び出される。
 セクションに含まれるセル数を返すように実装する
 （実装必須）
 */
-(NSInteger)tableView:(UITableView *)tableView
numberOfRowsInSection:(NSInteger)section
{
    return reportMessageList.size();
}

/*
 ロード時に呼び出される。
 セクション数を返すように実装する
 */
-(NSInteger)numberOfSectionsInTableView:
(UITableView *)tableView
{
    return 1;
}

/*
 セクションヘッダーの高さを返すように実装する
 */
-(CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

/*
 -(UITableViewCell *)tableView:
 (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath	ロード時に呼び出される。
 セルの内容を返すように実装する
 （実装必須）
 */
-(UITableViewCell *)tableView:
(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* c = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, rowSize.width, rowSize.height)] autorelease];
    [c setBackgroundColor:[UIColor clearColor]];
    [c setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // 情報
    int row = [indexPath row];
    ReportMessage msg = reportMessageList[row];
    
    // title
    {
        
        CGRect frame = CGRectMake(0, 0, rowSize.width/2, rowSize.height);
        UIView* titleFrame = [[[UIView alloc] initWithFrame:frame] autorelease];
        [titleFrame setBackgroundColor:[UIColor colorWithHexString:@"#18394c"]];
        [titleFrame.layer setBorderWidth:1];
        [titleFrame.layer setBorderColor:MAIN_BORDER_COLOR.CGColor];
        [c addSubview:titleFrame];
        
        frame.origin.x += 5;
        frame.origin.y += 3;
        UILabel* tlabel = [self createLabel];
        [tlabel setText:STR2NSSTR(msg.title)];
        [tlabel setFrame:frame];
        [c addSubview:tlabel];
        tlabel.adjustsFontSizeToFitWidth = true;
        
    }
    // message
    {
        CGRect frame = CGRectMake(rowSize.width/2, 0, rowSize.width/2, rowSize.height);
        UIView* titleFrame = [[[UIView alloc] initWithFrame:frame] autorelease];
        [titleFrame setBackgroundColor:[UIColor clearColor]];
        [titleFrame.layer setBorderWidth:1];
        [titleFrame.layer setBorderColor:MAIN_BORDER_COLOR.CGColor];
        [c addSubview:titleFrame];
        UILabel* mlabel = [self createLabel];
        
        frame.origin.x += 5;
        frame.origin.y += 3;
        [mlabel setText:STR2NSSTR(msg.message)];
        [mlabel setFrame:frame];
        [c addSubview:mlabel];
        mlabel.adjustsFontSizeToFitWidth = true;
    }
    
    return c;
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
