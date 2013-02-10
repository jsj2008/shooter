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

class Texture
{
public:
    static Texture* createTextureWithAsset(std::string name);
    Texture();
    void bind();
    void unbind();
    ~Texture();
private:
    GLuint textureId;
};
