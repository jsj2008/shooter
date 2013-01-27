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
#include <vector>

Object3D::Object3D()
{
    
}

Object3D::~Object3D()
{
    meshlist.clear();
}

void Object3D::draw()
{
    std::vector<Mesh*>::iterator it;
    it = meshlist.begin();
    while (it != meshlist.end()) {
        Mesh* m = *it;
        m->draw();
        it++;
    }
}

void Object3D::addMesh(Mesh* m)
{
    meshlist.push_back(m);
}

