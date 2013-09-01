//
//  AllyViewController.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/09.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "Common.h"
#import "StageTableView.h"
#import <QuartzCore/QuartzCore.h>
#import "HGame.h"
#import "UserData.h"
#import "UIColor+MyCategory.h"
#import "ImageButtonView.h"
#import "DialogView.h"
#import "MainViewController.h"
#import "StatusView.h"

@interface StageTableView ()
{
    UITableView* tableView;
    
    // action
    void (^onEndAction)();
    
    CGRect myFrame;
    
    float cell_width;
    float cell_height;
    
}

@end

@implementation StageTableView

static StageTableView* instance;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        myFrame = frame;
        CGRect appFrame = [UIScreen mainScreen].bounds;
        cell_width = appFrame.size.height - 40;
        cell_height = 44;
        [self viewDidLoad];
        instance = self;
    }
    return self;
}

+ (void)EndView
{
    if (instance)
    {
        [instance endView];
    }
}

- (void)endView
{
    [self setUserInteractionEnabled:FALSE];
    onEndAction();
}

+ (void)ReloadData
{
    if (instance)
    {
        [instance reloadData];
    }
}

- (void)reloadData
{
    [tableView reloadData];
}

- (void) setOnEndAction:(void(^)(void))action
{
    onEndAction = [action copy];
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

- (void)viewDidLoad
{
    
    [self setBackgroundColor:[UIColor clearColor]];
    
    [self setFrame:myFrame];
    
    UIView* tbCont = [[UIView alloc] initWithFrame: CGRectMake(0, StatusViewHeight, myFrame.size.width, myFrame.size.height - (StatusViewHeight + 30))];
    [tbCont setBackgroundColor:[UIColor clearColor]];
    //[tbCont setBackgroundColor:[UIColor redColor]];
    [self addSubview:tbCont];
    
    // テーブル
    CGRect scrollFrame = CGRectMake(0, 0, myFrame.size.width, myFrame.size.height);
    UITableView* tbv = [[UITableView alloc] initWithFrame:scrollFrame];
    [tbv setBackgroundColor:[UIColor clearColor]];
    //[tbv setBackgroundColor:[UIColor redColor]];
    [tbv setRowHeight:cell_height+2];
    [tbv setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tbv setEditing:false];
    [tbv setTableHeaderView:nil];
    [tbv setTableFooterView:nil];
    tbv.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    tbv.delegate = self;
    tbv.dataSource = self;
    [tbv setCenter:CGPointMake(tbCont.frame.size.width/2, tbCont.frame.size.height/2 + tbCont.frame.origin.y)];
    [tbv setIndicatorStyle:UIScrollViewIndicatorStyleWhite];
    [tbv setPagingEnabled:NO];
    tableView = tbv;
    [tbCont addSubview:tbv];
    
    // 戻るボタン
    {
        ImageButtonView* backImgView = [[[ImageButtonView alloc] initWithFrame:CGRectMake(0, 0, 66, 66)] autorelease];
        //UIImage* img = [UIImage imageNamed:@"checkmark.png"];
        NSString *path = [[NSBundle mainBundle] pathForResource:ICON_CHECK ofType:@"png"];
        UIImage* img = [[[UIImage alloc] initWithContentsOfFile:path] autorelease];
        
        [backImgView setBackgroundColor:[UIColor whiteColor]];
        [backImgView setFrame:CGRectMake(myFrame.size.width - 76, myFrame.size.height - 84, 66, 66)];
        [backImgView.layer setCornerRadius:8];
        [backImgView.layer setBorderColor:[UIColor colorWithHexString:@"#ffffff"].CGColor];
        [backImgView.layer setBorderWidth:0.5];
        
        [backImgView setImage:img];
        [backImgView setContentMode:UIViewContentModeScaleAspectFit];
        [backImgView setUserInteractionEnabled:YES];
        
        [self addSubview:backImgView];
        
        [backImgView setOnTapAction:^(ImageButtonView *target) {
            [self setUserInteractionEnabled:FALSE];
            onEndAction();
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
    return hg::UserData::sharedUserData()->getStageNum();
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
    UITableViewCell* c = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, cell_width + 40, cell_height)] autorelease];
    [c setBackgroundColor:[UIColor clearColor]];
    [c setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    // stage情報をビューに貼付ける
    hg::StageInfo info = hg::UserData::sharedUserData()->getStageInfo([indexPath row] + 1);
    
    // 背景
    ImageButtonView* back = [[[ImageButtonView alloc] initWithFrame:CGRectMake(20, 0, cell_width, cell_height)] autorelease];
    //UIView* back = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, cell_width, cell_height)] autorelease];
    //[back setBackgroundColor:SUB_BACK_COLOR];
    [back.layer setBorderColor: MAIN_BORDER_COLOR.CGColor];
    back.layer.borderWidth = 1;
    [back setUserInteractionEnabled:YES];
    [c addSubview:back];
    
    // stage番号
    UILabel* stageLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 0, cell_width, cell_height)];
    [stageLabel setBackgroundColor:[UIColor clearColor]];
    [stageLabel setTextColor:MAIN_FONT_COLOR];
    [stageLabel setText:[NSString stringWithCString:info.stage_name.c_str() encoding:NSUTF8StringEncoding]];
    [stageLabel autorelease];
    [back addSubview:stageLabel];
    [back setTag:[indexPath row] + 1];
    
    { // clear count
        UILabel* l = [[UILabel alloc] initWithFrame:CGRectMake(cell_width/2, 0, cell_width, cell_height)];
        [l setBackgroundColor:[UIColor clearColor]];
        [l setTextColor:MAIN_FONT_COLOR];
        [l setText:[NSString stringWithFormat:@"Cleared Count: %d", info.clear_count]];
        [l autorelease];
        [back addSubview:l];
    }
    
    // 選択時の処理
    [back setOnTapAction:^(ImageButtonView *target) {
        int stage_id = target.tag;
        hg::StageInfo info = hg::UserData::sharedUserData()->getStageInfo(stage_id);
        bool chk = true;
        if (stage_id > 1) {
            hg::StageInfo info_pre = hg::UserData::sharedUserData()->getStageInfo(stage_id - 1);
            if (info_pre.clear_count == 0) {
                chk = false;
                NSString* msg = [[NSString stringWithFormat:@"Soryy, You must clear %@ Stage at first.", [NSString stringWithCString:info_pre.stage_name_short.c_str() encoding:NSUTF8StringEncoding]] autorelease];
                DialogView* dv = [[DialogView alloc] initWithMessage:msg];
                [dv addButtonWithText:@"OK" withAction:^{
                    // do nothing
                }];
                [dv show];
            }
        }
        if (stage_id == hg::UserData::sharedUserData()->getStageInfo().stage_id) {
            chk = false;
        }
        if (!(chk == false && !IS_DEBUG_SHOOTER)) {
            
            NSString* msg = [[NSString stringWithFormat:@"Go to %@ Stage?", [NSString stringWithCString:info.stage_name_short.c_str() encoding:NSUTF8StringEncoding]] autorelease];
            DialogView* dv = [[DialogView alloc] initWithMessage:msg];
            [dv addButtonWithText:@"OK" withAction:^{
                [self setUserInteractionEnabled:FALSE];
                onEndAction();
                hg::UserData::sharedUserData()->setStageId(stage_id);
                hg::UserData::sharedUserData()->saveData();
                //[MainViewController RemoveBackgroundView];
                //[MainViewController ShowBackgroundView];
                StatusView* sv = [StatusView GetInstance];
                if (sv) {
                    [sv loadUserInfo];
                }
            }];
            [dv addButtonWithText:@"Cancel" withAction:^{
            }];
            [dv show];
        }
    }];
    
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
