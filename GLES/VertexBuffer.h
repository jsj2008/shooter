//
//  VertexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
    float Position[3];
    float Color[4];
} Vertex;

class VertexBuffer
{
public:
    VertexBuffer(const Vertex* v, int size);
    void bind();
    void unbind();
    ~VertexBuffer();
private:
    GLuint vertexBuffer;
};

