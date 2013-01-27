//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>

class IndexBuffer
{
public:
    IndexBuffer(const GLubyte* indices, int size);
    void bind();
    void draw();
    void unbind();
    ~IndexBuffer();
private:
    GLuint indexBuffer;
    int size;
};
