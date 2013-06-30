//
//  ImageButtonView.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/22.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageButtonView : UIImageView

- (void)setOnTapAction:(void(^)(ImageButtonView* target)) _onTap;

@end
