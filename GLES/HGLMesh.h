//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>

class HGLIndexBuffer;
class HGLVertexBuffer;
class HGLMaterial;

class HGLMesh
{
public:
    HGLMesh(HGLVertexBuffer* v, HGLIndexBuffer* i, HGLMaterial* m);
    void draw();
    ~HGLMesh();
    
private:
    HGLIndexBuffer* indexBuffer;
    HGLVertexBuffer* vertexBuffer;
    HGLMaterial* material;
};
