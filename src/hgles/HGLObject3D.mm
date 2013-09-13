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

namespace hgles {
    
    HGLObject3D::HGLObject3D()
    {
        position = HGLVector3();
        rotate   = HGLVector3();
        scale    = HGLVector3(1, 1, 1);
        useLight = 0.0;
        paralell = false;
        alpha = 1.0;
        programType = ProgramType3D;
    }
    
    HGLObject3D::~HGLObject3D()
    {
        for (std::vector<HGLMesh*>::iterator itr = meshlist.begin(); itr != meshlist.end(); itr++)
        {
            delete (*itr);
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
        if (programType != getCurrentProgramType())
        {
            setCurrentContext(programType);
        }
        
        // 光源使用有無設定
        glUniform1f(currentContext->uUseLight, useLight);
        
        // アルファ値設定
        glUniform1f(currentContext->uAlpha, alpha);
        
        // モデルビュー変換
        // 注意!
        // 拡大した後のアフィン変換はすべて拡大が適用される。
        // 回転した後平行移動すると平行移動の向きが変わる
        // =====正しい順序はこうなる
        // 行列をスタックに積む
        // ワールド座標での平行移動
        // ワールド座標での回転
        // ワールド座標での拡大
        // 以下、下記を繰り返す
        // ...行列をスタックに積む
        // ...ローカル座標での平行移動
        // ...ローカル座標での回転
        // ...ローカル座標での拡大
        // ...自身を描画
        // ...子を描画(再帰呼び出し)
        // ...行列をポップする
        // 行列をポップする
        // =====終わり
        HGLES::pushMatrix();
        mvMatrix = GLKMatrix4Translate(mvMatrix, position.x, position.y, position.z);
        mvMatrix = GLKMatrix4Scale(mvMatrix, scale.x, scale.y, scale.z);
            mvMatrix = GLKMatrix4Rotate(mvMatrix, rotate.x, 1, 0, 0);
            mvMatrix = GLKMatrix4Rotate(mvMatrix, rotate.y, 0, 1, 0);
            mvMatrix = GLKMatrix4Rotate(mvMatrix, rotate.z, 0, 0, 1);
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
    
}
