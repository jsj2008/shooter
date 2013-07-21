//
//  StatusView.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/29.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>

const int StatusViewHeight = 20;

@interface StatusView : UIView

- (void)loadUserInfo;
+ (id)GetInstance;
+ (id)CreateInstance;

@end
