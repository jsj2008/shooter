//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "HGLVector3.h"

namespace hgles {
    
    HGLVector3::HGLVector3()
    {
        x = y = z = 0;
    }
    
    HGLVector3::HGLVector3(float x, float y, float z)
    {
        this->x = x;
        this->y = y;
        this->z = z;
    }
    
    HGLVector3::HGLVector3(const HGLVector3* origin)
    {
        this->x = origin->x;
        this->y = origin->y;
        this->z = origin->z;
    }
    
    void HGLVector3::set(const HGLVector3* origin)
    {
        this->x = origin->x;
        this->y = origin->y;
        this->z = origin->z;
    }
    
    void HGLVector3::set(float x, float y, float z)
    {
        this->x = x;
        this->y = y;
        this->z = z;
    }
    
    float HGLVector3::dot(const HGLVector3* v)
    {
        return (v->x*x) + (v->y*y) + (v->z*z);
    }
    
    float HGLVector3::dot(float x, float y, float z)
    {
        return (this->x*x) + (this->y*y) + (this->z*z);
    }
    
    HGLVector3* HGLVector3::cross(const HGLVector3* v, HGLVector3* result)
    {
        result->set(
                    (this->y * v->z) - (this->z * v->y),
                    (this->z * v->x) - (this->x * v->z),
                    (this->x * v->y) - (this->y * v->x));
        return result;
    }
    
    void HGLVector3::cross(float x, float y, float z)
    {
        this->set(
                  (this->y * z) - (this->z * y),
                  (this->z * x) - (this->x * z),
                  (this->x * y) - (this->y * x));
    }
    
    void HGLVector3::add(const HGLVector3* v0, const HGLVector3* v1)
    {
        this->x = v0->x + v1->x;
        this->y = v0->y + v1->y;
        this->z = v0->z + v1->z;
    }
    
    void HGLVector3::sub(const HGLVector3* v0, const HGLVector3* v1)
    {
        this->x = v0->x - v1->x;
        this->y = v0->y - v1->y;
        this->z = v0->z - v1->z;
    }
    
    float HGLVector3::length()
    {
        return (float)sqrt((double)((x*x)+(y*y)+(z*z)));
    }
    
    void HGLVector3::normalize()
    {
        float len = length();
        this->x /= len;
        this->y /= len;
        this->z /= len;
    }
    
    bool HGLVector3::equals(const HGLVector3* v)
    {
        return (x == v->x && y == v->y && z == v->z);
    }
    
}
