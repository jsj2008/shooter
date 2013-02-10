//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "Texture.h"
#import "GLES.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

Texture* Texture::createTextureWithAsset(std::string name)
{
    Texture* tex = new Texture();
    glGenTextures(1, &tex->textureId);
    
    CGImageRef image;
    CGContextRef spriteContext;
    GLubyte *spriteData;
    size_t    width, height;
    
    image = [UIImage imageNamed:[NSString stringWithCString:name.c_str() encoding:NSUTF8StringEncoding]].CGImage;
    width = CGImageGetWidth(image);
    height = CGImageGetHeight(image);
    
    if(image) {
        spriteData = (GLubyte *) malloc(width * height * 4); // 32bit color
        spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(image), kCGImageAlphaPremultipliedLast);
        //these next two lines are necessary because the iPhone has its y-axis upside down, so everything looks flipped
        CGContextTranslateCTM(spriteContext, 0.0, height); //i.e., move the y-origin from the top to the bottom
        CGContextScaleCTM(spriteContext, 1.0, -1.0); //i.e., invert the y-axis
        CGContextDrawImage(spriteContext, CGRectMake(0.0, 0.0, (CGFloat)width, (CGFloat)height), image);
        CGContextRelease(spriteContext);
        glBindTexture(GL_TEXTURE_2D, tex->textureId);    // first Bind creates the texture and assigns a numeric name to it
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        free(spriteData);
        
        //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        glEnable(GL_TEXTURE_2D);
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
    }
    
    return tex;
}

Texture::Texture()
{
    textureId = 0;
}

void Texture::bind()
{
    if (textureId)
    {
        glUniform1f(GLES::uUseTexture, 1.0);
        glEnable(GL_TEXTURE_2D);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, textureId);
        glUniform1f(GLES::uTexSlot, 0);
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
