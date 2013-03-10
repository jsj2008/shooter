//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "HGLGraphics2D.h"
#import "HGLTexture.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "HGLMesh.h"
#import "HGLES.h"
#include <vector>

namespace hgles {
    
    HGLVertexBuffer* HGLGraphics2D::vertexBuffer;
    HGLIndexBuffer* HGLGraphics2D::indexBuffer;
    
    void HGLGraphics2D::initialize()
    {
        // 頂点バッファ、インデックスバッファ作成
        Vertex rectVertex[4] = {
            Vertex({0.5,-0.5,0},{1,1},{0,0,0.5}),
            Vertex({0.5,0.5,0},{1,0},{0,0,0.5}),
            Vertex({-0.5,0.5,0},{0,0},{0,0,0.5}),
            Vertex({-0.5,-0.5,0},{0,1},{0,0,0.5})
        };
        // http://www9.plala.or.jp/sgwr-t/c/sec10-2.html
        // 配列のときは&をつけなくても先頭要素のアドレス
        vertexBuffer = new HGLVertexBuffer(rectVertex, 4);
        Index index[] = {
            0,1,2,2,3,0
        };
        indexBuffer = new HGLIndexBuffer(index, 6);
    }
    
    void HGLGraphics2D::draw(t_hgl2di* p)
    {
        // アルファ値設定
        glUniform1f(HGLES::uAlpha, p->alpha);
        
        HGLES::pushMatrix();
        
        // モデルビュー変換
        HGLES::mvMatrix = GLKMatrix4Translate(HGLES::mvMatrix, p->position.x, p->position.y, p->position.z);
        HGLES::mvMatrix = GLKMatrix4Scale(HGLES::mvMatrix, p->scale.x, p->scale.y, p->scale.z);
        /*
         if (p->paralell)
         {
         HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, HGLES::cameraRotate.x*-1, 1, 0, 0);
         HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, HGLES::cameraRotate.y*-1, 0, 1, 0);
         HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, p->rotate.z, 0, 0, 1); // zは回転を適用
         }
         else
         {*/
        HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, p->rotate.x, 1, 0, 0);
        HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, p->rotate.y, 0, 1, 0);
        HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, p->rotate.z, 0, 0, 1);
        //}
        HGLES::updateMatrix();
        
        p->texture.bind();
        vertexBuffer->bind();
        indexBuffer->draw();
        vertexBuffer->unbind();
        p->texture.unbind();
        
        // 行列をもとに戻しておく
        HGLES::popMatrix();
        
    }
    
}






