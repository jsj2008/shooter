//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "IndexBuffer.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "HGLTypes.h"

/*
const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 7, 6,
    // Left
    2, 7, 3,
    7, 6, 2,
    // Right
    0, 4, 1,
    4, 1, 5,
    // Top
    6, 2, 1,
    1, 6, 5,
    // Bottom
    0, 3, 7,
    0, 7, 4
};
*/

IndexBuffer::IndexBuffer(const GLushort* indices, int num)
{
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    //glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, num*sizeof(GLushort), indices, GL_STATIC_DRAW);
    size = num;
    
//    for (int i = 0; i < num; i++) {
//        NSLog(@"%d: %d", i, indices[i]);
//    }
}

void IndexBuffer::bind()
{
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
}

void IndexBuffer::unbind()
{
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

void IndexBuffer::draw()
{
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glDrawElements(GL_TRIANGLES, size, GL_UNSIGNED_SHORT, 0);
    /*
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
     */
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

IndexBuffer::~IndexBuffer()
{
    if (indexBuffer)
    {
        glDeleteBuffers(1, &indexBuffer);
        indexBuffer = 0;
    }
}
