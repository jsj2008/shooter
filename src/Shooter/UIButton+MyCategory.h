//
//  UIButton+MyCategory.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/02.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef Shooter_UIButton_MyCategory_h
#define Shooter_UIButton_MyCategory_h

//
// UIButton+MyCategory.h
//

#import <Foundation/Foundation.h>
@interface UIButton (MyCategory)
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state radius:(CGFloat)radius;
- (void)setBackgroundColorString:(NSString *)colorStr forState:(UIControlState)state radius:(CGFloat)radius;
@end

#endif
