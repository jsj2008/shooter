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

@interface ReportView : UIView <UITableViewDataSource, UITableViewDelegate>

- (void) setOnEndAction:(void(^)(void))action;

typedef struct ReportMessage
{
    std::string title;
    std::string message;
}ReportMessage;

typedef std::vector<ReportMessage> ReportMessageList;

@end
