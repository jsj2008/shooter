//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>

class IndexBuffer;
class VertexBuffer;
class HGLMaterial;

class HGLMesh
{
public:
    HGLMesh(VertexBuffer* v, IndexBuffer* i, HGLMaterial* m);
    void draw();
    ~HGLMesh();
    
private:
    IndexBuffer* indexBuffer;
    VertexBuffer* vertexBuffer;
    HGLMaterial* material;
};
