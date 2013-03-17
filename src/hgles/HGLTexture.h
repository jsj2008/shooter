//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

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
        static void deleteAllTextures();
        HGLTexture();
        HGLTexture(const HGLTexture& obj); // コピーコンストラクタ
        void bind();
        void unbind();
        ~HGLTexture();
        GLKMatrix4 getTextureMatrix(int x, int y, int w, int h);
        void setTextureArea(int x, int y, int w, int h);
        void setTextureMatrix(GLKMatrix4 mat);
        Color color;
        Color blendColor;
        float repeatNum;
        unsigned int blend1;
        unsigned int blend2;
        float isAlphaMap;
        
        size_t width;
        size_t height;
        size_t sprWidth;
        size_t sprHeight;
    private:
        static std::map<std::string, HGLTexture*> textureIds;
        GLuint textureId;
        GLKMatrix4 textureMatrix;
        std::string textureName;
        void setTextureArea(int textureW,int textureH, int x, int y, int w, int h);
    };
}
