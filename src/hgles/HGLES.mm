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
#import <GLKit/GLKit.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <string>
#import "HGLCommon.h"

namespace hgles {
    
    std::map<int, t_context> contextMap;
    int contextIdIndex = -1;
    
    float HGLES::viewWidth;
    float HGLES::viewHeight;
    
    int currentContextId = 0;
    t_context* currentContext = NULL;
    void setCurrentContext(int contextId)
    {
        currentContextId = contextId;
        currentContext = &contextMap[currentContextId];
    }
    
    void HGLES::pushMatrix()
    {
        currentContext->matrixStack.push(currentContext->mvMatrix);
    }
    
    void HGLES::popMatrix()
    {
        currentContext->mvMatrix = currentContext->matrixStack.top();
        currentContext->matrixStack.pop();
    }
    
    int HGLES::initialize(float viewWidth, float viewHeight)
    {
        // 現在のコンテキストを作成
        contextIdIndex++;
        contextMap[contextIdIndex] = {};
        setCurrentContext(contextIdIndex);
        glViewport(0, 0, viewWidth, viewHeight);
        compileShaders();
        HGLES::viewWidth = viewWidth;
        HGLES::viewHeight = viewHeight;
        float aspect = (float)(viewWidth / viewHeight);
        currentContext->projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(80.0f), aspect, 0.1f, 2000.0f);
        currentContext->mvMatrix = GLKMatrix4Identity;
        
        return contextIdIndex;
    }
    
    void HGLES::updateCameraMatrix()
    {
        currentContext->cameraMatrix = GLKMatrix4Identity;
        currentContext->cameraMatrix = GLKMatrix4Rotate(currentContext->cameraMatrix, currentContext->cameraRotate.x, 1, 0, 0);
        currentContext->cameraMatrix = GLKMatrix4Rotate(currentContext->cameraMatrix, currentContext->cameraRotate.y, 0, 1, 0);
        currentContext->cameraMatrix = GLKMatrix4Rotate(currentContext->cameraMatrix, currentContext->cameraRotate.z, 0, 0, 1);
        currentContext->cameraMatrix = GLKMatrix4Translate(currentContext->cameraMatrix, currentContext->cameraPosition.x, currentContext->cameraPosition.y, currentContext->cameraPosition.z);
    }
    
    void HGLES::updateMatrix()
    {
        // 視点行列にモデル行列を掛けること
        currentContext->mvMatrix = GLKMatrix4Multiply(currentContext->cameraMatrix, currentContext->mvMatrix);
        glUniformMatrix4fv(currentContext->uModelViewMatrixSlot, 1, 0, currentContext->mvMatrix.m);
        GLKMatrix4 mvpMatrix = GLKMatrix4Multiply(currentContext->projectionMatrix, currentContext->mvMatrix);
        glUniformMatrix4fv(currentContext->uMvpMatrixSlot, 1, 0, mvpMatrix.m);
        
        // モデルビュー行列の逆転置行列の指定
        GLKMatrix4 normalM = currentContext->mvMatrix;
        bool result = true;
        normalM = GLKMatrix4InvertAndTranspose(normalM, (bool*)&result);
        glUniformMatrix4fv(currentContext->uNormalMatrixSlot, 1, false, normalM.m);
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
        
        currentContext->aPositionSlot = glGetAttribLocation(programHandle, "aPosition");
        currentContext->aNormalSlot = glGetAttribLocation(programHandle, "aNormal");
        currentContext->aUVSlot = glGetAttribLocation(programHandle, "aUV");
        
        currentContext->uMvpMatrixSlot = glGetUniformLocation(programHandle, "uMvpMatrix");
        currentContext->uNormalMatrixSlot = glGetUniformLocation(programHandle, "uNormalMatrix");
        
        currentContext->uMaterialAmbient = glGetUniformLocation(programHandle, "uMaterialAmbient");
        currentContext->uMaterialDiffuse = glGetUniformLocation(programHandle, "uMaterialDiffuse");
        currentContext->uMaterialSpecular = glGetUniformLocation(programHandle, "uMaterialSpecular");
        currentContext->uMaterialShininess = glGetUniformLocation(programHandle, "uMaterialShininess");
        
        currentContext->uLightAmbientSlot = glGetUniformLocation(programHandle, "uLightAmbient");
        currentContext->uLightDiffuseSlot = glGetUniformLocation(programHandle, "uLightDiffuse");
        currentContext->uLightSpecular = glGetUniformLocation(programHandle, "uLightSpecular");
        currentContext->uLightPos = glGetUniformLocation(programHandle, "uLightPos");
        currentContext->uUseLight = glGetUniformLocation(programHandle, "uUseLight");
        
        currentContext->uTexMatrixSlot = glGetUniformLocation(programHandle, "uTexMatrix");
        currentContext->uTexSlot = glGetUniformLocation(programHandle, "uTex");
        currentContext->uUseTexture = glGetUniformLocation(programHandle, "uUseTexture");
        currentContext->uTextureRepeatNum = glGetUniformLocation(programHandle, "uTextureRepeatNum");
        
        currentContext->uColor = glGetUniformLocation(programHandle, "uColor");
        currentContext->uBlendColor = glGetUniformLocation(programHandle, "uBlendColor");
        
        currentContext->uUseAlphaMap = glGetUniformLocation(programHandle, "uUseAlphaMap");
        
        currentContext->uAlpha = glGetUniformLocation(programHandle, "uAlpha");
        
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