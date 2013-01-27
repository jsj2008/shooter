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

void Mesh::setVertexBuffer(VertexBuffer* v)
{
    vertexBuffer = v;
}

void Mesh::setIndexBuffer(IndexBuffer* i)
{
    indexBuffer = i;
}

void Mesh::draw()
{
    vertexBuffer->bind();
    indexBuffer->draw();
    vertexBuffer->unbind();
}

Mesh::~Mesh()
{
    if (vertexBuffer)
    {
        delete vertexBuffer;
    }
    if (indexBuffer)
    {
        delete indexBuffer;
    }
}
