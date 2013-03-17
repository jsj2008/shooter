//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "HGLES.h"
#import "HGLTypes.h"
#import "HGLVector3.h"
#import "HGLTexture.h"
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <string>
#import "HGLCommon.h"

namespace hgles {
    
    std::stack<GLKMatrix4> HGLES::matrixStack;
    
    GLKMatrix4 HGLES::mvMatrix;
    GLKMatrix4 HGLES::cameraMatrix;
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
    GLuint HGLES::uUseLight;
    
    GLuint HGLES::uMaterialAmbient;
    GLuint HGLES::uMaterialDiffuse;
    GLuint HGLES::uMaterialSpecular;
    GLuint HGLES::uMaterialShininess;
    
    GLuint HGLES::uTexMatrixSlot;
    GLuint HGLES::uTexSlot;
    GLuint HGLES::uUseTexture;
    GLuint HGLES::uTextureRepeatNum;
    
    GLuint HGLES::uColor;
    GLuint HGLES::uBlendColor;
    
    GLuint HGLES::uUseAlphaMap;
    
    // アルファ
    GLuint HGLES::uAlpha;
    
    // 光源設定
    Color HGLES::ambient;
    Color HGLES::diffuse;
    Color HGLES::specular;
    Position HGLES::lightPos;
    
    float HGLES::viewWidth;
    float HGLES::viewHeight;
    
    // カメラ
    HGLVector3 HGLES::cameraPosition;
    HGLVector3 HGLES::cameraRotate;
    
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
        HGLES::projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(80.0f), aspect, 0.1f, 2000.0f);
        mvMatrix = GLKMatrix4Identity;
        initializeTextureIds();
    }
    
    void HGLES::updateMatrix()
    {
        // 視点行列にモデル行列を掛けること
        HGLES::mvMatrix = GLKMatrix4Multiply(HGLES::cameraMatrix, HGLES::mvMatrix);
        glUniformMatrix4fv(HGLES::uModelViewMatrixSlot, 1, 0, HGLES::mvMatrix.m);
        GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(projectionMatrix, HGLES::mvMatrix);
        glUniformMatrix4fv(HGLES::uMvpMatrixSlot, 1, 0, mvpMatrix.m);
        
        // モデルビュー行列の逆転置行列の指定
        GLKMatrix4 normalM = HGLES::mvMatrix;
        bool result = true;
        normalM = GLKMatrix4InvertAndTranspose(normalM, (bool*)&result);
        glUniformMatrix4fv(HGLES::uNormalMatrixSlot, 1, false, normalM.m);
    }
    
    GLuint HGLES::compileShader(NSString* shaderName, GLenum shaderType)
    {
        
        NSString* GLESPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                             ofType:@"glsl"];
        NSError* error;
        NSString* GLESString = [NSString stringWithContentsOfFile:GLESPath
                                                         encoding:NSUTF8StringEncoding error:&error];
        if (!GLESString) {
            LOG(@"Error loading GLES: %@", error.localizedDescription);
            exit(1);
        }
        
        GLuint GLESHandle = glCreateShader(shaderType);
        
        const char * GLESStringUTF8 = [GLESString UTF8String];
        int GLESStringLength = [GLESString length];
        glShaderSource(GLESHandle, 1, &GLESStringUTF8, &GLESStringLength);
        
        glCompileShader(GLESHandle);
        
        GLint compileSuccess;
        glGetShaderiv(GLESHandle, GL_COMPILE_STATUS, &compileSuccess);
        if (compileSuccess == GL_FALSE) {
            GLchar messages[256];
            glGetShaderInfoLog(GLESHandle, sizeof(messages), 0, &messages[0]);
            NSString *messageString = [NSString stringWithUTF8String:messages];
            LOG(@"%@", messageString);
            exit(1);
        }
        
        return GLESHandle;
        
    }
    
    void HGLES::compileShaders()
    {
        GLuint vertexShader = HGLES::compileShader(@"vertex2d", GL_VERTEX_SHADER);
        GLuint fragmentShader = HGLES::compileShader(@"fragment2d", GL_FRAGMENT_SHADER);
        
        GLuint programHandle = glCreateProgram();
        glAttachShader(programHandle, vertexShader);
        glAttachShader(programHandle, fragmentShader);
        glLinkProgram(programHandle);
        
        aPositionSlot = glGetAttribLocation(programHandle, "aPosition");
        aNormalSlot = glGetAttribLocation(programHandle, "aNormal");
        aUVSlot = glGetAttribLocation(programHandle, "aUV");
        
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
        uUseLight = glGetUniformLocation(programHandle, "uUseLight");
        
        uTexMatrixSlot = glGetUniformLocation(programHandle, "uTexMatrix");
        uTexSlot = glGetUniformLocation(programHandle, "uTex");
        uUseTexture = glGetUniformLocation(programHandle, "uUseTexture");
        uTextureRepeatNum = glGetUniformLocation(programHandle, "uTextureRepeatNum");
        
        uColor = glGetUniformLocation(programHandle, "uColor");
        uBlendColor = glGetUniformLocation(programHandle, "uBlendColor");
        
        uUseAlphaMap = glGetUniformLocation(programHandle, "uUseAlphaMap");
        
        uAlpha = glGetUniformLocation(programHandle, "uAlpha");
        
        GLint linkSuccess;
        glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
        if (linkSuccess == GL_FALSE) {
            GLchar messages[256];
            glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
            NSString *messageString = [NSString stringWithUTF8String:messages];
            LOG(@"%@", messageString);
            exit(1);
        }
        
        glUseProgram(programHandle);
        
    }
    
}