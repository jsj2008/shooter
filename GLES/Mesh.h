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
class Material;

class Mesh
{
public:
    Mesh(VertexBuffer* v, IndexBuffer* i, Material* m);
    void draw();
    ~Mesh();
    
private:
    IndexBuffer* indexBuffer;
    VertexBuffer* vertexBuffer;
    Material* material;
};
