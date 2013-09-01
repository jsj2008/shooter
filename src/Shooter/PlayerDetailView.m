//
//  ClearView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/08/25.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "PlayerDetailView.h"
#import <QuartzCore/QuartzCore.h>
#import "DialogView.h"
#import "ImageButtonView.h"
#import "UIColor+MyCategory.h"
#import "Common.h"
#import "UserData.h"
#import "GlowLabel.h"
#import "RRSGlowLabel.h"
#import <sstream>
#import <stdlib.h>

@interface PlayerDetailView()
{
    // action
    //void (^onEndAction)();
    CGRect mainFrame;
    CGRect hideFrame;
    UITableView* tableView;
    CGSize rowSize;
    PlayerReportMessageList reportMessageList;
    UILabel* gradeLabel;
}

@property(assign)CAEmitterLayer* emitterLayer;
@end

@implementation PlayerDetailView

#define PULL_BUTTON_HEIGHT 35

- (id)initWithFrame:(CGRect)frame
{
    mainFrame = frame;
    CGRect defFrame = mainFrame;
    defFrame.origin.y = frame.size.height * -1;
    defFrame.size.height += PULL_BUTTON_HEIGHT;
    hideFrame = defFrame;
    self = [super initWithFrame:defFrame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAlpha:0];
        [UIView animateWithDuration:0.5 animations:^{
            [self setAlpha:1];
        }];
        
        // back
        {
            UIView* backgroundView = [[UIView alloc] initWithFrame:frame];
            [backgroundView setBackgroundColor:[UIColor colorWithHexString:@"#080b0a"]];
            [self addSubview:backgroundView];
        }
        
        // button
        {
            CGRect pullFrame = CGRectMake(mainFrame.size.width/2 - 74, mainFrame.size.height - 10, 128, PULL_BUTTON_HEIGHT + 10);
            UIView* pullButton = [[UIView alloc] initWithFrame:pullFrame];
            [self addSubview:pullButton];
            [pullButton setBackgroundColor:[UIColor colorWithHexString:@"#000000"]];
            [pullButton.layer setCornerRadius:10];
            [pullButton.layer setBorderWidth:1];
            [pullButton.layer setBorderColor:[UIColor colorWithHexString:@"#444444"].CGColor];
             
            // label
            {
                CGRect lblFrame = CGRectMake(5, 20, pullFrame.size.width - 10, pullFrame.size.height - 20);
                UILabel* lbl = [self createLabel];
                gradeLabel = lbl;
                [gradeLabel retain];
                [gradeLabel setTextAlignment:NSTextAlignmentCenter];
                [pullButton addSubview:lbl];
                [lbl setFrame:lblFrame];
                //[gradeLabel setUserInteractionEnabled:NO];
            }
            
            // tap
            {
                UITapGestureRecognizer *tr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)] autorelease];
                [pullButton addGestureRecognizer:tr];
            }
        }
        
        // back img
        {
            
            float width = frame.size.width;
            //float height = width * (float)(800.0/600.0);
            float height = frame.size.height;
            float x = 0;
            float y = 0;
            //UIImage *img = [UIImage imageNamed:@"metal_back2.jpg"];
            
            /*
            NSString *path = [[NSBundle mainBundle] pathForResource:@"metal_back2" ofType:@"png"];
            UIImage* img = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
            
            UIImageView* backView = [[[UIImageView alloc] initWithFrame:CGRectMake(x,y,width,height)] autorelease];
            [backView setImage:img];
            [backView setUserInteractionEnabled:true];
            [self addSubview:backView];
             */
            UIView* backView = [[[UIView alloc] initWithFrame:CGRectMake(x,y,width,height)] autorelease];
            [backView setBackgroundColor:[UIColor blackColor]];
            [backView setUserInteractionEnabled:true];
            [self addSubview:backView];
            
        }
        
        
        // title
        {
            float height = 60;
            float width = height*(422/94);
            float x = mainFrame.size.width/2 - width/2;
            float y = 20;
            RRSGlowLabel* lbl = [[[RRSGlowLabel alloc] init] autorelease];
            [lbl setGlowAmount:10];
            [lbl setGlowColor:[UIColor colorWithHexString:@"ffffff"]];
            UIFont* font = [UIFont fontWithName:@"HiraKakuProN-W6" size:40];
            [lbl setFont:font];
            [lbl setText:NSLocalizedString(@"Statistics", nil)];
            [lbl setFrame:CGRectMake(x, y, width, height)];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setTextColor:[UIColor colorWithHexString:@"#F7F7F7"]];
            [self addSubview:lbl];
            /*
            UIImage *img = [UIImage imageNamed:@"statistics.png"];
            UIImageView* imgView = [[[UIImageView alloc] initWithFrame:CGRectMake(x,y,width,height)] autorelease];
            [imgView setImage:img];
            [imgView setFrame:CGRectMake(x, y, width, height)];
            [self addSubview:imgView];*/
        }
        
        // table
        float row_height = 25;
        rowSize.height = row_height;
        rowSize.width = mainFrame.size.width - 30;
        CGRect scrollFrame = CGRectMake(15, 75, rowSize.width, mainFrame.size.height - 75);
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
        
        hg::UserData* userData = hg::UserData::sharedUserData();
        {
            std::stringstream ss;
            ss << userData->getTotalScore();
            PlayerReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Total Score", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            PlayerReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Rank", nil)),
                userData->getGrade()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << userData->getMaxAllyNum();
            PlayerReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Max Units", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << userData->getSumValue();
            PlayerReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Total Value of Units", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << userData->getWinCount();
            PlayerReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Total Win Count", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << userData->getLoseCount();
            PlayerReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Total Lose Count", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << userData->getRetreatCount();
            PlayerReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Total Retreat Count", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << userData->getTotalKill();
            PlayerReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Total Destroyed Enemy", nil)),
                ss.str()
            };
            reportMessageList.push_back(r);
        }
        {
            std::stringstream ss;
            ss << userData->getTotalDead();
            PlayerReportMessage r = {
                NSSTR2STR(NSLocalizedString(@"Total Destroyed Friend", nil)),
                ss.str()
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
                [UIView animateWithDuration:0.3 animations:^{
                    self.frame = hideFrame;
                }];
                //onEndAction();
            }];
        }
    
        [self setBackgroundColor:[UIColor clearColor]];

    }
    return self;
}

