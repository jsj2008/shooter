//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//
#ifndef __INDEXBUF
#define __INDEXBUF

#import <Foundation/Foundation.h>

namespace hgles {
    
    class HGLIndexBuffer
    {
    public:
        HGLIndexBuffer(const GLushort* indices, int num);
        void bind();
        void draw();
        void unbind();
        ~HGLIndexBuffer();
    private:
        GLuint indexBuffer;
        int size;
    };
    
}
#endif