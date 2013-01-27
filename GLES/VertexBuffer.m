//
//  VertexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "VertexBuffer.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#import "Shader.h"

@implementation VertexBuffer

/*
const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {1, 0, 0, 1}},
    {{-1, 1, 0}, {0, 1, 0, 1}},
    {{-1, -1, 0}, {0, 1, 0, 1}},
    {{1, -1, -1}, {1, 0, 0, 1}},
    {{1, 1, -1}, {1, 0, 0, 1}},
    {{-1, 1, -1}, {0, 1, 0, 1}},
    {{-1, -1, -1}, {0, 1, 0, 1}}
};
*/

- (id)initWithWithVertices:(const Vertex*)v size:(int)size
{
    self = [super init];
    if (self)
    {
        glGenBuffers(1, &vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        //glBufferData(GL_ARRAY_BUFFER, sizeof(v), v, GL_STATIC_DRAW);
        glBufferData(GL_ARRAY_BUFFER, size, v, GL_STATIC_DRAW);
        // TODO:unbind
    }
    return self;
}

- (void)bind
{
    glEnableVertexAttribArray([Shader positionSlot]);
    glEnableVertexAttribArray([Shader colorSlot]);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    glVertexAttribPointer([Shader positionSlot], 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer([Shader colorSlot], 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
}

- (void)unbind
{
    glDisableVertexAttribArray([Shader positionSlot]);
    glDisableVertexAttribArray([Shader colorSlot]);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)dispose
{
    if (vertexBuffer)
    {
        glDeleteBuffers(1, &vertexBuffer);
        vertexBuffer = 0;
    }
    
}

- (void) dealloc
{
    [self dispose];
    [super dealloc];
}

@end
