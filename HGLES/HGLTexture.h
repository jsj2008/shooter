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

class HGLTexture
{
public:
    static HGLTexture* createTextureWithAsset(std::string name);
    HGLTexture();
    void bind();
    void unbind();
    ~HGLTexture();
    GLKMatrix4 getTextureMatrix(int x, int y, int w, int h);
    void setTextureMatrix(GLKMatrix4 mat);
    void useAsAlphaMap(bool p);
    Color color;
    float repeatNum;
    
private:
    GLuint textureId;
    size_t width;
    size_t height;
    GLKMatrix4 textureMatrix;
    float isAlphaMap;
    void setTextureArea(int textureW,int textureH, int x, int y, int w, int h);
};
