//
//  GlowLabel.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/08/28.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "GlowLabel.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+MyCategory.h"

@implementation GlowLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    UIColor *insideColor;
    UIColor *blurColor;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //insideColor =[UIColor colorWithRed:255/255.0 green:255/255.0 blue:191/255.0 alpha:1];
    insideColor = [UIColor colorWithHexString:@"#c9ffff"];
    blurColor =[UIColor colorWithHexString:@"ffffff"];
    
    
    CGContextSetFillColorWithColor(ctx, insideColor.CGColor);
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), self.glowAmount, blurColor.CGColor);
    CGContextSetTextDrawingMode(ctx, kCGTextFillStroke);
    
    [self.text drawInRect:self.bounds withFont:self.font lineBreakMode:self.lineBreakMode alignment:self.textAlignment];
    //CGContextRelease(ctx);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
