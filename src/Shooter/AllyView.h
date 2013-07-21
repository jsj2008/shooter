//
//  AllyView.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/09.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGame.h"

typedef enum AllyViewMode
{
    AllyViewModeSelectAlly,
    AllyViewModeDeployAlly,
    AllyViewModeFix,
    AllyViewModeSell,
    AllyViewModeSelectPlayer,
    AllyViewModeShop,
} AllyViewMode;

@interface AllyView : UIView

- (id)initWithAllyViewMode:(AllyViewMode)mode WithFrame:(CGRect)frame WithFighterInfo:(hg::FighterInfo*)info;
//- (void)setFighterInfo:(hg::FighterInfo*) info;
- (hg::FighterInfo*) getFighterinfo;
//- (void)setBackgroundColor:(UIColor *)backgroundColor WithTextColor:(UIColor *)textColor;
//- (void)onTouchAnime;

@end
