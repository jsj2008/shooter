//
//  CardListCell.m
//  ARC enabled
//  Created by Hooman Ahmadi on 7/18/12.
/*

#import "TroopCell.h"
#import <QuartzCore/QuartzCore.h>
#import "HGCPU.h"

@interface TroopCell()
{
    UILabel *cardTitle;
    int cardHeight;
    int cardWidth;
    UIView *cellBackground;
    HGGame::HGCPU fighter;
    // HP
    UILabel* life;
    // 搭乗/出撃
    UILabel* battle;
}
@end

@implementation TroopCell
@synthesize data;

// Take all the attributes defined in the CardList controller and use them to initialize the cell atributes.
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier withHeight:(int)cellHeight withWidth:(int)cellWidth withData:(HGGame::userinfo::t_fighter*) indata
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.data = nil;
        cellBackground = [[UIView alloc] initWithFrame:CGRectZero];
        [[self contentView] addSubview:cellBackground];
        cellBackground.layer.masksToBounds = YES;

        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        cardWidth = cellWidth;
        cardHeight = cellHeight;
        self.data = indata;
        fighter = HGGame::HGCPU();
        fighter.initWithData(data, HGGame::FRIEND_SIDE);
    }
    return self;
}

- (void)refresh
{
    // 搭乗
    {
        NSString* str;
        if (data->player > 0)
        {
            str = [NSString stringWithFormat:@"搭乗中"];
        }
        else if (data->battle > 0)
        {
            str = [NSString stringWithFormat:@"出撃予定"];
        }
        else
        {
            str = [NSString stringWithFormat:@""];
        }
        [battle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
        [battle setText:str];
    }
}

// All the content inside the card can be added here. Feel free to add text and buttons.
- (void)addContent
{
    // 名前
    cardTitle = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    [[self contentView] addSubview:cardTitle];
    [cardTitle setFrame:CGRectMake(10.0, 5.0, cardWidth - 20.0, 30.0)];
    cardTitle.textAlignment = UITextAlignmentLeft;
    cardTitle.backgroundColor = [UIColor clearColor];
    [cardTitle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    cardTitle.textColor = [UIColor whiteColor];
    NSString* name = [NSString stringWithCString:data->name.c_str() encoding:NSUTF8StringEncoding];
    [cardTitle setText:name];
    
    // 画像
    NSString* fighterImgName = [NSString stringWithCString:fighter.textureName.c_str() encoding:NSUTF8StringEncoding];
    UIImage* fighterImg = [UIImage imageNamed:fighterImgName];
    
    CGRect crop;
    if (fighter.animeType == HGGame::HG_ANIME_SPRITE)
    {
        crop = CGRectMake(fighter.sprPos.x + fighter.sprSize.w*2, fighter.sprPos.y, fighter.sprSize.w, fighter.sprSize.h);
    }
    else
    {
        crop = CGRectMake(fighter.sprPos.x, fighter.sprPos.y, fighter.sprSize.w, fighter.sprSize.h);
    }
    fighterImg = [self imageByCropping:fighterImg toRect:crop];
    UIImageView* fighterImgView = [[[UIImageView alloc] initWithImage:fighterImg] autorelease];
    [fighterImgView setFrame:CGRectMake(10, 35, fighter.sprSize.w, fighter.sprSize.h)];
    [[self contentView] addSubview:fighterImgView];
    
    // 背景
 
    // HP
    life = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
    [life setFrame:CGRectMake(90.0, 3.0, 200, 35)];
    life.textAlignment = UITextAlignmentLeft;
    life.backgroundColor = [UIColor clearColor];
    life.textColor = [UIColor whiteColor];
    NSString* lifestr = [NSString stringWithFormat:@"装甲: %d/%d", fighter.life, fighter.maxlife];
    [life setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    [life setText:lifestr];
    [[self contentView] addSubview:life];
    
    // 搭乗
    {
        battle = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
        [battle setFrame:CGRectMake(90.0, 25.0, 200, 35)];
        battle.textAlignment = UITextAlignmentLeft;
        battle.backgroundColor = [UIColor clearColor];
        battle.textColor = [UIColor whiteColor];
        NSString* str = nil;
        if (data->player > 0)
        {
            str = [NSString stringWithFormat:@"搭乗中"];
        }
        else if (data->battle > 0)
        {
            str = [NSString stringWithFormat:@"出撃予定"];
        }
        else
        {
            str = [NSString stringWithFormat:@""];
        }
        [battle setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
        [battle setText:str];
        [[self contentView] addSubview:battle];
    }
}

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    float scale = [[UIScreen mainScreen] scale];
    CGImageRef imageRef = CGImageCreateWithImageInRect([imageToCrop CGImage], rect);
    UIImage *clipedImage = [UIImage imageWithCGImage:imageRef
                                               scale:scale
                                         orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    return clipedImage;
}

@end
*/