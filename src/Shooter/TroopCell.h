//
//  CardListCell.h
//  ARC enabled
//  Created by Hooman Ahmadi on 7/18/12.

#import <Foundation/Foundation.h>

#import "HGUser.h"

@interface TroopCell : UITableViewCell
{
}
@property(readwrite, atomic)HGGame::userinfo::t_fighter* data;

- (void)addContent;
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier withHeight:(int)cellHeight withWidth:(int)cellWidth withData:(HGGame::userinfo::t_fighter*) indata;
- (void)refresh;
@end
