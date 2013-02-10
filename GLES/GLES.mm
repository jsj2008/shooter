//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "GLES.h"
#import "GLTypes.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <string>

std::stack<GLKMatrix4> GLES::matrixStack;

GLKMatrix4 GLES::mvMatrix;
GLKMatrix4 GLES::projectionMatrix;

GLuint GLES::aPositionSlot        ;
GLuint GLES::aNormalSlot          ;
GLuint GLES::aUVSlot              ;

GLuint GLES::uProjectionMatrixSlot;
GLuint GLES::uModelViewMatrixSlot ;
GLuint GLES::uNormalMatrixSlot    ;

GLuint GLES::uLightAmbientSlot;
GLuint GLES::uLightDiffuseSlot;
GLuint GLES::uLightSpecular;
GLuint GLES::uLightPos;

GLuint GLES::uMaterialAmbient;
GLuint GLES::uMaterialDiffuse;
GLuint GLES::uMaterialSpecular;
GLuint GLES::uMaterialShininess;

GLuint GLES::uTexMatrixSlot;
GLuint GLES::uTexSlot;

// 光源設定
Color GLES::ambient;
Color GLES::diffuse;
Color GLES::specular;
Position GLES::lightPos;

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
    setDefault();
}

void GLES::setDefault()
{
    // light
    ambient = {1.0, 1.0, 1.0, 1.0};
    diffuse = {0.7, 0.7, 0.7, 1.0};
    specular = {1.9, 1.9, 1.9, 1.0};
    lightPos = {115.0, 115.0, 0.0};
    glUniform4fv(uLightAmbientSlot, 1, (GLfloat*)(&ambient));
    glUniform4fv(uLightDiffuseSlot, 1, (GLfloat*)(&diffuse));
    glUniform4fv(uLightSpecular, 1, (GLfloat*)(&specular));
    glUniform3fv(uLightPos, 1, (GLfloat*)(&lightPos));
    
    // texture
    GLKMatrix4 texMatrix = GLKMatrix4Identity;
    glUniformMatrix4fv(uTexMatrixSlot, 1, 0, texMatrix.m);
}

void GLES::updateMatrix()
{
    glUniformMatrix4fv(GLES::uProjectionMatrixSlot, 1, 0, GLES::projectionMatrix.m);
    glUniformMatrix4fv(GLES::uModelViewMatrixSlot, 1, 0, GLES::mvMatrix.m);
    // モデルビュー行列の逆転置行列の指定
    GLKMatrix4 normalM = GLES::mvMatrix;
    bool result = true;
    normalM = GLKMatrix4InvertAndTranspose(normalM, (bool*)&result);
    glUniformMatrix4fv(GLES::uNormalMatrixSlot, 1, false, normalM.m);
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
    
    
    // 5
    aPositionSlot = glGetAttribLocation(programHandle, "aPosition");
    aNormalSlot = glGetAttribLocation(programHandle, "aNormal");
    aUVSlot = glGetAttribLocation(programHandle, "aUV");
    //aNormalSlot = glGetAttribLocation(programHandle, "aNormal");
    //aNormalSlot = glGetAttribLocation(programHandle, "normal");
    //aColorSlot = glGetAttribLocation(programHandle, "SourceColor");
    
    uProjectionMatrixSlot = glGetUniformLocation(programHandle, "uPMatrix");
    uModelViewMatrixSlot = glGetUniformLocation(programHandle, "uMMatrix");
    uNormalMatrixSlot = glGetUniformLocation(programHandle, "uNormalMatrix");
    
    uMaterialAmbient = glGetUniformLocation(programHandle, "uMaterialAmbient");
    uMaterialDiffuse = glGetUniformLocation(programHandle, "uMaterialDiffuse");
    uMaterialSpecular = glGetUniformLocation(programHandle, "uMaterialSpecular");
    uMaterialShininess = glGetUniformLocation(programHandle, "uMaterialShininess");
    
    uLightAmbientSlot = glGetUniformLocation(programHandle, "uLightAmbient");
    uLightDiffuseSlot = glGetUniformLocation(programHandle, "uLightDiffuse");
    uLightSpecular = glGetUniformLocation(programHandle, "uLightSpecular");
    uLightPos = glGetUniformLocation(programHandle, "uLightPos");
    
    uTexMatrixSlot = glGetUniformLocation(programHandle, "uTexMatrix");
    uTexSlot = glGetUniformLocation(programHandle, "uTex");
    
    
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
    
}

