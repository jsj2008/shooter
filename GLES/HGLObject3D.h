//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGLMesh.h"
#import "HGLVector3.h"
#import <vector>

class HGLObject3D
{
public:
    HGLObject3D();
    void addMesh(HGLMesh* m);
    void draw();
    ~HGLObject3D();
    
    HGLVector3 position; // 位置
    HGLVector3 rotate  ; // 回転
    HGLVector3 scale   ; // 拡大縮小
    
private:
    std::vector<HGLMesh*> meshlist;
    std::vector<HGLObject3D*> children;
    
};
