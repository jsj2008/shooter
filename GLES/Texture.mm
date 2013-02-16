//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

// <注意点>
// 先に不透明なものを描画してから透明なものを描画すること
// 24bitカラー、アルファ付きの画像をテクスチャとして使用すること
// (インデックスカラーは不可)

#import "Texture.h"
#import "GLES.h"
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

Texture* Texture::createTextureWithAsset(std::string name)
{
    
    glEnable(GL_TEXTURE_2D);
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    Texture* tex = new Texture();
    glGenTextures(1, &tex->textureId);
    
    CGImageRef image;
    CGContextRef spriteContext;
    GLubyte *spriteData;
    size_t    width, height;
    
    image = [UIImage imageNamed:[NSString stringWithCString:name.c_str() encoding:NSUTF8StringEncoding]].CGImage;
    width = CGImageGetWidth(image);
    height = CGImageGetHeight(image);
    tex->width = width; tex->height = height;
    
    if(image) {
        spriteData = (GLubyte *) malloc(width * height * 4); // 32bit color
        spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
        
        // 一旦コメント
        //these next two lines are necessary because the iPhone has its y-axis upside down, so everything looks flipped
        //CGContextTranslateCTM(spriteContext, 0.0, height); //i.e., move the y-origin from the top to the bottom
        //CGContextScaleCTM(spriteContext, 1.0, -1.0); //i.e., invert the y-axis
        
        CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
        CGContextRelease(spriteContext);
        glBindTexture(GL_TEXTURE_2D, tex->textureId);    // first Bind creates the texture and assigns a numeric name to it
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        free(spriteData);
        
        //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glEnable(GL_TEXTURE_2D);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
    }
    
    return tex;
}

Texture::Texture()
{
    textureId = 0;
    textureMatrix = GLKMatrix4Identity;
}

// テクスチャ領域の指定
// テクスチャ行列を使ってテクスチャの一部分を表示する
void Texture::setTextureArea(int textureW,int textureH, int x, int y, int w, int h)
{
    //ピクセル座標をUV座標に変換
    float tw=(float)w/(float)textureW;
    float th=(float)h/(float)textureH;
    float tx=(float)x/(float)textureW;
    float ty=(float)y/(float)textureH;
    
    //テクスチャ行列の移動・拡大縮小
    textureMatrix = GLKMatrix4Identity;
    textureMatrix = GLKMatrix4Translate(textureMatrix, tx, ty, 0);
    textureMatrix = GLKMatrix4Scale(textureMatrix, tw, th, 0);
}

void Texture::bind()
{
   if (textureId)
    {
        setTextureArea(width, height, 0, 0, 64, 64);
        // テクスチャ使用フラグ
        glUniform1f(GLES::uUseTexture, 1.0);
        glEnable(GL_TEXTURE_2D);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, textureId);
        glUniform1f(GLES::uTexSlot, 0);
        // テクスチャ行列
        glUniformMatrix4fv(GLES::uTexMatrixSlot, 1, 0, textureMatrix.m);
    }
}

void Texture::unbind()
{
    glUniform1f(GLES::uUseTexture, 0);
    glDisable(GL_TEXTURE_2D);
    glBindTexture(GL_TEXTURE_2D, 0);
}

Texture::~Texture()
{
    if (textureId)
    {
        glDeleteTextures(1, &textureId);
        textureId = 0;
    }
}

