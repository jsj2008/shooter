//
//  AllyDetailView.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/07/21.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserData.h"

@interface AllyDetailView : UIView

- (id)initWithFighterInfo:(hg::FighterInfo*)fighterInfo isUsers:(bool)_isUsers;
- (void)show;

@end
