//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <vector>
#import <map>
#import "GLTypes.h"

class Object3D;
class HGLMaterial;

class ObjLoader
{
public:
    static Object3D* load(NSString* name);
private:
    static void loadMtl(std::string* name);
    static void addIndex(std::string* index_str);
    static void addMeshTo(Object3D* obj, std::string material_name);
    static std::vector<Position> positions;
    static std::vector<Normal> normals;
    static std::vector<UV> uvs;
    
    static std::vector<Vertex> vertices; // position+uv+normal
    static std::vector<Index> indices;
    static std::map<std::string, HGLMaterial*> materials;
    
};

