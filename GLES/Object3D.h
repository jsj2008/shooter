//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mesh.h"
#import "Vector3.h"
#import <vector>

class Object3D
{
public:
    Object3D();
    void addMesh(Mesh* m);
    void draw();
    ~Object3D();
    
    Vector3 position; // 位置
    Vector3 rotate  ; // 回転
    Vector3 scale   ; // 拡大縮小
    
private:
    std::vector<Mesh*> meshlist;
    std::vector<Object3D*> children;
    
};
