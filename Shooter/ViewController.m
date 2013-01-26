//
//  ViewController.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "ViewController.h"
#import "GLView.h"

@implementation ViewController
GLView* glview;
    
- (void)dealloc
{
    if (glview) {
        [glview release];
    }
    [super dealloc];
}

- (id) init
{
    self = [super init];
    CGRect frame = [[UIScreen mainScreen] bounds];
    glview = [[GLView alloc] initWithFrame:frame];
    self.view = glview;
    return self;
}


@end
