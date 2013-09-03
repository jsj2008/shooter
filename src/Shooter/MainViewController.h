//
//  ViewController.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>
// gamefeat
#import <GameFeatKit/GFView.h>
#import <GameFeatKit/GFController.h>

// Google AdMob
#import "GADBannerView.h"

@interface MainViewController : UIViewController<GFViewDelegate>
{
}

+(void)Start;
+(void)PresentViewController:(UIViewController*) vc;
+ (void)RemoveBackgroundView;
+ (void)ShowBackgroundView;
+(GADBannerView*)CreateGADBannerView;

@end


