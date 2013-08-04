//
//  DialogView.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/07/07.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageView : UIView

- (id)initWithMessageList:(NSMutableArray*)messageList;
- (void)show;

@end
