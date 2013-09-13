//
//  ViewController.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <UIKit/UIKit.h>

#if IS_GAMEFEAT
// gamefeat
#import <GameFeatKit/GFView.h>
#import <GameFeatKit/GFController.h>
#endif

// Google AdMob
#import "GADBannerView.h"

#if IS_GAMEFEAT
@interface MainViewController : UIViewController<GFViewDelegate>
{
}
#else
@interface MainViewController : UIViewController
{
}
#endif

+(void)Start;
+(void)PresentViewController:(UIViewController*) vc;
+ (void)RemoveBackgroundView;
+ (void)ShowBackgroundView;
+(GADBannerView*)CreateGADBannerView;
+ (UIImage*)getCheckImage;

@end


