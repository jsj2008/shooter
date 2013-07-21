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

#import "HGLTexture.h"
#import "HGLES.h"
#include <Foundation/Foundation.h>
#import <QuartzCore/CALayer.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <map>
#include <vector>

namespace hgles {
    
    const unsigned int TEXTURE_MAX_NUM = 100;
    
    //std::map<std::string, HGLTexture*> HGLTexture::textureIds;
    
    HGLTexture* HGLTexture::createTextureWithAsset(std::string name)
    {
        if (textureIds.find(name) == textureIds.end())
        {
            HGLTexture* tex = new HGLTexture();
            
            glEnable(GL_TEXTURE_2D);
            glBlendFunc(GL_ONE, GL_ZERO);
            glEnable(GL_BLEND);
            
            GLuint texid;
            glGenTextures(1, &texid);
            tex->textureId = texid;
            
            CGImageRef image;
            CGContextRef spriteContext;
            GLubyte *spriteData;
            size_t    width, height;
            
            image = [UIImage imageNamed:[NSString stringWithCString:name.c_str() encoding:NSUTF8StringEncoding]].CGImage;
            width = CGImageGetWidth(image);
            height = CGImageGetHeight(image);
            tex->width = width;
            tex->height = height;
            
            if(image) {
                spriteData = (GLubyte*)calloc(1, width*height*4);
                spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
                
                CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
                CGContextRelease(spriteContext);
                
                glBindTexture(GL_TEXTURE_2D, tex->textureId);    // first Bind creates the texture and assigns a numeric name to it
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
                glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
                
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
                
                free(spriteData);
                
                glBindTexture(GL_TEXTURE_2D, 0);
                
            }
            (textureIds)[name] = tex;
            return tex;
        }
        else
        {
            return (textureIds)[name];
        }
        
    }
    
    HGLTexture* HGLTexture::createTextureWithString(std::string text, Color fontColor)
    {
        NSString* fontName = @"HiraKakuProN-W6";
        UIFont* font = [UIFont fontWithName:fontName size:20];
        NSLineBreakMode bm = NSLineBreakByCharWrapping;
        NSString* strText = [NSString stringWithCString:text.c_str() encoding:NSUTF8StringEncoding];
        // テキストのサイズを計算
        CGSize expectedLabelSize = [strText sizeWithFont:font constrainedToSize:CGSizeMake(1024, 1024) lineBreakMode:bm];
        
        // 空の画像を生成
        float width = expectedLabelSize.width;
        float height = expectedLabelSize.height;
        
        // 最小の２のべき乗に変換
        int wk = 32;
        float tmp = width;
        do {
            wk = wk << 1;
            tmp = wk;
        } while (tmp < width && tmp <= 1024);
        width = tmp;
        wk = 32;
        tmp = height;
        do {
            wk = wk << 1;
            tmp = wk;
        } while (tmp < height && tmp <= 1024);
        height = tmp;
        
        CGImageRef image;
        
        {
            UIGraphicsBeginImageContext(CGSizeMake(width, height));
            CGContextRef context = UIGraphicsGetCurrentContext();
            
            UILabel* label = [[[UILabel alloc] initWithFrame:CGRectMake(0,0,width, height)] autorelease];
            [label setText:[NSString stringWithCString:text.c_str() encoding:NSUTF8StringEncoding]];
            [label setFont: font];
            label.textColor = [UIColor colorWithRed:fontColor.r green:fontColor.g blue:fontColor.b alpha:fontColor.a];
            label.backgroundColor = [UIColor clearColor];
            [label.layer renderInContext:context];
            [label setTextAlignment:NSTextAlignmentLeft];
            UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
            image = img.CGImage;
            UIGraphicsEndImageContext();
        }
    
        HGLTexture* tex = new HGLTexture();
        glEnable(GL_TEXTURE_2D);
        glBlendFunc(GL_ONE, GL_ZERO);
        glEnable(GL_BLEND);
        
        GLuint texid;
        glGenTextures(1, &texid);
        tex->textureId = texid;
        tex->width = width;
        tex->height = height;
        
        GLubyte *spriteData = (GLubyte*)calloc(1, width*height*4);
        CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
        
        CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
        CGContextRelease(spriteContext);
        
        glBindTexture(GL_TEXTURE_2D, tex->textureId);    // first Bind creates the texture and assigns a numeric name to it
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
        
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        
        free(spriteData);
        
        glBindTexture(GL_TEXTURE_2D, 0);
        
        return tex;
    }
    
