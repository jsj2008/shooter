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

typedef struct t_2d
{
    t_2d():
    texture(NULL),
    scale(1,1,1),
    position(0,0,0),
    rotate(0,0,0),
    paralell(1),
    alpha(1),
    blend1(GL_SRC_ALPHA),
    blend2(GL_ONE_MINUS_SRC_ALPHA),
    isAlphaMap(0),
    color({1,1,1,1}),
    textureRepeatNum(1),
    isSprite(0)
    {}
    HGLTexture* texture;
    HGLVector3 scale;
    HGLVector3 position;
    HGLVector3 rotate;
    
    float paralell; // cameraに並行
    float alpha; // alpha値
    // 合成方法
    unsigned int blend1;
    unsigned int blend2;
    
    float isAlphaMap; // アルファマップ
    Color color; // アルファマップの色指定
    
    short textureRepeatNum; // 繰り返し回数
    
    // sprite
    short isSprite;
    short textureX;
    short textureY;
    short textureW;
    short textureH;
} t_2d;

class HGLGraphics2D
{
public:
    static void setup();
    static void draw(t_2d* t);
    
private:
    static HGLVertexBuffer* vertexBuffer;
    static HGLIndexBuffer* indexBuffer;
    
};
