//
//  DialogView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/07/07.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "Common.h"
#import "MessageView.h"
#import "MenuButton.h"
#import "UIColor+MyCategory.h"
#import <QuartzCore/QuartzCore.h>
#import "ObjectAL.h"

const float MessageBoxHeight = 140;
const float MessageBoxWidth = 320;
const float MessageHeight = 180;

@interface MessageView()
{
    CGRect defaultMessageRect;
}

@property(assign)UIView* menuBase;
@property(assign)UILabel* msgLabel;
@property(assign)UIView* curtain;
@property(assign)NSMutableArray* messageList;

@end

@implementation  MessageView

- (id)initWithMessageList:(NSMutableArray*)messageList
{
    self = [super init];
    if (self) {
        self.messageList = messageList;
        [self.messageList retain];
    }
    return self;
}

-(void)dealloc
{
    [self.messageList release];
    [_menuBase release];
    [_curtain release];
    [_msgLabel release];
    [super dealloc];
}

- (void)onTap:(UIGestureRecognizer*)sender
{
    [[OALSimpleAudio sharedInstance] playEffect:SE_CLICK];
    // close
    if ([self.messageList count] > 0) {
        [_msgLabel setFrame:defaultMessageRect];
        [_msgLabel setText:[self.messageList objectAtIndex:0]];
        [self.messageList removeObjectAtIndex:0];
        [_msgLabel sizeToFit];
    }
    else {
        [_curtain removeFromSuperview];
        [UIView animateWithDuration:0.2 animations:^{
            [_menuBase setTransform:CGAffineTransformMakeScale(2, 0)];
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
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
        
        UITapGestureRecognizer *tr = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)] autorelease];
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
            frame.size.width/2 - MessageBoxWidth/2, frame.size.height - MessageBoxHeight, MessageBoxWidth, MessageBoxHeight);
    UIView* messageBox = [[[UIView alloc] initWithFrame:msgBoxRect] autorelease];
    [messageBox setBackgroundColor:[UIColor blackColor]];
    [messageBox.layer setBorderColor:MAIN_BORDER_COLOR.CGColor];
    [messageBox.layer setBorderWidth:2];
    [_menuBase addSubview:messageBox];
    [messageBox setUserInteractionEnabled:FALSE];
    
    // message label
    {
        CGRect msgRect = msgBoxRect;
        
        msgRect.size.width = MessageBoxWidth - 10;
        msgRect.origin.x = 5;
        msgRect.size.height = MessageBoxHeight - 10;
        msgRect.origin.y = 5;
        defaultMessageRect = msgRect;
        
        UILabel* msgLbl = [[[UILabel alloc] initWithFrame:msgRect] autorelease];
        [msgLbl setBackgroundColor:[UIColor clearColor]];
        [msgLbl setTextColor:MAIN_FONT_COLOR];
        [msgLbl setNumberOfLines:0];
        [msgLbl setLineBreakMode:NSLineBreakByWordWrapping];
        UIFont* font = [UIFont fontWithName:@"Copperplate-Bold" size:18];
        [msgLbl setAdjustsFontSizeToFitWidth:YES];
        [msgLbl setTextAlignment:NSTextAlignmentLeft];
        [msgLbl setFont:font];
        [msgLbl setText:[self.messageList objectAtIndex:0]];
        [msgLbl sizeToFit];
        [self.messageList removeObjectAtIndex:0];
        
        [self.msgLabel setUserInteractionEnabled:false];
        self.msgLabel = msgLbl;
        
        [messageBox addSubview:msgLbl];
    }
   
    // rotate
    [self setTransform:CGAffineTransformMakeRotation(-90*M_PI/180)];
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
