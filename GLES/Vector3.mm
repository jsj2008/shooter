//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "Vector3.h"

Vector3::Vector3()
{
    x = y = z = 0;
}

Vector3::Vector3(float x, float y, float z)
{
    this->x = x;
    this->y = y;
    this->z = z;
}

Vector3::Vector3(const Vector3* origin)
{
    this->x = origin->x;
    this->y = origin->y;
    this->z = origin->z;
}

void Vector3::set(const Vector3* origin)
{
    this->x = origin->x;
    this->y = origin->y;
    this->z = origin->z;
}

void Vector3::set(float x, float y, float z)
{
    this->x = x;
    this->y = y;
    this->z = z;
}

float Vector3::dot(const Vector3* v)
{
    return (v->x*x) + (v->y*y) + (v->z*z);
}

float Vector3::dot(float x, float y, float z)
{
    return (this->x*x) + (this->y*y) + (this->z*z);
}

Vector3* Vector3::cross(const Vector3* v, Vector3* result)
{
    result->set(
        (this->y * v->z) - (this->z * v->y),
        (this->z * v->x) - (this->x * v->z),
        (this->x * v->y) - (this->y * v->x));
    return result;
}

void Vector3::cross(float x, float y, float z)
{
    this->set(
        (this->y * z) - (this->z * y),
        (this->z * x) - (this->x * z),
        (this->x * y) - (this->y * x));
}

void Vector3::add(const Vector3* v0, const Vector3* v1)
{
    this->x = v0->x + v1->x;
    this->y = v0->y + v1->y;
    this->z = v0->z + v1->z;
}

void Vector3::sub(const Vector3* v0, const Vector3* v1)
{
    this->x = v0->x - v1->x;
    this->y = v0->y - v1->y;
    this->z = v0->z - v1->z;
}

float Vector3::length()
{
    return (float)sqrt((double)((x*x)+(y*y)+(z*z)));
}

void Vector3::normalize()
{
    float len = length();
    this->x /= len;
    this->y /= len;
    this->z /= len;
}

bool Vector3::equals(const Vector3* v)
{
    return (x == v->x && y == v->y && z == v->z);
}

