//
//  ClearView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/08/25.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "CopyrightView.h"
#import "RRSGlowLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "DialogView.h"
#import "ImageButtonView.h"
#import "UIColor+MyCategory.h"
#import "Common.h"
#import "GlowLabel.h"
#import <sstream>
#import <stdlib.h>

@interface CopyrightView ()
{
    // action
    void (^onEndAction)();
    CGRect mainFrame;
    UITableView* tableView;
    CGSize rowSize;
    CopyrightMessageList reportMessageList;
}

@property(assign)CAEmitterLayer* emitterLayer;
@end

@implementation CopyrightView

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
            [lbl setText:NSLocalizedString(@"Credits", nil)];
            [lbl setFrame:CGRectMake(x, y, width, height)];
            [lbl setTextAlignment:NSTextAlignmentCenter];
            [lbl setBackgroundColor:[UIColor clearColor]];
            [lbl setTextColor:[UIColor colorWithHexString:@"#F7F7F7"]];
            [self addSubview:lbl];
        }
        
        // table
        float row_height = 25;
        rowSize.height = row_height;
        rowSize.width = mainFrame.size.width - 30;
        CGRect scrollFrame = CGRectMake(15, 55, rowSize.width, mainFrame.size.height - 75);
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
        reportMessageList.push_back({
            "BGM",
            "魔王魂様"
        });
        reportMessageList.push_back({
            "SE",
            "ザ・マッチメイカァズ様"
        });
        reportMessageList.push_back({
            "Ship 3D Model",
            "little killy様"
        });
        reportMessageList.push_back({
            "Icon Texture",
            "Lorc様"
        });
        reportMessageList.push_back({
            "Voice SE",
            "MrBeast様"
        });
        reportMessageList.push_back({
            "Boss Texture",
            "Paul Wortmann様"
        });
        
        
        
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
                [UIView animateWithDuration:0.5
                                 animations:^{
                                     [self setAlpha:0];
                                 } completion:^(BOOL finished) {
                                     [self setUserInteractionEnabled:FALSE];
                                     [UIView animateWithDuration:0.3 animations:^{
                                         [self setAlpha:0];
                                     }];
                                     if (onEndAction) {
                                         onEndAction();
                                     }
                                     [self removeFromSuperview];
                                 }];
            }];
        }
    
        [self setBackgroundColor:[UIColor blackColor]];

    }
    return self;
}

- (UILabel*)createLabel
{
    UILabel* lbl = [[[UILabel alloc] init] autorelease];
    UIFont* font = [UIFont fontWithName:@"HiraKakuProN-W6" size:16];
    [lbl setFont:font];
    [lbl setTextAlignment:NSTextAlignmentLeft];
    [lbl setBackgroundColor:[UIColor clearColor]];
    [lbl setTextColor:[UIColor blackColor]];
    [lbl setAdjustsFontSizeToFitWidth:YES];
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
    CopyrightMessage msg = reportMessageList[row];
    
    // title
    {
        
        CGRect frame = CGRectMake(0, 0, rowSize.width/2 - 50, rowSize.height);
        UIView* titleFrame = [[[UIView alloc] initWithFrame:frame] autorelease];
        [titleFrame setBackgroundColor:[UIColor colorWithHexString:@"#ffffff"]];
        [titleFrame.layer setBorderWidth:1];
        [titleFrame.layer setBorderColor:MAIN_BORDER_COLOR.CGColor];
        [c addSubview:titleFrame];
        
        frame.origin.x += 5;
        frame.origin.y += 3;
        UILabel* tlabel = [self createLabel];
        [tlabel setText:STR2NSSTR(msg.title)];
        [tlabel setFrame:frame];
        tlabel.adjustsFontSizeToFitWidth = YES;
        [c addSubview:tlabel];
        
    }
    // message
    {
        CGRect frame = CGRectMake(rowSize.width/2 - 50, 0, rowSize.width/2 + 50, rowSize.height);
        UIView* titleFrame = [[[UIView alloc] initWithFrame:frame] autorelease];
        [titleFrame setBackgroundColor:[UIColor clearColor]];
        [titleFrame.layer setBorderWidth:1];
        [titleFrame.layer setBorderColor:MAIN_BORDER_COLOR.CGColor];
        [c addSubview:titleFrame];
        UILabel* mlabel = [self createLabel];
        [mlabel setTextColor:[UIColor whiteColor]];
        
        frame.origin.x += 5;
        frame.origin.y += 3;
        [mlabel setText:STR2NSSTR(msg.message)];
        [mlabel setFrame:frame];
        mlabel.adjustsFontSizeToFitWidth = YES;
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
