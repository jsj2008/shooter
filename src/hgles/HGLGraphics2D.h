//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//
#import "HGLVertexBuffer.h"
#import "HGLIndexBuffer.h"
#import "HGLTexture.h"

namespace hgles {
    
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
    
    class HGLGraphics2D
    {
    public:
        static void initialize();
        static void draw(t_hgl2di* t);
        
        static void drawLike3d(HGLVector3* position,
                         HGLVector3* scale,
                         HGLVector3* rotate,
                         HGLTexture* texture);
        
        static void draw(HGLVector3* position,
                         HGLVector3* scale,
                         HGLVector3* rotate,
                         HGLTexture* texture);
        
    private:
        static HGLVertexBuffer* vertexBuffer;
        static HGLIndexBuffer* indexBuffer;
        
    };
}
