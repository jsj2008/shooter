//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "HGLObject3D.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "HGLMesh.h"
#import "HGLES.h"
#include <vector>

HGLObject3D::HGLObject3D()
{
    position = HGLVector3();
    rotate   = HGLVector3();
    scale    = HGLVector3(1, 1, 1);
    useLight = false;
    alpha = 1.0;
}

HGLObject3D::~HGLObject3D()
{
    for (std::vector<HGLMesh*>::iterator itr = meshlist.begin(); itr != meshlist.end(); itr++)
    {
        free(*itr);
    }
    meshlist.clear();
}

HGLMesh* HGLObject3D::getMesh(int index)
{
    if (meshlist.size() > index)
    {
        return meshlist.at(index);
    }
    return NULL;
}

void HGLObject3D::draw()
{
    // 光源使用有無設定
    glUniform1f(HGLES::uUseLight, useLight?1.0:0.0);
    
    // モデルビュー変換
    HGLES::pushMatrix();
    HGLES::mvMatrix = GLKMatrix4Translate(HGLES::mvMatrix, position.x, position.y, position.z);
    HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, rotate.z, 0, 0, 1);
    HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, rotate.y, 0, 1, 0);
    HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, rotate.x, 1, 0, 0);
    HGLES::mvMatrix = GLKMatrix4Scale(HGLES::mvMatrix, scale.x, scale.y, scale.z);
    HGLES::updateMatrix();
    
    // 自分を描画
    std::vector<HGLMesh*>::iterator meshItr;
    meshItr = meshlist.begin();
    while (meshItr != meshlist.end()) {
        HGLMesh* m = *meshItr;
        m->draw();
        meshItr++;
    }
    
    // 子を描画
    std::vector<HGLObject3D*>::iterator childItr;
    childItr = children.begin();
    while (childItr != children.end()) {
        HGLObject3D* c = *childItr;
        c->draw();
        childItr++;
    }
    
    HGLES::popMatrix();
}

void HGLObject3D::addMesh(HGLMesh* m)
{
    meshlist.push_back(m);
}

