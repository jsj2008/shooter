//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "HGLMaterial.h"
#import "HGLES.h"
#import "HGLTexture.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

void HGLMaterial::bind()
{
    glUniform4fv(HGLES::uMaterialAmbient, 1, (float*)(&ambient));
    glUniform4fv(HGLES::uMaterialDiffuse, 1, (float*)(&diffuse));
    glUniform4fv(HGLES::uMaterialSpecular, 1, (float*)(&specular));
    glUniform1f(HGLES::uMaterialShininess, shininess);
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