- (void)loadGrade
{
    std::string grade = hg::UserData::sharedUserData()->getGrade();
    if (gradeLabel) {
        [gradeLabel setText:STR2NSSTR(grade)];
        //[gradeLabel setText:@"Highest Admiral afallse"];
    }
}

- (UILabel*)createLabel
{
    UILabel* lbl = [[[UILabel alloc] init] autorelease];
    UIFont* font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16];
    [lbl setFont:font];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:MAIN_FONT_COLOR];
    [lbl setAdjustsFontSizeToFitWidth:YES];
    //[lbl setTransform:CGAffineTransformTranslate(CGAffineTransformIdentity, 1, 0)];
    /*
    [UIView animateWithDuration:0.3 animations:^{
        [lbl setTransform:CGAffineTransformTranslate(CGAffineTransformIdentity, 1, 1)];
    }];*/
    return lbl;
}

- (void)onTap:(UIGestureRecognizer*)sender
{
    CGRect frame = mainFrame;
    frame.origin.y = 0;
    [UIView animateWithDuration:0.5 animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
    }];
}

- (void)dealloc
{
    //if (onEndAction) [onEndAction release];
    if(tableView)
    {
        [tableView release];
        tableView = nil;
    }
    if (gradeLabel)
    {
        [gradeLabel release];
        gradeLabel = nil;
    }
    [super dealloc];
}

/*
- (void) setOnEndAction:(void(^)(void))action
{
    onEndAction = [action copy];
}*/

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
    PlayerReportMessage msg = reportMessageList[row];
    
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
        mlabel.adjustsFontSizeToFitWidth = true;
        [c addSubview:mlabel];
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
