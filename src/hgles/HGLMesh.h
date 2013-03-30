//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//
#ifndef __HGLMESH
#define __HGLMESH

#import <Foundation/Foundation.h>

namespace hgles {
    
    class HGLIndexBuffer;
    class HGLVertexBuffer;
    class HGLMaterial;
    class HGLTexture;
    
    class HGLMesh
    {
    public:
        HGLMesh(HGLVertexBuffer* v, HGLIndexBuffer* i, HGLMaterial* m, HGLTexture* t);
        void draw();
        ~HGLMesh();
        HGLMaterial* getMaterial();
        
        // property
        HGLIndexBuffer* indexBuffer;
        HGLVertexBuffer* vertexBuffer;
        HGLTexture* texture;
        HGLMaterial* material;
        
    };
}
#endif