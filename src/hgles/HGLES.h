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
    class HGLIndexBuffer;
    class HGLVertexBuffer;
    
    typedef struct t_context
    {
        t_context():
        currentTextureId(-1)
        {}
        ////////////////////
        // テクスチャ描画用プリミティブ
        HGLIndexBuffer* squareIndexBuffer;
        HGLVertexBuffer* squareVertexBuffer;
        ////////////////////
        // テクスチャIDリスト
        std::map<std::string, HGLTexture*> textureIds;
        GLuint currentTextureId;
        
        ////////////////////
        // モデルビュー行列
        std::stack<GLKMatrix4> matrixStack;
        GLKMatrix4 mvMatrix;
        GLKMatrix4 cameraMatrix;
        GLKMatrix4 projectionMatrix;
        
        ////////////////////
        // カメラ設定
        // 反映するにはupdateCameraMatrixを呼び出す
        HGLVector3 cameraPosition;
        HGLVector3 cameraRotate;
        
        ////////////////////
        // シェーダ変数ポインタ
        GLuint aPositionSlot        ;
        GLuint aNormalSlot          ;
        GLuint aUVSlot              ;
        // モデルビュー行列
        GLuint uModelViewMatrixSlot ;
        GLuint uMvpMatrixSlot       ;
        GLuint uNormalMatrixSlot    ;
        // 光源
        GLuint uLightAmbientSlot;
        GLuint uLightDiffuseSlot;
        GLuint uLightSpecular;
        GLuint uLightPos;
        GLuint uUseLight;
        // マテリアル
        GLuint uMaterialAmbient;
        GLuint uMaterialDiffuse;
        GLuint uMaterialSpecular;
        GLuint uMaterialShininess;
        // テクスチャ
        GLuint uTexMatrixSlot;
        GLuint uTexSlot;
        GLuint uUseTexture;
        GLuint uTextureRepeatNum;
        // カラー
        GLuint uColor;
        GLuint uBlendColor;
        GLuint uUseAlphaMap;
        GLuint uAlpha;
        // program
        GLuint vertexShader;
        GLuint fragmentShader;
        GLuint programHandle;
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
        
        static float viewWidth;
        static float viewHeight;
        
    private:
        static void compileShaders(NSString* vertexShader, NSString* fragmentShader);
        static GLuint compileShader(NSString* shaderName, GLenum shaderType);
        //static std::stack<GLKMatrix4> matrixStack; // 行列スタック
        static void setDefault();
        
    };
    
}
#endif