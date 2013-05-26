//
// PadView
//
#import <UIKit/UIKit.h>

@interface PadView : UIView

- (id)initWithFrame:(CGRect)frame WithOnTouchBlock:(void (^)(int degree, float power, bool touchBegan, bool touchEnd))onTouch;

@end


