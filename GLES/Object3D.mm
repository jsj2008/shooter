//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "Object3D.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "Mesh.h"
#import "HGLES.h"
#include <vector>

Object3D::Object3D()
{
    position = Vector3();
    rotate   = Vector3();
    scale    = Vector3(1, 1, 1);
}

Object3D::~Object3D()
{
    for (std::vector<Mesh*>::iterator itr = meshlist.begin(); itr != meshlist.end(); itr++)
    {
        free(*itr);
    }
    meshlist.clear();
}

void Object3D::draw()
{
    HGLES::pushMatrix();
    HGLES::mvMatrix = GLKMatrix4Translate(HGLES::mvMatrix, position.x, position.y, position.z);
    HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, rotate.z, 0, 0, 1);
    HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, rotate.y, 0, 1, 0);
    HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, rotate.x, 1, 0, 0);
    HGLES::mvMatrix = GLKMatrix4Scale(HGLES::mvMatrix, scale.x, scale.y, scale.z);
    HGLES::updateMatrix();
    
    // 自分を描画
    std::vector<Mesh*>::iterator meshItr;
    meshItr = meshlist.begin();
    while (meshItr != meshlist.end()) {
        Mesh* m = *meshItr;
        m->draw();
        meshItr++;
    }
    
    // 子を描画
    std::vector<Object3D*>::iterator childItr;
    childItr = children.begin();
    while (childItr != children.end()) {
        Object3D* c = *childItr;
        c->draw();
        childItr++;
    }
    
    HGLES::popMatrix();
}

void Object3D::addMesh(Mesh* m)
{
    meshlist.push_back(m);
}

