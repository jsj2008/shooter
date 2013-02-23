//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//
#ifndef HGLVectro3
#define HGLVectro3

class HGLVector3
{
public:
    HGLVector3();
    HGLVector3(float x, float y, float z);
    HGLVector3(const HGLVector3* origin);
    void set(const HGLVector3* origin);
    void set(float x, float y, float z);
    float dot(const HGLVector3* v); // 内積
    float dot(float x, float y, float z); // 内積
    HGLVector3* cross(const HGLVector3* v, HGLVector3* result); // 外積
    void cross(float x, float y, float z); // 外積
    void add(const HGLVector3* v0, const HGLVector3* v1); // 和
    void sub(const HGLVector3* v0, const HGLVector3* v1); // 差
    float length(); // ベクトルの長さ
    void normalize(); // 長さの正規化
    bool equals(const HGLVector3* v); // 比較
    float x, y, z;
};

#endif
