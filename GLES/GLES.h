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

struct Color;
struct Position;
class GLES
{
public:
    
    static void initialize(float viewWidth, float viewHeight);
    
    static void pushMatrix();
    static void popMatrix();
    static void updateMatrix(); // シェーダ変数に現在の行列を渡す
    
    static GLuint aPositionSlot        ;
    static GLuint aNormalSlot          ;
    
    static GLuint uProjectionMatrixSlot;
    static GLuint uModelViewMatrixSlot ;
    static GLuint uNormalMatrixSlot    ;
    
    static GLuint uLightAmbientSlot;
    static GLuint uLightDiffuseSlot;
    static GLuint uLightSpecular;
    static GLuint uLightPos;
//    static GLuint uUseLigtht;
    
    static GLuint uMaterialAmbient;
    static GLuint uMaterialDiffuse;
    static GLuint uMaterialSpecular;
    static GLuint uMaterialShininess;
    
    static GLKMatrix4 mvMatrix; // モデルビュー行列
    static GLKMatrix4 projectionMatrix; // 射影行列
    
    static Color ambient;
    static Color diffuse;
    static Color specular;
    static Position lightPos;
    
    static float viewWidth;
    static float viewHeight;
    
private:
    static void compileShaders();
    static GLuint compileShader(NSString* shaderName, GLenum shaderType);
    static std::stack<GLKMatrix4> matrixStack; // 行列スタック
    static void setDefaultLight();
    
};
