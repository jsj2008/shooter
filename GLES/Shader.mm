//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "Shader.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <string>

// static
GLuint Shader::aPositionSlot        ;
GLuint Shader::aColorSlot           ;
GLuint Shader::uProjectionMatrixSlot;
GLuint Shader::uModelViewMatrixSlot ;

// static
GLuint Shader::projectionMatrixSlot()
{
    return uProjectionMatrixSlot;
}

GLuint Shader::modelViewMatrixSlot()
{
    return uModelViewMatrixSlot;
}

GLuint Shader::positionSlot()
{
    return aPositionSlot;
}

GLuint Shader::colorSlot()
{
    return aColorSlot;
}

GLuint Shader::compileShader(NSString* shaderName, GLenum shaderType)
{
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

void Shader::compileShaders()
{
    // 1
    GLuint vertexShader = Shader::compileShader(@"vertex", GL_VERTEX_SHADER);
    GLuint fragmentShader = Shader::compileShader(@"fragment", GL_FRAGMENT_SHADER);
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    aPositionSlot = glGetAttribLocation(programHandle, "Position");
    aColorSlot = glGetAttribLocation(programHandle, "SourceColor");
    
    uProjectionMatrixSlot = glGetUniformLocation(programHandle, "Projection");
    uModelViewMatrixSlot = glGetUniformLocation(programHandle, "Modelview");
    
}

