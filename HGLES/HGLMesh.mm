//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "HGLMesh.h"
#import "HGLES.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

#import "HGLIndexBuffer.h"
#import "HGLVertexBuffer.h"
#import "HGLMaterial.h"

HGLMesh::HGLMesh(HGLVertexBuffer* v, HGLIndexBuffer* i, HGLMaterial* m)
{
    vertexBuffer = v;
    indexBuffer = i;
    material = m;
}

void HGLMesh::draw()
{
    if (material) material->bind();
    vertexBuffer->bind();
    indexBuffer->draw();
    vertexBuffer->unbind();
    if (material) material->unbind();
}

HGLMesh::~HGLMesh()
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
