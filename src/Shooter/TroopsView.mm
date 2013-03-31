#import "TroopsView.h"
#import "TroopCell.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <vector>

#define CARD_SEPARATOR 30.0
#define CARD_HEIGHT 115.0
#define CARD_WIDTH 200.0
#define CARD_COLOR [UIColor whiteColor]
#define NUMBER_OF_CARDS 5.0
#define CORNER_RADIUS 10.0

@interface TroopsView ()
{
    UITableView *troopsTableView;
}

@end

@implementation TroopsView

- (id)init
{
    self = [super init];
    if (self)
    {
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        CGRect viewFrame = CGRectMake(0, 0, frame.size.height, frame.size.width);
        [self setFrame:viewFrame];
        
        // table
        CGRect tframe = viewFrame;
        tframe.size.width = CARD_WIDTH;
        troopsTableView = [[UITableView alloc] initWithFrame:tframe style:UITableViewStylePlain];
        [troopsTableView setBackgroundColor:[UIColor clearColor]];
        troopsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        troopsTableView.dataSource = self;
        troopsTableView.delegate = self;
        
        [self addSubview:troopsTableView];
        
        [self initialize];
    }
    return self;
}

-(void)initialize
{
    
}

-(void)dealloc
{
    [super dealloc];
}

#pragma mark - TableView DataSource Implementation

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1; // or other number, that you want
}

////////////////////
// Returns the the height of the card and proper spacing between them.
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (CARD_HEIGHT + CARD_SEPARATOR);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    TroopCell *cell = (TroopCell *)[tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if (!cell) {
        cell = [[TroopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell" withHeight:CARD_HEIGHT withWidth:CARD_WIDTH withCornerRadius:CORNER_RADIUS withColor:CARD_COLOR];
    }
    
    [cell addContent];
    
    //This line makes the entire card unclickable. This is handy if you want to add clickable buttons within the card. If
    //you want the entire card to be clickable, remove this line and define UITableView's didSelectWithRowAtIndexPath method
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    /*
    static NSString *cellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.backgroundView = [[UIView alloc] init];
    [cell.backgroundView setBackgroundColor:[UIColor clearColor]];
    
    UILabel* lab = [[UILabel alloc] init];
    lab.text = @"tes";
    lab.textColor = [UIColor blueColor];
    [lab setBackgroundColor:[UIColor whiteColor]];
    lab.layer.cornerRadius = 10;
    [lab.layer setBorderColor:[[UIColor redColor] CGColor]];
    lab.frame = CGRectMake(0, 0, CARD_HEIGHT - 10, CARD_WIDTH - 10);
    [cell addSubview:lab];*/
    
    return cell;
}

@end
