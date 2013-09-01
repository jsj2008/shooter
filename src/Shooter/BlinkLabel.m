//
//  BlinkLabel.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/09/01.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "BlinkLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation BlinkLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CABasicAnimation *theAnimation;
        theAnimation=[CABasicAnimation animationWithKeyPath:@"opacity"];
        theAnimation.duration=1.0;
        theAnimation.repeatCount=999999;
        theAnimation.autoreverses=YES;
        theAnimation.fromValue=[NSNumber numberWithFloat:1.0];
        theAnimation.toValue=[NSNumber numberWithFloat:0.0];
        [self.layer addAnimation:theAnimation forKey:@"animateOpacity"];
    }
    return self;
}

// アウトライン
void ShowStringCentered(CGContextRef gc, float x, float y, const char *str) {
    CGContextSetTextDrawingMode(gc, kCGTextInvisible);
    CGContextShowTextAtPoint(gc, 0, 0, str, strlen(str));
    CGPoint pt = CGContextGetTextPosition(gc);
    
    CGContextSetTextDrawingMode(gc, kCGTextFillStroke);
    //NSString* fontName = @"HiraKakuProN-W6";
    CGContextShowTextAtPoint(gc, x - pt.x / 2, y, str, strlen(str));
}


// アウトライン
- (void)drawRect:(CGRect)rect{
    
    CGContextRef theContext = UIGraphicsGetCurrentContext();
    CGRect viewBounds = self.bounds;
    
    CGContextTranslateCTM(theContext, 0, viewBounds.size.height);
    CGContextScaleCTM(theContext, 0.5, -0.5);
    
    CGContextSelectFont (theContext, "Helvetica-Bold", viewBounds.size.height,  kCGEncodingMacRoman);
    
    CGContextSetRGBFillColor (theContext, 1, 0.3, 0.3, 1.0);
    CGContextSetRGBStrokeColor (theContext, 0.5, 0, 0, 1);
    CGContextSetLineWidth(theContext, 1.0);
    
    ShowStringCentered(theContext, rect.size.width, 12, [[self text] cStringUsingEncoding:NSASCIIStringEncoding]);
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
