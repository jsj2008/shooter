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
@property (assign, atomic) IBOutlet UILabel *myLabel;

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
        [UIView animateWithDuration:1.0 animations:^{
            [self.myLabel setAlpha:1];
        } completion:^(BOOL finished) {
            [self changeLabelState];
        }];
    }
    else
    {
        isLabelHidden = true;
        [UIView animateWithDuration:1.0 animations:^{
            [self.myLabel setAlpha:0];
        } completion:^(BOOL finished) {
            [self changeLabelState];
        }];
    }
}

-(void)initialize
{
    
    // logo
    //UIImage* img = [UIImage imageNamed:@"ShooterTitle.jpg"];
    NSString *path = [[[NSBundle mainBundle] pathForResource:@"ShooterTitle" ofType:@"jpg"] autorelease];
    UIImage* img = [[UIImage alloc] initWithContentsOfFile:path];
    UIImageView* imgView = [[[UIImageView alloc] initWithImage:img] autorelease];
    float w = self.frame.size.width;
    float h = w/884*944;
    [self addSubview:imgView];
    CGRect logoFrame = CGRectMake(0,0,w,h);
    [imgView setFrame:logoFrame];
    
    imgView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [UIView animateWithDuration:0.7 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        imgView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        // message
        {
            UILabel* l = [[UILabel alloc] initWithFrame: CGRectMake(self.frame.size.width/2-200, logoFrame.size.height - 50, 400, 50)];
            [l setTextAlignment:NSTextAlignmentCenter];
            [l setTextColor:[UIColor greenColor]];
            [l setText:@"Touch to start"];
            UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:20];
            [l setFont:font];
            [l setBackgroundColor:[UIColor clearColor]];
            [l setAlpha:0];
            [l autorelease];
            self.myLabel = l;
            [self addSubview:l];
            [self changeLabelState];
        }
    }];
    
    // curtain
    {
        UIView* curtain = [[[UIView alloc] initWithFrame:self.frame] autorelease];
        [curtain setBackgroundColor:[UIColor colorWithHexString:@"#000000"]];
        [self addSubview:curtain];
        [UIView animateWithDuration:0.6 animations:^{
            [curtain setAlpha:0];
        } completion:^(BOOL finished) {
            [curtain removeFromSuperview];
        }];
    }
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[OALSimpleAudio sharedInstance] playEffect:SE_CLICK];
    [MainViewController Start];
}

-(void)dealloc
{
    [super dealloc];
}


@end
