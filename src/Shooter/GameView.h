//
//  ViewController.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameView : UIView

- (void) setOnEndAction:(void(^)(void))action;

@end
