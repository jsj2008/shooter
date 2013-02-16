//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "Mesh.h"
#import "GLES.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#import "IndexBuffer.h"
#import "VertexBuffer.h"
#import "HGLMaterial.h"

Mesh::Mesh(VertexBuffer* v, IndexBuffer* i, HGLMaterial* m)
{
    vertexBuffer = v;
    indexBuffer = i;
    material = m;
}

void Mesh::draw()
{
    material->bind();
    vertexBuffer->bind();
    indexBuffer->draw();
    vertexBuffer->unbind();
    material->unbind();
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
    if (material)
    {
        delete material;
    }
}
