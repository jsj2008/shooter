//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "GLES.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <string>

std::stack<GLKMatrix4> GLES::matrixStack;

GLKMatrix4 GLES::mvMatrix;
GLKMatrix4 GLES::projectionMatrix;

GLuint GLES::aPositionSlot        ;
//GLuint GLES::aColorSlot           ;
GLuint GLES::uProjectionMatrixSlot;
GLuint GLES::uModelViewMatrixSlot ;

float GLES::viewWidth;
float GLES::viewHeight;

void GLES::pushMatrix()
{
    matrixStack.push(mvMatrix);
}

void GLES::popMatrix()
{
    mvMatrix = matrixStack.top();
    matrixStack.pop();
}

void GLES::initialize(float viewWidth, float viewHeight)
{
    glViewport(0, 0, viewWidth, viewHeight);
    compileShaders();
    GLES::viewWidth = viewWidth;
    GLES::viewHeight = viewHeight;
    float aspect = (float)(viewWidth / viewHeight);
    GLES::projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 350.0f);
    mvMatrix = GLKMatrix4Identity;
}

void GLES::updateMatrix()
{
    glUniformMatrix4fv(GLES::uProjectionMatrixSlot, 1, 0, GLES::projectionMatrix.m);
    glUniformMatrix4fv(GLES::uModelViewMatrixSlot, 1, 0, GLES::mvMatrix.m);
}

GLuint GLES::compileShader(NSString* shaderName, GLenum shaderType)
{
    
    // 1
    NSString* GLESPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* GLESString = [NSString stringWithContentsOfFile:GLESPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!GLESString) {
        NSLog(@"Error loading GLES: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint GLESHandle = glCreateShader(shaderType);
    
    // 3
    const char * GLESStringUTF8 = [GLESString UTF8String];
    int GLESStringLength = [GLESString length];
    glShaderSource(GLESHandle, 1, &GLESStringUTF8, &GLESStringLength);
    
    // 4
    glCompileShader(GLESHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(GLESHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(GLESHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return GLESHandle;
    
}

void GLES::compileShaders()
{
    // 1
    GLuint vertexShader = GLES::compileShader(@"vertex", GL_VERTEX_SHADER);
    GLuint fragmentShader = GLES::compileShader(@"fragment", GL_FRAGMENT_SHADER);
    
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
    //aColorSlot = glGetAttribLocation(programHandle, "SourceColor");
    
    uProjectionMatrixSlot = glGetUniformLocation(programHandle, "Projection");
    uModelViewMatrixSlot = glGetUniformLocation(programHandle, "Modelview");
    
}

