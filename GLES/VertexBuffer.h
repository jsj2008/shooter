//
//  VertexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGLTypes.h"

class VertexBuffer
{
public:
    VertexBuffer(const Vertex* v, int num);
    void bind();
    void unbind();
    ~VertexBuffer();
private:
    GLuint vertexBuffer;
};

