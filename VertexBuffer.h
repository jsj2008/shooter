//
//  VertexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

@interface VertexBuffer : NSObject
{
    @public
        GLuint vertexBuffer;
    
    
}

- (id)initWithWithVertices:(const Vertex*)v size:(int)size;

- (void)bind:(GLuint)positionHandle colorHandle:(GLuint)colorHandle;

- (void)unbind:(GLuint)positionHandle colorHandle:(GLuint)colorHandle;

@end
