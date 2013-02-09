//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GLTypes.h"
#import <string>

class Material
{
public:
    Material();
    void bind();
    void unbind();
    ~Material();
    
    Color ambient;
    Color diffuse;
    Color specular;
    float shininess;
    std::string name;
};
