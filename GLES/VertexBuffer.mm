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
#import "GLES.h"

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

VertexBuffer::VertexBuffer(const Vertex* v, int size)
{
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    //glBufferData(GL_ARRAY_BUFFER, sizeof(v), v, GL_STATIC_DRAW);
    glBufferData(GL_ARRAY_BUFFER, size, v, GL_STATIC_DRAW);
    // TODO:unbind
}

void VertexBuffer::bind()
{
    glEnableVertexAttribArray(GLES::aPositionSlot);
    glEnableVertexAttribArray(GLES::aColorSlot);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    glVertexAttribPointer(GLES::aPositionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(GLES::aColorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    
}

void VertexBuffer::unbind()
{
    glDisableVertexAttribArray(GLES::aPositionSlot);
    glDisableVertexAttribArray(GLES::aColorSlot);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

VertexBuffer::~VertexBuffer()
{
    if (vertexBuffer)
    {
        glDeleteBuffers(1, &vertexBuffer);
        vertexBuffer = 0;
    }
}

