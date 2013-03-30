//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//
#ifndef __HGLES
#define __HGLES

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import <stack>
#import <map>
#import "HGLTexture.h"

namespace hgles {
    
    typedef struct t_context
    {
        std::map<std::string, HGLTexture*> textureIds;
        std::stack<GLKMatrix4> matrixStack;
        GLKMatrix4 mvMatrix;
        GLKMatrix4 cameraMatrix;
        GLKMatrix4 projectionMatrix;
    } t_context;
    
    // 現在のコンテキストを設定する
    void setCurrentContext(int contextId);
    
    // 現在のコンテキスト
    extern t_context* currentContext;
    
    struct Color;
    struct Position;
    class HGLVector3;
    class HGLES
    {
    public:
        
        // コンテキストIDを返す
        static int initialize(float viewWidth, float viewHeight);
        
        
        static void pushMatrix();
        static void popMatrix();
        
        static void updateCameraMatrix();
        static void updateMatrix(); // シェーダ変数に現在の行列を渡す
        
        static GLuint aPositionSlot        ;
        static GLuint aNormalSlot          ;
        static GLuint aUVSlot              ;
        
        static GLuint uModelViewMatrixSlot ;
        static GLuint uMvpMatrixSlot ;
        static GLuint uNormalMatrixSlot    ;
        
        static GLuint uLightAmbientSlot;
        static GLuint uLightDiffuseSlot;
        static GLuint uLightSpecular;
        static GLuint uLightPos;
        static GLuint uUseLight;
        
        static GLuint uMaterialAmbient;
        static GLuint uMaterialDiffuse;
        static GLuint uMaterialSpecular;
        static GLuint uMaterialShininess;
        
        static GLuint uColor;
        static GLuint uBlendColor;
        
        //static GLKMatrix4 mvMatrix; // モデルビュー行列
        //static GLKMatrix4 cameraMatrix;
        //static GLKMatrix4 projectionMatrix; // 射影行列
        
        // texture
        static GLuint uUseTexture;
        static GLuint uTexMatrixSlot;
        static GLuint uTexSlot;
        static GLuint uTextureRepeatNum;
        
        // alpha of mesh
        static GLuint uAlpha;
        
        // alpha map
        static GLuint uUseAlphaMap;
        
        // light
        static Color ambient;
        static Color diffuse;
        static Color specular;
        static Position lightPos;
        
        static float viewWidth;
        static float viewHeight;
        
        static HGLVector3 cameraPosition;
        static HGLVector3 cameraRotate;
        
    private:
        static void compileShaders();
        static GLuint compileShader(NSString* shaderName, GLenum shaderType);
        //static std::stack<GLKMatrix4> matrixStack; // 行列スタック
        static void setDefault();
        
    };
    
}
#endif