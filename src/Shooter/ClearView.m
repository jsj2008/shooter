//
//  ClearView.m
//  Shooter
//
//  Created by 濱田 洋太 on 13/08/25.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#import "ClearView.h"
#import "UserData.h"
#import "MessageView.h"
#import <QuartzCore/QuartzCore.h>
#import "DialogView.h"

@interface ClearView ()
{
    // action
    void (^onEndAction)();
}
@property(weak)CAEmitterLayer* emitterLayer;
@end

@implementation ClearView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAlpha:0];
        [UIView animateWithDuration:0.5 animations:^{
            [self setAlpha:1];
        }];
        
        // back image
        float width = frame.size.width;
        float height = width * (float)(512.0/512.0);
        float x = 0;
        float y = 0;
        //UIImage *img = [UIImage imageNamed:@"space2.png"];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"space2" ofType:@"png"];
        UIImage* img = [[UIImage alloc] initWithContentsOfFile:path];
        UIImageView* backView = [[UIImageView alloc] initWithFrame:CGRectMake(x,y,width,height)];
        [backView setImage:img];
        [backView setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [backView setUserInteractionEnabled:true];
        [self addSubview:backView];
        
        // particle
        CGRect particleViewRect = frame;
        particleViewRect.origin.x = 0;
        particleViewRect.origin.y = 0;
        UIView* particleView = [[UIView alloc] initWithFrame:particleViewRect];
        [particleView setBackgroundColor:[UIColor clearColor]];
        [particleView setUserInteractionEnabled:false];
        [self addSubview:particleView];
        {
            CAEmitterLayer *emitterLayer = [CAEmitterLayer layer];
            CGSize size = self.bounds.size;
            emitterLayer.emitterPosition = CGPointMake(size.width / 2, size.height * 1.3);
            emitterLayer.renderMode = kCAEmitterLayerAdditive;
            self.emitterLayer = emitterLayer;
            [particleView.layer addSublayer:emitterLayer];
            
            // emitter cell
            /*
             // fire
             CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];
             UIImage *image = [UIImage imageNamed:@"particle.png"];
             emitterCell.contents = (id)(image.CGImage);
             emitterCell.emissionLongitude = M_PI * 2;
             emitterCell.emissionRange = M_PI * 2;
             emitterCell.birthRate = 800;
             emitterCell.lifetimeRange = 1.2;
             emitterCell.velocity = 240;
             emitterCell.color = [UIColor colorWithRed:0.89
             green:0.56
             blue:0.36
             alpha:0.5].CGColor;
             */
            
            // パーティクル画像
            //UIImage *particleImage = [UIImage imageNamed:@"star_cross.png"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"star_cross" ofType:@"png"];
            UIImage* particleImage = [[UIImage alloc] initWithContentsOfFile:path];
            
            // 花火自体の発生源
            CAEmitterCell *baseCell = [CAEmitterCell emitterCell];
            baseCell.emissionLongitude = -M_PI / 2;
            baseCell.emissionLatitude = 0;
            baseCell.emissionRange = M_PI / 5;
            baseCell.lifetime = 2.0;
            baseCell.birthRate = 1.5;
            baseCell.velocity = 400;
            baseCell.velocityRange = 50;
            baseCell.yAcceleration = 250;
            baseCell.color = CGColorCreateCopy([UIColor colorWithRed:0.6
                                                               green:0.6
                                                                blue:0.6
                                                               alpha:0.6].CGColor);
            baseCell.redRange   = 0.4;
            baseCell.greenRange = 0.4;
            baseCell.blueRange  = 0.4;
            baseCell.alphaRange = 0.4;
            
            // 上昇中のパーティクルの発生源
            CAEmitterCell *risingCell = [CAEmitterCell emitterCell];
            risingCell.contents = (id)particleImage.CGImage;
            risingCell.emissionLongitude = (4 * M_PI) / 2;
            risingCell.emissionRange = M_PI / 7;
            risingCell.scale = 0.4;
            risingCell.scaleRange = 0.2;
            risingCell.velocity = 80;
            risingCell.velocityRange = 40;
            risingCell.birthRate = 100;
            risingCell.lifetime = 1.5;
            risingCell.yAcceleration = 350;
            //risingCell.alphaSpeed = -0.3;
            //risingCell.scaleSpeed = -0.1;
            risingCell.scaleRange = 0.1;
            risingCell.beginTime = 0.01;
            risingCell.duration = 0.4;
            
            // 破裂後に飛散するパーティクルの発生源
            CAEmitterCell *sparkCell = [CAEmitterCell emitterCell];
            sparkCell.contents = (id)particleImage.CGImage;
            sparkCell.emissionRange = 2 * M_PI;
            sparkCell.birthRate = 3000;
            sparkCell.scale = 1.8;
            sparkCell.scaleRange = 1;
            sparkCell.velocity = 180;
            sparkCell.lifetime = 2.0;
            sparkCell.yAcceleration = 50;
            sparkCell.beginTime = risingCell.lifetime;
            sparkCell.duration = 0.17;
            sparkCell.alphaSpeed = -0.53;
            sparkCell.scaleSpeed = -0.1;
            //sparkCell.spinRange = 1;
            
            // baseCellからrisingCellとsparkCellを発生させる
            baseCell.emitterCells = [NSArray arrayWithObjects:risingCell, sparkCell, nil];
            
            // baseCellはemitterLayerから発生させる
            self.emitterLayer.emitterCells = [NSArray arrayWithObjects:baseCell, nil];
        }
        
        // congraturation
        {
            float width = frame.size.width * 0.8;
            float height = width * (float)(155.0/633.0);
            float x = frame.size.width/2 - width/2;
            float y = frame.size.height/2 - height/2 - frame.size.height/4;
            //UIImage *img = [UIImage imageNamed:@"congraturation.png"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"congraturation" ofType:@"png"];
            UIImage* img = [[UIImage alloc] initWithContentsOfFile:path];
            
            UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(x,y,width,height)];
            [iv setImage:img];
            [iv setTransform:CGAffineTransformMakeScale(0, 0)];
            [iv setUserInteractionEnabled:false];
            [self addSubview:iv];
            double delayInSeconds = 1.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [UIView animateWithDuration:0.5 animations:^{
                    [iv setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3 animations:^{
                        [iv setTransform:CGAffineTransformMakeScale(1, 1)];
                    }];
                }];
            });
        }
        // you got
        {
            float width = frame.size.width * 0.3;
            float height = width * (float)(122.0/371.0);
            float x = frame.size.width/2 - width/2;
            float y = frame.size.height/2 - height/2;
            //UIImage *img = [UIImage imageNamed:@"yougot.png"];
            UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(x,y,width,height)];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"yougot" ofType:@"png"];
            UIImage* img = [[UIImage alloc] initWithContentsOfFile:path];
            
            [iv setImage:img];
            [iv setTransform:CGAffineTransformMakeScale(0, 0)];
            [iv setUserInteractionEnabled:false];
            [self addSubview:iv];
            double delayInSeconds = 3.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [UIView animateWithDuration:0.5 animations:^{
                    [iv setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3 animations:^{
                        [iv setTransform:CGAffineTransformMakeScale(1, 1)];
                    }];
                }];
            });
        }
        // victory!
        {
            float width = frame.size.width * 0.9;
            float height = width * (float)(117.0/598.0);
            float x = frame.size.width/2 - width/2;
            float y = frame.size.height/2 - height/2 + frame.size.height/4;
            //UIImage *img = [UIImage imageNamed:@"greatvictory.png"];
            NSString *path = [[NSBundle mainBundle] pathForResource:@"greatvictory" ofType:@"png"];
            UIImage* img = [[UIImage alloc] initWithContentsOfFile:path];
            
            UIImageView* iv = [[UIImageView alloc] initWithFrame:CGRectMake(x,y,width,height)];
            [iv setImage:img];
            [iv setTransform:CGAffineTransformMakeScale(0, 0)];
            [iv setUserInteractionEnabled:false];
            [self addSubview:iv];
            double delayInSeconds = 3.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [UIView animateWithDuration:0.5 animations:^{
                    [iv setTransform:CGAffineTransformMakeScale(1.3, 1.3)];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.3 animations:^{
                        [iv setTransform:CGAffineTransformMakeScale(1, 1)];
                    }];
                }];
            });
        }
        
        // reward message
        if (hg::UserData::sharedUserData()->hasRewardInfo())
        {
            NSMutableArray* msgList = [NSMutableArray arrayWithObjects: nil];
            while (1) {
                if (!hg::UserData::sharedUserData()->hasRewardInfo()) {
                    break;
                }
                std::string msg = hg::UserData::sharedUserData()->popRewardMessage();
                [msgList addObject:[NSString stringWithCString:msg.c_str() encoding:NSUTF8StringEncoding]];
            }
            
            MessageView* msgView = [[MessageView alloc] initWithMessageList:msgList];
            [msgView show];
        }
        
        // tap
        {
            double delayInSeconds = 3.5;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                UITapGestureRecognizer *tr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
                [backView addGestureRecognizer:tr];
            });
        }
    }
    return self;
}

- (void)onTap:(UIGestureRecognizer*)sender
{
    [self setUserInteractionEnabled:false];
    [UIView animateWithDuration:0.5 animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        if (onEndAction) {
            onEndAction();
        }
    }];
}


- (void) setOnEndAction:(void(^)(void))action
{
    onEndAction = [action copy];
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

