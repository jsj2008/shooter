#import "TitleView.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>

#import <vector>

// openGL
#import "HGLView.h"
#import "HGLES.h"
#import "HGLGraphics2D.h"
#import "UIColor+MyCategory.h"
#import "Common.h"
#import "ObjectAL.h"
#import "MenuButton.h"
#import "DialogView.h"
#import "UserData.h"
#import "BlinkLabel.h"
#import "CopyrightView.h"

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
    bool isLabelHidden;
}
@property (weak, atomic) IBOutlet UILabel *myLabel;

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
        isLabelHidden = true;
    }
    return self;
}

- (void)changeLabelState
{
    if(isLabelHidden)
    {
        isLabelHidden = false;
        __weak TitleView* self_ = self;
        [UIView animateWithDuration:1.0 animations:^{
            [self_.myLabel setAlpha:1];
        } completion:^(BOOL finished) {
            [self_ changeLabelState];
        }];
    }
    else
    {
        isLabelHidden = true;
        __weak TitleView* self_ = self;
        [UIView animateWithDuration:1.0 animations:^{
            [self_.myLabel setAlpha:0];
        } completion:^(BOOL finished) {
            [self_ changeLabelState];
        }];
    }
}

-(void)initialize
{
    
    // logo
    //UIImage* img = [UIImage imageNamed:@"ShooterTitle.jpg"];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ShooterTitle" ofType:@"jpg"];
    UIImage* img = [[UIImage alloc] initWithContentsOfFile:path];
    UIImageView* imgView = [[UIImageView alloc] initWithImage:img];
    float w = self.frame.size.width;
    float h = w/884*944;
    [self addSubview:imgView];
    CGRect logoFrame = CGRectMake(0,0,w,h);
    [imgView setFrame:logoFrame];
    
    imgView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    __weak UIImageView* imv = imgView;
    __weak TitleView* self_ = self;
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        imv.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        // message
        {
            UILabel* l = [[UILabel alloc] initWithFrame: CGRectMake(self.frame.size.width/2-200, logoFrame.size.height - 50, 400, 50)];
            [l setTextAlignment:NSTextAlignmentCenter];
            [l setTextColor:[UIColor greenColor]];
            [l setText:@"Touch to start"];
            //UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:20];
            UIFont* font = [UIFont systemFontOfSize:20];
            [l setFont:font];
            [l setBackgroundColor:[UIColor clearColor]];
            [l setAlpha:0];
            self_.myLabel = l;
            [self_ addSubview:l];
            [self_ changeLabelState];
        }
    }];
    
    // curtain
    {
        UIView* curtain = [[UIView alloc] initWithFrame:self.frame];
        [curtain setBackgroundColor:[UIColor colorWithHexString:@"#000000"]];
        [self addSubview:curtain];
        __weak UIView* ctn = curtain;
        [UIView animateWithDuration:0.6 animations:^{
            [ctn setAlpha:0];
        } completion:^(BOOL finished) {
            [ctn removeFromSuperview];
        }];
    }
    
    int MenuButtonWidth = 160;
    int MenuButtonHeight = 34;
    int buttonX2 = self.frame.size.width - MenuButtonWidth - 10;
    int buttonY2 = self.frame.size.height - MenuButtonHeight - 5;
    // delete data button
    {
        CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
        MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
        [m setBackgroundColor:[UIColor whiteColor]];
        [m setText:NSLocalizedString(@"Initialize Data", nil)];
        [m setColor:[UIColor blackColor]];
        [m setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:m];
        [m setOnTapAction:^(MenuButton *target) {
            DialogView* dialog = [[DialogView alloc] initWithMessage:NSLocalizedString(@"Are you sure to initialize your playing data of this game?", nil)];
            [dialog addButtonWithText:NSLocalizedString(@"OK", nil) withAction:^{
                DialogView* dialog = [[DialogView alloc] initWithMessage:NSLocalizedString(@"Is it really OK?", nil)];
                [dialog addButtonWithText:NSLocalizedString(@"OK", nil) withAction:^{
                    hg::UserData::DeleteAllData();
                    DialogView* dialog = [[DialogView alloc] initWithMessage:NSLocalizedString(@"GameData is initialized.", nil)];
                    [dialog addButtonWithText:NSLocalizedString(@"OK", nil) withAction:^{
                    }];
                    [dialog show];
                }];
                [dialog addButtonWithText:NSLocalizedString(@"Cancel", nil) withAction:^{
                }];
                [dialog show];
            }];
            [dialog addButtonWithText:NSLocalizedString(@"Cancel", nil) withAction:^{
                // do nothing
            }];
            [dialog show];
        }];
    }
    // copyright button
    buttonX2 = 10;
    {
        CGRect frm = CGRectMake(buttonX2, buttonY2, MenuButtonWidth, MenuButtonHeight);
        MenuButton* m = [[MenuButton alloc] initWithFrame:frm];
        [m setBackgroundColor:[UIColor whiteColor]];
        [m setText:NSLocalizedString(@"Show Credits", nil)];
        [m setColor:[UIColor blackColor]];
        [m setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:m];
        __weak TitleView* self_ = self;
        [m setOnTapAction:^(MenuButton *target) {
            CopyrightView* copyRight = [[CopyrightView alloc] initWithFrame:self_.frame];
            [self_ addSubview:copyRight];
        }];
    }
    // push start
    float labelWidth = 200;
    float labelHeight = 30;
    CGRect labelRect = CGRectMake(self.frame.size.width/2 - labelWidth/2, self.frame.size.height/2 - labelHeight/2 + 80, labelWidth, labelHeight);
    BlinkLabel* startLabel = [[BlinkLabel alloc] initWithFrame:labelRect];
    [startLabel setTextColor:[UIColor redColor]];
    //NSString* fontName = @"HiraKakuProN-W6";
    //UIFont* font = [UIFont fontWithName:fontName size:15];
    UIFont* font = [UIFont systemFontOfSize:15];
    [startLabel setFont:font];
    [startLabel setBackgroundColor:[UIColor clearColor]];
    [startLabel setUserInteractionEnabled:NO];
    [startLabel setText:@"TOUCH TO START"];
    [self addSubview:startLabel];
    
    // title logo
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"title2" ofType:@"png"];
        UIImage* img = [[UIImage alloc] initWithContentsOfFile:path];
        UIImageView* imgView = [[UIImageView alloc] initWithImage:img];
        float w = MIN(self.frame.size.width - 20, 400);
        float h = w*58/286;
        [imgView setFrame:CGRectMake(0, 0, w, h)];
        [imgView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
        [self addSubview:imgView];
        [imgView setTransform:CGAffineTransformMakeScale(1, 0)];
        __weak UIImageView* imv = imgView;
        [UIView animateWithDuration:0.5 animations:^{
            [imv setTransform:CGAffineTransformMakeScale(1, 1)];
        }];
    }
    
    // cover
    /*
     {
     UIView* v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
     [v setBackgroundColor:[UIColor blackColor]];
     [v setUserInteractionEnabled:NO];
     [self addSubview:v];
     [UIView animateWithDuration:0.3 animations:^{
     [v setAlpha:0];
     }];
     }*/
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[OALSimpleAudio sharedInstance] playEffect:SE_CLICK];
    [MainViewController Start];
}



@end

