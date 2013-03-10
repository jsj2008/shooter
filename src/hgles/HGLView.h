//
//  GLObject.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "HGLVector3.h"

@interface HGLView : UIView
{
}

- (id)initWithFrame:(CGRect)frame WithRenderBlock:(void (^)())block;
- (void)start;
- (void)draw; // request render

@end
