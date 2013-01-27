//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IndexBuffer : NSObject
{
    GLuint indexBuffer;
    
}
- (id)initWithIndices:(const GLubyte*)indices size:(int)size;

- (void)bind;

- (void)draw;

- (void)unbind;

- (void)dispose;

@end
