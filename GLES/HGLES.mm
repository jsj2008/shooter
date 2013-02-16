//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "HGLES.h"
#import "GLTypes.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <string>

std::stack<GLKMatrix4> HGLES::matrixStack;

GLKMatrix4 HGLES::mvMatrix;
GLKMatrix4 HGLES::projectionMatrix;

GLuint HGLES::aPositionSlot        ;
GLuint HGLES::aNormalSlot          ;
GLuint HGLES::aUVSlot              ;

//GLuint HGLES::uProjectionMatrixSlot;
GLuint HGLES::uModelViewMatrixSlot ;
GLuint HGLES::uMvpMatrixSlot       ;
GLuint HGLES::uNormalMatrixSlot    ;

GLuint HGLES::uLightAmbientSlot;
GLuint HGLES::uLightDiffuseSlot;
GLuint HGLES::uLightSpecular;
GLuint HGLES::uLightPos;

GLuint HGLES::uMaterialAmbient;
GLuint HGLES::uMaterialDiffuse;
GLuint HGLES::uMaterialSpecular;
GLuint HGLES::uMaterialShininess;

GLuint HGLES::uTexMatrixSlot;
GLuint HGLES::uTexSlot;
GLuint HGLES::uUseTexture;

// 光源設定
Color HGLES::ambient;
Color HGLES::diffuse;
Color HGLES::specular;
Position HGLES::lightPos;

float HGLES::viewWidth;
float HGLES::viewHeight;

void HGLES::pushMatrix()
{
    matrixStack.push(mvMatrix);
}

void HGLES::popMatrix()
{
    mvMatrix = matrixStack.top();
    matrixStack.pop();
}

void HGLES::initialize(float viewWidth, float viewHeight)
{
    glViewport(0, 0, viewWidth, viewHeight);
    compileShaders();
    HGLES::viewWidth = viewWidth;
    HGLES::viewHeight = viewHeight;
    float aspect = (float)(viewWidth / viewHeight);
    HGLES::projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 350.0f);
    mvMatrix = GLKMatrix4Identity;
    setDefault();
}

void HGLES::setDefault()
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
}

void HGLES::updateMatrix()
{
    //glUniformMatrix4fv(HGLES::uProjectionMatrixSlot, 1, 0, HGLES::projectionMatrix.m);
    glUniformMatrix4fv(HGLES::uModelViewMatrixSlot, 1, 0, HGLES::mvMatrix.m);
    GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(projectionMatrix, mvMatrix);
    glUniformMatrix4fv(HGLES::uMvpMatrixSlot, 1, 0, mvpMatrix.m);
    
    
    // モデルビュー行列の逆転置行列の指定
    GLKMatrix4 normalM = HGLES::mvMatrix;
    bool result = true;
    normalM = GLKMatrix4InvertAndTranspose(normalM, (bool*)&result);
    glUniformMatrix4fv(HGLES::uNormalMatrixSlot, 1, false, normalM.m);
}

GLuint HGLES::compileShader(NSString* shaderName, GLenum shaderType)
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

void HGLES::compileShaders()
{
    // 1
    GLuint vertexShader = HGLES::compileShader(@"vertex", GL_VERTEX_SHADER);
    GLuint fragmentShader = HGLES::compileShader(@"fragment", GL_FRAGMENT_SHADER);
    
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
    
    //uProjectionMatrixSlot = glGetUniformLocation(programHandle, "uPMatrix");
    //uModelViewMatrixSlot = glGetUniformLocation(programHandle, "uMMatrix");
    uMvpMatrixSlot = glGetUniformLocation(programHandle, "uMvpMatrix");
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
    uUseTexture = glGetUniformLocation(programHandle, "uUseTexture");
    
    
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

