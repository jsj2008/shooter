
//
// UIButton+MyCategory.m
//

#import "UIButton+MyCategory.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+MyCategory.h"

@implementation UIButton (MyCategory)

/**
 * 特定のStateのボタンの背景色を変える
 * change UIButton background color for the specified button state
 * e.g. [buttonObj setBackgroundColorString:[UIColor redColor] forState:UIControlStateNormal radius:10.0f];
 *
 * @param color 新しい背景色
 * @param state 適用State
 * @param radius 角丸
 */
- (void)setBackgroundColor:(UIColor *)color forState:(UIControlState)state radius:(CGFloat)radius {
    // imageを生成して、setBackgroundImageにセットしている
    // create images dynamically, then setBackgroundImage
    UIView *view            = [[UIView alloc] initWithFrame:self.bounds];
    view.layer.cornerRadius = radius;
    view.clipsToBounds      = YES;
    view.backgroundColor    = color;
    UIGraphicsBeginImageContext(self.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image          = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self setBackgroundImage:image forState:state];
    //[view release];
}

/**
 * 特定のStateのボタンの背景色をRGB文字列で指定する
 * change UIButton background color for the specified button state
 * e.g. [buttonObj setBackgroundColorString:@"#123456" forState:UIControlStateNormal radius:10.0f];
 *
 * @param colorStr 新しい背景色
 * @param state 適用State
 * @param radius 角丸
 */
- (void)setBackgroundColorString:(NSString *)colorStr forState:(UIControlState)state radius:(CGFloat)radius {
    UIColor *color = [UIColor colorWithHexString:colorStr];
    [self setBackgroundColor:color forState:state radius:radius];
}
@end
