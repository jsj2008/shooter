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

@interface PlayerDetailView : UIView <UITableViewDataSource, UITableViewDelegate>

typedef struct PlayerReportMessage
{
    std::string title;
    std::string message;
}PlayerReportMessage;

typedef std::vector<PlayerReportMessage> PlayerReportMessageList;

- (void)loadGrade;

@end
