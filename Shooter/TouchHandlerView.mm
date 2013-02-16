#import "TouchHandlerView.h"
#import <QuartzCore/QuartzCore.h>
//
// すべてのViewの一番上におき、hitTest:をオーバーライドすることにより
// 複数のsubviewでタッチイベントを受け取れるようにするためのビュー
//
@implementation TouchHandlerView

UIView*(^_hitTest)(CGPoint point, UIEvent *event);

- (id)initWithHandler:(UIView*(^)(CGPoint point, UIEvent *event))hitTest
{
    CGRect frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self)
    {
        _hitTest = [hitTest copy];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

- (UIView*)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *result = [super hitTest:point withEvent:event];
    UIView *result2 = _hitTest(point, event);
    if (result2)
    {
        return result2;
    }
    return result;
}

@end
