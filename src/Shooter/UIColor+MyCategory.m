//
// UIColor+MyCategory.m
//

#import "UIColor+MyCategory.h"
@implementation UIColor (MyCategory)

/**
 * RGB値からUIColorを生成する
 * Create UIColor instance from a RGB value
 * e.g. [UIColor colorWithHex:0x123456]
 *
 * @param rgbValue RGB値
 * @return RGB値から生成した[UIColor]オブジェクト
 */
+ (UIColor *)colorWithHex:(uint)rgbValue {
	return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

/**
 * RGB文字列からUIColorを生成する
 * Create UIColor instance from a RGB string
 * e.g. [UIColor colorWithHexString:@"#123456"]
 *
 * @param str RGB文字列
 * @return RGB文字列から生成した[UIColor]オブジェクト
 */
+ (UIColor *)colorWithHexString:(NSString *)str {
    const char *cStr = [str cStringUsingEncoding:NSASCIIStringEncoding];
    long x = strtol(cStr+1, NULL, 16);
    return [UIColor colorWithHex:x];
}
@end
