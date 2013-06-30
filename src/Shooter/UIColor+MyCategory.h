
//
// UIColor+MyCategory.h
//

#import <Foundation/Foundation.h>

/** 色をRGB指定 */
@interface UIColor (MyCategory)
+ (UIColor *)colorWithHex:(uint)rgbValue;
+ (UIColor *)colorWithHexString:(NSString *)str;
@end