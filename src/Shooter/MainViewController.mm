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
#import "MenuBackView.h"
#import "MenuView.h"

typedef enum TYPE_MENU_BTN
{
    MENU_STAGE_BTN,
    MENU_BTN_NUM
} TYPE_MENU_BTN;

typedef struct t_menu_btn
{
    float x;
    float y;
    float w;
    float h;
    NSString* btnName;
} t_menu_btn;

t_menu_btn menu_btn_info[] = {
    {
        0,
        100,
        200,
        50,
        @"stage"
    }
};

@interface MainViewController()
{
    ViewController* gameViewController;
    TitleView* title;
    
    // button
    UIButton* _buttons[MENU_BTN_NUM];
    
    // background
    MenuBackView* menuBackView;
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
        menuBackView = [[MenuBackView alloc] init];
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

-(void)showMenu
{
    
}

@end
