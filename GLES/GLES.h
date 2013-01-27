//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import <stack>

class GLES
{
public:
    static void pushMatrix();
    static void popMatrix();
    
    // 頂点シェーダ変数を現在の行列で更新する
    static void updateMatrix();
    
    // 初期化
    static void initialize(float viewAspect);
    
    static GLuint aPositionSlot        ;
    static GLuint aColorSlot           ;
    static GLuint uProjectionMatrixSlot;
    static GLuint uModelViewMatrixSlot ;
    
    static GLKMatrix4 mvMatrix; // モデルビュー行列
    static GLKMatrix4 projectionMatrix; // 射影行列
    static float aspect; // アスペクト比
    
private:
    static void compileShaders();
    static GLuint compileShader(NSString* shaderName, GLenum shaderType);
    static std::stack<GLKMatrix4> matrixStack; // 行列スタック
};
