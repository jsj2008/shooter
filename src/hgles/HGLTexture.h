//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//
#ifndef __HGLTEXTURE
#define __HGLTEXTURE

#import <Foundation/Foundation.h>
#import "HGLTypes.h"
#import <string>
#import <GLKit/GLKit.h>
#import "HGLVector3.h"
#import <map>

namespace hgles {
    
    typedef struct t_hgl_tex_cache
    {
        GLuint textureId;
        size_t width;
        size_t height;
    } t_hgl_tex_cache;
    
    //void initializeTextureIds();
    
    class HGLTexture
    {
    public:
        static HGLTexture* createTextureWithAsset(std::string name);
        static HGLTexture* createTextureWithString(std::string text, Color fontColor);
        static void deleteAllTextures();
        HGLTexture();
        HGLTexture(const HGLTexture& obj); // コピーコンストラクタ
        void bind();
        void unbind();
        void deleteTexture();
        ~HGLTexture();
        GLKMatrix4 getTextureMatrix(int x, int y, int w, int h);
        void setTextureArea(int x, int y, int w, int h);
        void setTextureMatrix(GLKMatrix4 mat);
        void setBlendFunc(int a, int b);
        Color color;
        Color blendColor;
        float repeatNum;
        unsigned int blend1;
        unsigned int blend2;
        float isAlphaMap;
        
        size_t width;
        size_t height;
    private:
        GLuint textureId;
        GLKMatrix4 textureMatrix;
        std::string textureName;
        void setTextureArea(int textureW,int textureH, int x, int y, int w, int h);
    };
}
#endif