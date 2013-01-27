//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "Mesh.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

@implementation Mesh

IndexBuffer* indexBuffer;
VertexBuffer* vertexBuffer;

- (id)init
{
    self = [super init];
    return self;
}

- (void)setVertexBuffer:(VertexBuffer*)v
{
    vertexBuffer = v;
    [vertexBuffer retain];
}

- (void)setIndexBuffer:(IndexBuffer*)i
{
    indexBuffer = i;
    [indexBuffer retain];
}

- (void)draw:(GLuint)positionHandle colorHandle:(GLuint)colorHandle
{
    [vertexBuffer bind:positionHandle colorHandle:colorHandle];
    [indexBuffer draw];
    [vertexBuffer unbind:positionHandle colorHandle:colorHandle];
}


@end
