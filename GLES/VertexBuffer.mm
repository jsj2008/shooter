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

VertexBuffer::VertexBuffer(const Vertex* v, int num)
{
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    //glBufferData(GL_ARRAY_BUFFER, sizeof(v), v, GL_STATIC_DRAW);
    glBufferData(GL_ARRAY_BUFFER, num*sizeof(Vertex), v, GL_STATIC_DRAW);
//    for (int i = 0; i < num; i++) {
//        NSLog(@"%d:%f,%f,%f", i,
//              v[i].position.x,
//              v[i].position.y,
//              v[i].position.z
//              );
//    }
}

void VertexBuffer::bind()
{
    glEnableVertexAttribArray(GLES::aPositionSlot);
    glEnableVertexAttribArray(GLES::aNormalSlot);
    glEnableVertexAttribArray(GLES::aUVSlot);
    //glEnableVertexAttribArray(GLES::aColorSlot);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    // 頂点
    glVertexAttribPointer(GLES::aPositionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    // UV
    glVertexAttribPointer(GLES::aUVSlot, 2, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
    // 法線
    glVertexAttribPointer(GLES::aNormalSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) * 5));
    
}

void VertexBuffer::unbind()
{
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

