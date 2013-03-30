//
//  ViewController.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "MainViewController.h"
#import "HGGame.h"
#import "Common.h"
#import "TitleView.h"
#import "AppDelegate.h"

@interface MainViewController()
{
    ViewController* gameViewController;
    TitleView* title;
}
@end

static MainViewController* instance = nil;

@implementation MainViewController

- (void)dealloc
{
    [super dealloc];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        instance = self;
        title = [[TitleView alloc] init];
        assert(title != nil);
        [self.view addSubview:title];
    }
    return self;
}

+(void)StartShooting
{
    if (instance)
    {
        [instance startShooting];
    }
}

-(void)startShooting
{
    gameViewController = [[ViewController alloc] init];
    [title removeFromSuperview];
    [title release];
    title = NULL;
    [self presentViewController:gameViewController animated:NO completion:^{
        // nothing
    }];
}

@end
