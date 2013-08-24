//
//  DialogView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/07/07.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "DialogView.h"
#import "MenuButton.h"
#import "UIColor+MyCategory.h"
#import <QuartzCore/QuartzCore.h>

const float ButtonHeight = 44;
const float ButtonGap = 10;
const float ButtonWidth = 100;
const float MessageBoxHeight = 200;
const float MessageBoxWidth = 270;
const float MessageHeight = 100;

@interface DialogView()
{
    int _numButton;
    void (^onCancel)();
}

@property(assign)NSString* message;
@property(assign)NSMutableArray* actionList;
@property(assign)NSMutableArray* textList;
@property(assign)UIView* menuBase;
@property(assign)UIView* curtain;

@end

@implementation DialogView

- (id)initWithMessage:(NSString*)message
{
    self = [super init];
    if (self) {
        self.message = [message copy];
        self.actionList = [[NSMutableArray alloc] init];
        self.textList = [[NSMutableArray alloc] init];
        _numButton = 0;
        onCancel = NULL;
        self.closeOnTapBackground = true;
    }
    return self;
}

-(void)dealloc
{
    [self.message release];
    
    for (id i in self.actionList)
    {
        [i release];
    }
    [self.actionList removeAllObjects];
    [self.actionList release];
    for (id i in self.textList)
    {
        [i release];
    }
    [self.textList removeAllObjects];
    [self.textList release];
    if (onCancel)
    {
        [onCancel release];
    }
    [_menuBase release];
    [_curtain release];
    [super dealloc];
}

- (void)addButtonWithText:(NSString*)text withAction:(void (^)(void))action
{
    _numButton++;
    [self.actionList addObject:[action copy]];
    UIView* btn = [[UIView alloc] init];
    btn.tag = _numButton;
    [self.textList addObject:[text copy]];
}

- (void)setCancelAction:(void (^)(void))_onCancel
{
    onCancel = [_onCancel copy];
}

- (void)onTapBackground:(UIGestureRecognizer*)sender
{
    if (!self.closeOnTapBackground) return;
    // close
    [_curtain removeFromSuperview];
    [UIView animateWithDuration:0.2 animations:^{
        [_menuBase setTransform:CGAffineTransformMakeScale(2, 0)];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if (onCancel)
        {
            onCancel();
        }
    }];
}

- (void)show
{
    
    // design
    [self setBackgroundColor:[UIColor clearColor]];
    
    // add subview
    UIView* rootView = [[UIApplication sharedApplication].keyWindow viewForBaselineLayout];
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGRect frame = CGRectMake(0, 0, screenFrame.size.height, screenFrame.size.width);
    
    [self setFrame:frame];
    [self setCenter:CGPointMake(frame.size.height/2, frame.size.width/2)];
    [rootView addSubview:self];
    
    // curtain
    {
        CGRect frm = CGRectMake(0, 0, frame.size.width, frame.size.height);
        UIView* curtain = [[UIView alloc] initWithFrame:frm];
        [curtain setBackgroundColor:[UIColor blackColor]];
        [curtain setAlpha:0.5];
        [self addSubview:curtain];
        _curtain = curtain;
        
    }
    
    // base
    {
        CGRect frm = CGRectMake(0, 0, frame.size.width, frame.size.height);
        UIView* base = [[UIView alloc] initWithFrame:frm];
        [base setBackgroundColor:[UIColor clearColor]];
        [self addSubview:base];
        
        UITapGestureRecognizer *tr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapBackground:)] autorelease];
        [base addGestureRecognizer:tr];
        
        _menuBase = base;
        [_menuBase setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
    }
    
    // animation
    [_menuBase setAlpha:0];
    [_menuBase setTransform:CGAffineTransformMakeScale(2, 0)];
    [UIView animateWithDuration:0.2 animations:^{
        [_menuBase setAlpha:1];
        [_menuBase setTransform:CGAffineTransformMakeScale(1.0, 1.0)];
    }completion:^(BOOL finished) {
        //[_curtain setAlpha:0.2];
    }];
    
    // message box
    CGRect msgBoxRect = CGRectMake(
            frame.size.width/2 - MessageBoxWidth/2, frame.size.height/2 - MessageBoxHeight/2, MessageBoxWidth, MessageBoxHeight);
    UIView* messageBox = [[[UIView alloc] initWithFrame:msgBoxRect] autorelease];
    [messageBox setBackgroundColor:[UIColor blackColor]];
    [messageBox.layer setBorderColor:[UIColor colorWithHexString:@"#00ff00"].CGColor];
    [messageBox.layer setBorderWidth:2];
    [_menuBase addSubview:messageBox];
    
    // message label
    {
        CGRect msgRect = msgBoxRect;
        
        msgRect.size.width -= 10;
        msgRect.origin.x = 5;
        msgRect.size.height = MessageHeight;
        msgRect.origin.y = 5;
        
        UILabel* msgLbl = [[[UILabel alloc] initWithFrame:msgRect] autorelease];
        [msgLbl setBackgroundColor:[UIColor clearColor]];
        [msgLbl setTextColor:[UIColor colorWithHexString:@"#00ff00"]];
        [msgLbl setNumberOfLines:0];
        [msgLbl setLineBreakMode:NSLineBreakByWordWrapping];
        UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:18];
        [msgLbl setTextAlignment:NSTextAlignmentCenter];
        [msgLbl setFont:font];
        [msgLbl setText:_message];
        
        [messageBox addSubview:msgLbl];
    }
   
    // rotate
    [self setTransform:CGAffineTransformMakeRotation(-90*M_PI/180)];
    
    int index = -1;
    int x = MessageBoxWidth/2 - ButtonWidth/2 - (floor((_numButton)/2) * ButtonHeight) - (floor((_numButton)/2) * ButtonGap);
    int y = MessageHeight + 10;
    for (id i in _textList)
    {
        index++;
        MenuButton* btn = [[[MenuButton alloc] init] autorelease];
        [btn setFrame:CGRectMake(x, y, ButtonWidth, ButtonHeight)];
        btn.tag = index;
        [btn setBackgroundColor:[UIColor colorWithHexString:@"#aaffaa"]];
        [btn.layer setBorderColor:[UIColor colorWithHexString:@"#55aa55"].CGColor];
        [btn setOnTapAction:^(MenuButton *target) {
            void (^action)() = [_actionList objectAtIndex:index];
            // close
            
            [_curtain removeFromSuperview];
            [UIView animateWithDuration:0.2 animations:^{
                [_menuBase setAlpha:0];
                [_menuBase setTransform:CGAffineTransformMakeScale(2, 0)];
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
                action();
            }];
        }];
        [messageBox addSubview:btn];
        
        // label
        UILabel* lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ButtonWidth, ButtonHeight)];
        UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:18];
        [lbl setFont:font];
        [lbl setTextAlignment:NSTextAlignmentCenter];
        [lbl setBackgroundColor:[UIColor clearColor]];
        [lbl setText:i];
        [btn addSubview:lbl];
        
        x += (ButtonWidth + ButtonGap);
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
