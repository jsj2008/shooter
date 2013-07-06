//
//  AllyViewController.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/09.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "AllyTableView.h"
#import "TroopsView.h"
#import <QuartzCore/QuartzCore.h>
#import "HGame.h"
#import "UserData.h"
#import "UIColor+MyCategory.h"
#import "ImageButtonView.h"

@interface AllyTableView ()
{
    AllyViewMode viewMode;
    UITableView* allyTableView;
    
    // action
    void (^onEndAction)();
}

@end

@implementation AllyTableView

const int CELL_WIDTH = 130;
const int CELL_HEIGHT = 85;
const int CELL_GAP = 7;

int maxRowNum = 0;

CGRect frame;

- (id)initWithViewMode:(AllyViewMode)_viewMode WithFrame:(CGRect)_frame
{
    self = [super init];
    if (self)
    {
        frame = _frame;
        viewMode = _viewMode;
        [self viewDidLoad];
    }
    return self;
}

- (void) setOnEndAction:(void(^)(void))action
{
    onEndAction = [action copy];
}

- (void)dealloc
{
    if (onEndAction) [onEndAction release];
    [super dealloc];
}

- (void)viewDidLoad
{
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self setFrame:frame];
    
    UIView* tbCont = [[UIView alloc] initWithFrame: CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [tbCont setBackgroundColor:[UIColor clearColor]];
    //[tbCont setBackgroundColor:[UIColor redColor]];
    [self addSubview:tbCont];
    
    // テーブル
    CGRect scrollFrame = CGRectMake(0, 0, frame.size.height, frame.size.width);
    UITableView* tbv = [[UITableView alloc] initWithFrame:scrollFrame];
    [tbv setBackgroundColor:[UIColor clearColor]];
    [tbv setRowHeight:150];
    [tbv setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tbv setEditing:false];
    [tbv setTableHeaderView:nil];
    [tbv setTableFooterView:nil];
    tbv.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    tbv.delegate = self;
    tbv.dataSource = self;
    //[tbv setBackgroundColor:[UIColor blackColor]];
    [tbv setTransform:CGAffineTransformRotate(CGAffineTransformIdentity, -90*M_PI/180)];
    [tbv setCenter:CGPointMake(tbCont.frame.size.width/2, tbCont.frame.size.height/2)];
    allyTableView = tbv;
    [tbCont addSubview:tbv];
    
    // calc max row num
    maxRowNum = (int)(frame.size.height / (CELL_HEIGHT + CELL_GAP));
    
    // 戻るボタン
    {
        ImageButtonView* backImgView = [[ImageButtonView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)];
        UIImage* img = [UIImage imageNamed:@"checkmark.png"];
        
        [backImgView setBackgroundColor:[UIColor whiteColor]];
        [backImgView setFrame:CGRectMake(frame.size.width - 76, frame.size.height - 84, 66, 66)];
        [backImgView.layer setCornerRadius:8];
        [backImgView.layer setBorderColor:[UIColor colorWithHexString:@"#222222"].CGColor];
        [backImgView.layer setBorderWidth:3];
        
        [backImgView setImage:img];
        [backImgView setContentMode:UIViewContentModeScaleAspectFit];
        [backImgView setUserInteractionEnabled:YES];
        
        [self addSubview:backImgView];
        
        [backImgView setOnTapAction:^(ImageButtonView *target) {
            //[self removeFromSuperview];
            [self setUserInteractionEnabled:FALSE];
            [backImgView setUserInteractionEnabled:FALSE];
            onEndAction();
            NSLog(@"onEnd");
        }];
    }
    
    [self setBackgroundColor:[UIColor clearColor]];
}


/*
 ロード時に呼び出される。
 セクションに含まれるセル数を返すように実装する
 （実装必須）
 */
-(NSInteger)tableView:(UITableView *)tableView
numberOfRowsInSection:(NSInteger)section
{
    hg::FighterList list = hg::UserData::sharedUserData()->getFighterList();
    int rows = (int)(list.size()/maxRowNum) + 1 + 1;
    return rows;
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
 -(UITableViewCell *)tableView:
 (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath	ロード時に呼び出される。
 セルの内容を返すように実装する
 （実装必須）
 */
-(UITableViewCell *)tableView:
(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* c = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, CELL_HEIGHT, CELL_WIDTH)] autorelease];
    [c setBackgroundColor:[UIColor clearColor]];
    [c setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // 枠
    int y = frame.size.height - CELL_HEIGHT - CELL_GAP;
    hg::FighterList fList = hg::UserData::sharedUserData()->getFighterList();
    for (int i = 0; i < maxRowNum; i++)
    {
        int index = i + [indexPath row] * maxRowNum;
        if (fList.size() <= index)
        {
            break;
        }
        hg::FighterInfo* fInfo = fList[index];
        
        // セルコンテナ
        AllyView* v = [[[AllyView alloc] initWithAllyViewMode:viewMode WithFrame:CGRectMake(y, 0, CELL_HEIGHT, CELL_WIDTH)] autorelease];
        [v setFighterInfo:fInfo];
        [c addSubview:v];
        
        y -= (CELL_HEIGHT + CELL_GAP);
    }
    return c;
}

/*
 セクションヘッダーの高さを返すように実装する
 */
-(CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section
{
    return 0;
}


@end
