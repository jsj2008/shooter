//
//  ImageButtonView.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/22.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuButton : UIView

- (void)setOnTapAction:(void(^)(MenuButton* target)) _onTap;
- (void)setText:(NSString*)text;

@end
