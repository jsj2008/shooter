//
//  AllyViewController.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/09.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AllyView.h"

@interface AllyViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

- (id)initWithViewMode:(AllyViewMode)_viewMode;

@end