    HGLTexture::HGLTexture(const HGLTexture& obj)
    {
        this->textureId = obj.textureId;
        this->width = obj.width;
        this->height = obj.height;
    }
    
    ////////////////////
    // 呼び出す際にはコンテキストに注意
    void HGLTexture::deleteAllTextures()
    {
        for (std::map<std::string, HGLTexture*>::iterator itr = textureIds.begin(); itr != textureIds.end(); itr++)
        {
            HGLTexture* t = itr->second;
            glDeleteTextures(1, &t->textureId);
            delete t;
        }
        textureIds.clear();
    }
    
    void HGLTexture::deleteTexture()
    {
        glDeleteTextures(1, &textureId);
    }
    
    GLKMatrix4 HGLTexture::getTextureMatrix(int x, int y, int w, int h)
    {
        //ピクセル座標をUV座標に変換
        float tw=(float)w/(float)width;
        float th=(float)h/(float)height;
        float tx=(float)x/(float)width;
        float ty=(float)y/(float)height;
        
        //テクスチャ行列の移動・拡大縮小
        GLKMatrix4 mat = GLKMatrix4Identity;
        mat = GLKMatrix4Translate(mat, tx, ty, 0);
        mat = GLKMatrix4Scale(mat, tw, th, 0);
        return mat;
    }
    
    void HGLTexture::setTextureMatrix(GLKMatrix4 mat)
    {
        textureMatrix = mat;
    }
    
    void HGLTexture::setBlendFunc(int a, int b)
    {
        blend1 = a;
        blend2 = b;
    }
    
    HGLTexture::HGLTexture()
    {
        textureId = 0;
        textureMatrix = GLKMatrix4Identity;
        isAlphaMap = 0.0;
        color.r = 1.0; color.g = 1.0; color.b = 1.0; color.a = 1.0;
        blendColor = {1.0, 1.0, 1.0, 1.0};
        repeatNum = 1;
        blend1 = GL_SRC_ALPHA;
        blend2 = GL_ONE_MINUS_SRC_ALPHA;
    }
    
    void HGLTexture::setTextureArea(int x, int y, int w, int h)
    {
        this->setTextureArea(width, height, x, y, w, h);
    }
    
    // テクスチャ領域の指定
    // テクスチャ行列を使ってテクスチャの一部分を表示する
    void HGLTexture::setTextureArea(int textureW,int textureH, int x, int y, int w, int h)
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
    
    void HGLTexture::bind()
    {
        //if (textureId != -1)
        //{
        // テクスチャ使用フラグ
        glEnable(GL_TEXTURE_2D);
        glActiveTexture(GL_TEXTURE0);
        
        if (currentTextureId != textureId)
        {
            glBindTexture(GL_TEXTURE_2D, textureId);
            currentTextureId = textureId;
        }
        glBlendFunc(blend1, blend2);
        glUniform1f(currentContext->uTexSlot, 0);
        glUniform1f(currentContext->uUseTexture, 1.0);
        glUniform1f(currentContext->uUseAlphaMap, isAlphaMap);
        glUniform1f(currentContext->uTextureRepeatNum, repeatNum);
        glUniform1f(currentContext->uAlpha, color.a);
        
        // テクスチャ行列
        glUniformMatrix4fv(currentContext->uTexMatrixSlot, 1, 0, textureMatrix.m);
        if (isAlphaMap)
        {
            glUniform4fv(currentContext->uColor, 1, (GLfloat*)(&color));
        }
        glUniform4fv(currentContext->uBlendColor, 1, (GLfloat*)(&blendColor));
        //}
    }
    
    void HGLTexture::unbind()
    {
        glUniform1f(currentContext->uUseTexture, 0);
        glUniform1f(currentContext->uUseAlphaMap, 0);
        glDisable(GL_TEXTURE_2D);
        //glBindTexture(GL_TEXTURE_2D, 0);
    }
    
    HGLTexture::~HGLTexture()
    {
        // 再使用するのでここではテクスチャをビデオメモリから削除しない
    }
    
}
