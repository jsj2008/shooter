#import "TroopsView.h"
#import "TroopCell.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <vector>

#define CARD_SEPARATOR 30.0
#define CARD_HEIGHT 115.0
//#define CARD_WIDTH 300.0
#define CARD_COLOR [UIColor whiteColor]
#define NUMBER_OF_CARDS 5.0
#define CORNER_RADIUS 10.0

typedef enum T_TRP_BTN
{
    TRP_USETHIS_BTN,
    TRP_BATTLE_BTN,
    TRP_BACK_BTN,
    TRP_BTN_NUM
} T_TRP_BTN;

typedef struct t_trp_btn
{
    NSString* btnName;
} t_title_btn;

t_trp_btn trp_btn_info[] = {
    {
        @"player"
    },
    {
        @"cpu"
    },
    {
        @"back"
    },
};

@interface TroopsView ()
{
    UITableView *troopsTableView;
    TroopCell *currentCell;
}

@end

@implementation TroopsView

- (id)init
{
    self = [super init];
    if (self)
    {
        currentCell = nil;
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        CGRect viewFrame = CGRectMake(0, 0, frame.size.height, frame.size.width);
        [self setFrame:viewFrame];
        
        // table
        CGRect tframe = viewFrame;
        tframe.size.width = viewFrame.size.width - 100;//width of btnCont
        troopsTableView = [[UITableView alloc] initWithFrame:tframe style:UITableViewStylePlain];
        [troopsTableView setBackgroundColor:[UIColor clearColor]];
        troopsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        troopsTableView.dataSource = self;
        troopsTableView.delegate = self;
        
        [self addSubview:troopsTableView];
        
        // button cont
        UIView* btnCont = [[UIView alloc] initWithFrame:CGRectMake(viewFrame.size.width - 60, 10, 50, viewFrame.size.height - 20)];
        [btnCont setBackgroundColor:[UIColor clearColor]];
        [self addSubview:btnCont];
        
        // buttons
        for (int i = 0; i < TRP_BTN_NUM; ++i)
        {
            t_trp_btn info = trp_btn_info[i];
            UIButton* b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
            [b setFrame: CGRectMake(0, i*50+i*10, 50, 50)];
            [b setTag:i];
            [b setTitle:info.btnName forState:UIControlStateNormal];
            [b setTitle:info.btnName forState:UIControlStateDisabled];
            [b setTitle:info.btnName forState:UIControlStateHighlighted];
            [b setTitle:info.btnName forState:UIControlStateSelected];
            [b addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [btnCont addSubview:b];
        }
    }
    return self;
}

-(void)buttonPressed:(UIButton*)button
{
    switch (button.tag) {
        case TRP_BACK_BTN:
            [MainViewController HideTroops];
            break;
        case TRP_USETHIS_BTN:
        {
            if (!currentCell) break;
            // データ更新
            using namespace HGGame::userinfo;
            for (t_fighter_list::iterator itr = current_fighter_list->begin(); itr != current_fighter_list->end(); ++itr)
            {
                t_fighter* f = &(*itr);
                f->player = 0;
            }
            
            //カスタムセルをリフレッシュ
            for (NSInteger j = 0; j < [troopsTableView numberOfSections]; ++j)
            {
                for (NSInteger i = 0; i < [troopsTableView numberOfRowsInSection:j]; ++i)
                {
                    TroopCell *c = (TroopCell *) [troopsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
                    if (c)
                    {
                        [c refresh];
                    }
                }
            }
            currentCell.data->player = 1;
            [currentCell refresh];
        }
            break;
        case TRP_BATTLE_BTN:
        {
            if (!currentCell) break;
            if (currentCell.data->player > 0)
            {
                break;
            }
            if (currentCell.data->battle > 0)
            {
                currentCell.data->battle = 0;
            }
            else
            {
                currentCell.data->battle = 1;
            }
            [currentCell refresh];
        }
            break;
        default:
            break;
    }
    
}

-(void)dealloc
{
    if (currentCell)
    {
        [currentCell release];
        currentCell = nil;
    }
        
    [super dealloc];
}

#pragma mark - TableView DataSource Implementation

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return HGGame::userinfo::current_fighter_list->size();
}

////////////////////
// Returns the the height of the card and proper spacing between them.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (CARD_HEIGHT + CARD_SEPARATOR);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
#warning 再利用コード
    /*
    TroopCell *cell = (TroopCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[[TroopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell" withHeight:CARD_HEIGHT withWidth:CARD_WIDTH withCornerRadius:CORNER_RADIUS withColor:CARD_COLOR] autorelease];
    }*/
    
    HGGame::userinfo::t_fighter* data = &(*HGGame::userinfo::current_fighter_list)[indexPath.row];
    TroopCell* cell = [[TroopCell alloc] initWithReuseIdentifier:@"UITableViewCell" withHeight:CARD_HEIGHT withWidth:troopsTableView.frame.size.width withData:data];
    [cell addContent];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //カスタムセルの選択状態を解除
    for (NSInteger j = 0; j < [tableView numberOfSections]; ++j)
    {
        for (NSInteger i = 0; i < [tableView numberOfRowsInSection:j]; ++i)
        {
            TroopCell *c = (TroopCell *) [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:j]];
            [c setBackgroundColor:[UIColor clearColor]];
        }
    }
    //セルの情報を取り出す
    TroopCell *cell = (TroopCell *)[tableView cellForRowAtIndexPath:indexPath];
    [cell setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0.5 alpha:0.5]];
    if (currentCell)
    {
        [currentCell release];
        currentCell = nil;
    }
    currentCell = [cell retain];
}


@end
