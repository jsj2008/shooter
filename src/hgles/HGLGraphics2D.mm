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
    
    //HGLVertexBuffer* HGLGraphics2D::vertexBuffer;
    //HGLIndexBuffer* HGLGraphics2D::indexBuffer;
    
    void HGLGraphics2D::cleanup()
    {
        if (squareVertexBuffer) {
            delete squareVertexBuffer;
            squareVertexBuffer = NULL;
        }
        if (squareIndexBuffer) {
            delete squareIndexBuffer;
            squareIndexBuffer = NULL;
        }
    }
    
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
        HGLVertexBuffer* vertexBuffer = new HGLVertexBuffer(rectVertex, 4);
        squareVertexBuffer = vertexBuffer;
        Index index[] = {
            0,1,2,2,3,0
        };
        HGLIndexBuffer* indexBuffer = new HGLIndexBuffer(index, 6);
        squareIndexBuffer = indexBuffer;
    }
    
    /*
    typedef struct t_hgl2di
    {
        t_hgl2di():
        scale(1,1,1),
        position(0,0,0),
        rotate(0,0,0),
        alpha(1)
        {}
        HGLTexture texture;
        HGLVector3 scale;
        HGLVector3 position;
        HGLVector3 rotate;
        float alpha;
    } t_hgl2di;
    */
    
    void HGLGraphics2D::drawLike3d(HGLVector3* position,
                         HGLVector3* scale,
                         HGLVector3* rotate,
                         HGLTexture* texture)
    {
        HGLES::pushMatrix();
        
        // モデルビュー変換
        mvMatrix = GLKMatrix4Translate(mvMatrix, position->x, position->y, position->z);
        mvMatrix = GLKMatrix4Scale(mvMatrix, scale->x, scale->y, scale->z);
        mvMatrix = GLKMatrix4Rotate(mvMatrix, rotate->x, 1, 0, 0);
        mvMatrix = GLKMatrix4Rotate(mvMatrix, rotate->y, 0, 1, 0);
        mvMatrix = GLKMatrix4Rotate(mvMatrix, rotate->z, 0, 0, 1);
        HGLES::updateMatrix();
        
        texture->bind();
        squareVertexBuffer->bind();
        squareIndexBuffer->draw();
        squareVertexBuffer->unbind();
        texture->unbind();
        
        // 行列をもとに戻しておく
        HGLES::popMatrix();
        
    }
        
    void HGLGraphics2D::draw(HGLVector3* position,
                             HGLVector3* scale,
                             HGLVector3* rotate,
                             HGLTexture* texture)
    {
        glUniform1f(currentContext->uAlpha, texture->color.a);
        HGLES::pushMatrix();
        
        mvMatrix = GLKMatrix4Translate(mvMatrix, position->x, position->y, position->z);
        mvMatrix = GLKMatrix4Scale(mvMatrix, scale->x, scale->y, scale->z);
        mvMatrix = GLKMatrix4Rotate(mvMatrix, cameraRotate.x*-1, 1, 0, 0);
        mvMatrix = GLKMatrix4Rotate(mvMatrix, cameraRotate.y*-1, 0, 1, 0);
        mvMatrix = GLKMatrix4Rotate(mvMatrix, rotate->z, 0, 0, 1);
        
        HGLES::updateMatrix();
        
        texture->bind();
        squareVertexBuffer->bind();
        squareIndexBuffer->draw();
        squareVertexBuffer->unbind();
        texture->unbind();
       
        HGLES::popMatrix();
        
    }
    
    void HGLGraphics2D::draw(t_hgl2di* p)
    {
        HGLES::pushMatrix();
        
        // モデルビュー変換
        mvMatrix = GLKMatrix4Translate(mvMatrix, p->position.x, p->position.y, p->position.z);
        mvMatrix = GLKMatrix4Scale(mvMatrix, p->scale.x, p->scale.y, p->scale.z);
        mvMatrix = GLKMatrix4Rotate(mvMatrix, p->rotate.x, 1, 0, 0);
        mvMatrix = GLKMatrix4Rotate(mvMatrix, p->rotate.y, 0, 1, 0);
        mvMatrix = GLKMatrix4Rotate(mvMatrix, p->rotate.z, 0, 0, 1);
        HGLES::updateMatrix();
        
        p->texture.bind();
        squareVertexBuffer->bind();
        squareIndexBuffer->draw();
        squareVertexBuffer->unbind();
        p->texture.unbind();
        
        // 行列をもとに戻しておく
        HGLES::popMatrix();
        
    }
    
}






