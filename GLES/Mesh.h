//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IndexBuffer.h"
#import "VertexBuffer.h"

class Mesh
{
public:
    Mesh(VertexBuffer* v, IndexBuffer* i);
    void draw();
    ~Mesh();
    
private:
    IndexBuffer* indexBuffer;
    VertexBuffer* vertexBuffer;

};
