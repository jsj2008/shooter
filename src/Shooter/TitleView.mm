#import "TitleView.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>

#import <vector>

// openGL
#import "HGLView.h"
#import "HGLES.h"
#import "HGLGraphics2D.h"

typedef enum TYPE_TITLE_BTN
{
    TITLE_START_BTN,
    TITLE_BTN_NUM
} TYPE_BTN;

typedef struct t_title_btn
{
    float x;
    float y;
    float w;
    float h;
    NSString* btnName;
} t_title_btn;

t_title_btn title_btn_info[] = {
    {
        0,
        100,
        200,
        50,
        @"start"
    }
};


@interface TitleView ()
{
    
    UIButton* _buttons[TITLE_BTN_NUM];
    
    bool isEnd;
    bool is3DInitialized;
}

@end

@implementation TitleView

- (id)init
{
    self = [super init];
    if (self)
    {
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        CGRect viewFrame = CGRectMake(0, 0, frame.size.height, frame.size.width);
        [self setFrame:viewFrame];
        [self initialize];
        [self setBackgroundColor:[UIColor clearColor]];
        isEnd = false;
        is3DInitialized = false;
    }
    return self;
}

-(void)initialize
{
    
    // button
    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    for (int i = 0; i < TITLE_BTN_NUM; ++i)
    {
        t_title_btn info = title_btn_info[i];
        UIButton* b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [b setFrame: CGRectMake(0, 0, info.w, info.h)];
        [b setCenter:CGPointMake(center.x + info.x, center.y + info.y)];
        [b setTag:i];
        [b setTitle:info.btnName forState:UIControlStateNormal];
        [b setTitle:info.btnName forState:UIControlStateDisabled];
        [b setTitle:info.btnName forState:UIControlStateHighlighted];
        [b setTitle:info.btnName forState:UIControlStateSelected];
        [b addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:b];
    }
    
}

- (void)buttonPressed:(UIButton*)button
{
    switch (button.tag) {
        case TITLE_START_BTN:
            [MainViewController Start];
            break;
        default:
            assert(0);
    }
}

-(void)dealloc
{
    [super dealloc];
}


@end
