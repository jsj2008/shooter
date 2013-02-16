//
// PadView
//
#import <UIKit/UIKit.h>

@interface TouchHandlerView : UIView

- (id)initWithHandler:(UIView*(^)(CGPoint point, UIEvent *event))hitTest;

@end


