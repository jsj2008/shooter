//
//  ClearView.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/08/25.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <string>
#import <vector>

@interface CopyrightView : UIView <UITableViewDataSource, UITableViewDelegate>

- (void) setOnEndAction:(void(^)(void))action;

typedef struct CopyrightMessage
{
    std::string title;
    std::string message;
} CopyrightMessage;

typedef std::vector<CopyrightMessage> CopyrightMessageList;

@end
