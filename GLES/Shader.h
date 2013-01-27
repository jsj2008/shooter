//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>

class Shader
{
public:
    static void compileShaders();
    static GLuint projectionMatrixSlot();
    static GLuint modelViewMatrixSlot();
    static GLuint positionSlot();
    static GLuint colorSlot();
    static GLuint compileShader(NSString* shaderName, GLenum shaderType);
private:
static GLuint aPositionSlot        ;
static GLuint aColorSlot           ;
static GLuint uProjectionMatrixSlot;
static GLuint uModelViewMatrixSlot ;
};
