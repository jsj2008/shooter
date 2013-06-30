#import "MenuView.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AllyViewController.h"
#import <vector>

typedef enum MainMenuTag
{
    MainMenuStage,
    MainMenuSelectAlly,
    MainMenuFixAlly,
    MainMenuNum,
}MainMenuTag;

typedef struct t_menu_btn
{
    float x;
    float y;
    float w;
    float h;
    NSString* btnName;
} t_menu_btn;

t_menu_btn menu_btn_info[] = {
    {
        0,
        -100,
        300,
        50,
        @"start battle"
    },
    {
        0,
        0,
        300,
        50,
        @"select ally"
    },
    {
        0,
        100,
        300,
        50,
        @"repair"
    }
};

@interface MenuView ()
{
    UIButton* _buttons[MainMenuNum];
}

@end

@implementation MenuView

- (id)init
{
    self = [super init];
    if (self)
    {
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        CGRect viewFrame = CGRectMake(0, 0, frame.size.height, frame.size.width);
        [self setFrame:viewFrame];
        [self initialize];
    }
    return self;
}

-(void)initialize
{
    // button
    CGPoint center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    for (int i = 0; i < MainMenuNum; ++i)
    {
        t_menu_btn info = menu_btn_info[i];
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
        case MainMenuStage:
            [MainViewController StageStart];
            break;
        case MainMenuSelectAlly:
        {
            //[MainViewController ShowTroops];
            AllyViewController* vc = [[[AllyViewController alloc] initWithViewMode:AllyViewModeSelectAlly] autorelease];
            [MainViewController PresentViewController:vc];
            break;
        }
        case MainMenuFixAlly:
        {
            AllyViewController* vc = [[[AllyViewController alloc] initWithViewMode:AllyViewModeFix] autorelease];
            [MainViewController PresentViewController:vc];
            break;
        }
        default:
            assert(0);
    }
}

-(void)dealloc
{
    [super dealloc];
}


@end
