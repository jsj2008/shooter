//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "HGLMaterial.h"
#import "GLES.h"
#import "HGLTexture.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

HGLMaterial::HGLMaterial()
{
    texture = NULL;
    texture_name = "";
}

void HGLMaterial::bind()
{
    glUniform4fv(GLES::uMaterialAmbient, 1, (float*)(&ambient));
    glUniform4fv(GLES::uMaterialDiffuse, 1, (float*)(&diffuse));
    glUniform4fv(GLES::uMaterialSpecular, 1, (float*)(&specular));
    glUniform1f(GLES::uMaterialShininess, shininess);
    if (texture)
    {
        texture->bind();
    }
}

void HGLMaterial::unbind()
{
    if (texture)
    {
        texture->unbind();
    }
}

HGLMaterial::~HGLMaterial()
{
    if (texture)
    {
        free(texture);
    }
}
