//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGLTypes.h"
#import "HGLTexture.h"
#import <string>

class HGLMaterial
{
public:
    HGLMaterial():
        texture_name("")
        {}
    void bind();
    void unbind();
    ~HGLMaterial();
    
    Color ambient;
    Color diffuse;
    Color specular;
    float shininess;
    
    std::string name;
    std::string texture_name; // obj loader用
};
