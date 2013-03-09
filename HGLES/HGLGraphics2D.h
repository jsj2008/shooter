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

typedef struct t_hgl2d
{
    t_hgl2d():
    scale(1,1,1),
    position(0,0,0),
    rotate(0,0,0),
    //paralell(1),
    alpha(1)
    {}
    HGLTexture texture;
    HGLVector3 scale;
    HGLVector3 position;
    HGLVector3 rotate;
    //float paralell; // cameraに並行
    float alpha; // alpha値
} t_hgl2d;

class HGLGraphics2D
{
public:
    static void initialize();
    static void draw(t_hgl2d* t);
    
private:
    static HGLVertexBuffer* vertexBuffer;
    static HGLIndexBuffer* indexBuffer;
    
};
