//
//  DialogView.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/07/07.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogView : UIView

- (id)initWithMessage:(NSString*)message;
- (void)addButtonWithText:(NSString*)text withAction:(void (^)(void))action;
- (void)show;

@end
