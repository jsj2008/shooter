//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

class Vector3
{
public:
    Vector3();
    Vector3(float x, float y, float z);
    Vector3(const Vector3* origin);
    void set(const Vector3* origin);
    void set(float x, float y, float z);
    float dot(const Vector3* v); // 内積
    float dot(float x, float y, float z); // 内積
    Vector3* cross(const Vector3* v, Vector3* result); // 外積
    void cross(float x, float y, float z); // 外積
    void add(const Vector3* v0, const Vector3* v1); // 和
    void sub(const Vector3* v0, const Vector3* v1); // 差
    float length(); // ベクトルの長さ
    void normalize(); // 長さの正規化
    bool equals(const Vector3* v); // 比較
    float x, y, z;
};
