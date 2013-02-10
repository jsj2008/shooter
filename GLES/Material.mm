//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "Material.h"
#import "GLES.h"
#import "Texture.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>

Material::Material()
{
    texture = NULL;
    texture_name = "";
}

void Material::bind()
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

void Material::unbind()
{
    if (texture)
    {
        texture->unbind();
    }
}

Material::~Material()
{
    if (texture)
    {
        free(texture);
    }
}
