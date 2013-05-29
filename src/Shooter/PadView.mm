#import "PadView.h"
#import <QuartzCore/QuartzCore.h>
//
// controller
//
@interface PadView ()
{
    CGPoint _center;
    float _padRadius;
    CGPoint _padPos;
    void (^_onTouch)(int degree, float power, bool touchBegan, bool touchEnd);
    
    UIView* _touchEffectView;
    float _touchEffectRadius;
}

@end

@implementation PadView

CGSize padSize;
CGSize defaultPadSize;

- (id)initWithFrame:(CGRect)frame WithOnTouchBlock:(void (^)(int degree, float power, bool touchBegan, bool touchEnd))onTouch
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setAlpha:0.4];
        [self setBackgroundColor:[UIColor clearColor]];
        
        defaultPadSize = {120, 120};
        _onTouch = [onTouch copy];
        [self setPadSize:CGSizeMake(0, 0)];
        [self setCenter:CGPointMake(defaultPadSize.width/2, frame.size.height - defaultPadSize.height/2)];
        
        // タッチエフェクト
        _touchEffectRadius = _padRadius * 0.3f;
        CGRect touchEffectFrame = CGRectMake(_center.x - _touchEffectRadius,
                                               _center.y - _touchEffectRadius,
                                               _touchEffectRadius*2,
                                               _touchEffectRadius*2);
        _touchEffectView = [[UIView alloc] initWithFrame:touchEffectFrame];
        [_touchEffectView setUserInteractionEnabled:NO];
        [_touchEffectView setBackgroundColor:[UIColor cyanColor]];
        [self addSubview:_touchEffectView];
    }
    
    return self;
}

- (void)setPadSize: (CGSize)size
{
    padSize = size;
    _padRadius = padSize.width * 0.80 / 2;
    [self setNeedsDisplay]; // 描画をやり直す
    if (size.width <= 0)
    {
        [_touchEffectView setAlpha:0];
    }
    else
    {
        [_touchEffectView setAlpha:1];
    }
}

- (void)setCenter:(CGPoint) center
{
    _center = center;
    _padPos.x = _center.x - _padRadius; // パッドの位置
    _padPos.y = _center.y - _padRadius; // パッドの位置
    _padPos.x = _center.x - _padRadius; // パッドの位置
    _padPos.y = _center.y - _padRadius; // パッドの位置
    [self setNeedsDisplay]; // 描画をやり直す
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();  // コンテキストを取得
    // 線の太さを指定
    CGContextSetLineWidth(context, 2.0);
    // 線の色を指定
    CGContextSetRGBStrokeColor(context, 0.5, 0.5, 0.5, 1);
    // 終端の形を指定
    //CGContextSetLineCap(context, kCGLineCapRound);
    // 円を描画
    CGContextStrokeEllipseInRect(context, CGRectMake(_padPos.x, _padPos.y, _padRadius*2, _padRadius*2));  // 円の描画
    //CGContextFillEllipseInRect(context, CGRectMake(_padPos.x, _padPos.y, _padRadius*2, _padRadius*2));  // 円を塗りつぶす
}

#pragma mark touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    [self setPadSize:defaultPadSize];
    [self setCenter:location];
    [self touch:location isBegan:true isEnd:false];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    [self touch:location isBegan:false isEnd:false];
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchEnd];
    [super touchesEnded:touches withEvent:event];
    [self setPadSize: CGSizeMake(0, 0)];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchEnd];
    [super touchesCancelled:touches withEvent:event];
    [self setPadSize: CGSizeMake(0, 0)];
}

- (void)touchEnd
{
    _onTouch(0, 0, false, true);
    
    // animation
    CGRect tFrm = _touchEffectView.frame;
    tFrm.origin.x = _center.x - _touchEffectRadius;
    tFrm.origin.y = _center.y - _touchEffectRadius;
    [UIView animateWithDuration:0.3 animations:^{
        _touchEffectView.frame = tFrm;
    }];
    
}

- (void)touch:(CGPoint)location isBegan:(bool)touchBegan isEnd:(bool)touchEnd
{
    // 角度
    // GLViewで使用する角度に合わせる(右方向が0度、上方向が90度)
    float aspect = atan2f(location.x - _center.x, location.y - _center.y);
    int t_degree = (int)((aspect * 180 / M_PI) + 0.5);
    int degree = (t_degree * -1 + 720 - 270) % 360; // もっと良いやりかたがあるはず。。
    // %での距離
    float power = sqrtf(
        powf(location.x - _center.x, 2) + powf(location.y - _center.y, 2))
        / _padRadius;
    power *= 1.2;
    if (power > 1.0) power = 1.0;
    
    // コールバック呼び出し
    if (_onTouch)
    {
        _onTouch(degree, power, touchBegan, touchEnd);
    }
    
    // animation
    CGPoint touchEffectLocation = location;
    CGPoint mostFarPoint = CGPointMake(_center.y + _padRadius * sin(aspect),
                                       _center.x + _padRadius * cos(aspect));
    if (mostFarPoint.x >= _center.x && touchEffectLocation.x > mostFarPoint.x) touchEffectLocation.x = mostFarPoint.x;
    if (mostFarPoint.x <  _center.x && touchEffectLocation.x < mostFarPoint.x) touchEffectLocation.x = mostFarPoint.x;
    if (mostFarPoint.y >= _center.y && touchEffectLocation.y > mostFarPoint.y) touchEffectLocation.y = mostFarPoint.y;
    if (mostFarPoint.y <  _center.y && touchEffectLocation.y < mostFarPoint.y) touchEffectLocation.y = mostFarPoint.y;
    
    CGRect tFrm = _touchEffectView.frame;
    tFrm.origin.x = touchEffectLocation.x - _touchEffectRadius;
    tFrm.origin.y = touchEffectLocation.y - _touchEffectRadius;
    
    _touchEffectView.frame = tFrm;
    
}



@end
