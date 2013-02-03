//G
         //  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "ObjLoader.h"
#import "VertexBuffer.h"
#import "IndexBuffer.h"
#import "GLUtil.h"
#import "GLTypes.h"
#import "Mesh.h"
#import "Object3D.h"

#import <string>
#import <vector>
#import <algorithm>

std::vector<Position> ObjLoader::positions;
std::vector<Normal> ObjLoader::normals;
std::vector<UV> ObjLoader::uvs;

std::vector<Vertex> ObjLoader::vertices; // position+uv+normal
std::vector<Index> ObjLoader::indices;


Object3D* ObjLoader::load(NSString* name)
{
    // load file
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"obj"];
    NSData *modelData = [NSData dataWithContentsOfFile:path];
    NSString *modelDataStr = [[[NSString alloc] initWithData:modelData encoding:NSUTF8StringEncoding] autorelease];
    
    using namespace std;
    bool mesh_flg = false;
    string* s_dat = new string([modelDataStr UTF8String]);
    vector<string> v_dat;
    split(&v_dat, s_dat, "\n\r");
    delete s_dat;
    vector<string>::iterator itr = v_dat.begin();
    
    Object3D* obj3d = new Object3D();
    
    while (itr != v_dat.end())
    {
        string* l = &(*itr);
        ++itr;
        vector<string> words;
        split(&words, l, " ");
        if (!words.size()) {
            continue;
        }
        string* t = &(words[0]);
        string a = *t;
        if (*t == "#")
        {
            continue;
        }
        else if (*t == "mtlib")
        {
            //TODO:後で
            //loadMtl(materials, (*word)[1]);
        }
        else if (*t == "usemtl")
        {
            // TODO:後で
        }
        // position
        else if (*t == "v")
        {
            positions.push_back({
                s2f(&(words)[1]),
                s2f(&(words)[2]),
                s2f(&(words)[3])
            });
        }
        // uv
        else if (*t == "vt")
        {
            uvs.push_back({
                s2f(&(words)[1]),
                1.0f - s2f(&(words)[2])
            });
        }
        // normal
        else if (*t == "vn")
        {
            normals.push_back({
                s2f(&(words)[1]),
                s2f(&(words)[2]),
                s2f(&(words)[3])
            });
        }
        // index
        else if (*t == "f")
        {
            mesh_flg = true;
            vector<string>::iterator wItr = words.begin();
            while (++wItr != words.end())
            {
                addIndex(&(*wItr));
            }
        }
    }
    
    if (mesh_flg)
    {
        addMeshTo(obj3d);
        
    }
    
    return obj3d;
}

void ObjLoader::addMeshTo(Object3D* obj3d)
{
    VertexBuffer* v = new VertexBuffer(&vertices[0], vertices.size());
    IndexBuffer* i = new IndexBuffer(&indices[0], indices.size());
    Mesh *m = new Mesh(v, i);
    obj3d->addMesh(m);
    
    //vertices.clear();
    indices.clear();
    
    //positions.clear();
    //uvs.clear();
    //normals.clear();
}
void ObjLoader::addIndex(std::string* index_str)
{
    
    using namespace std;
    vector<string> m;
    split(&m, index_str, "/");
    
    Position p = positions[s2i(&(m[0]))-1];
    UV uv;
    if (m.size() >= 2)
    {
        uv = uvs[s2i(&((m)[1]))-1];
    }
    Normal n;
    if (m.size() >= 3)
    {
        n = normals[s2i(&((m)[2]))-1];
    }
    
    //Vertex v(p, uv, n);
    Vertex v(p);
    
    // search vertex index
    std::vector<Vertex>::iterator vItr;
    vItr = vertices.begin();
    Index index = 0;
    while (vItr != vertices.end())
    {
        if (v == *vItr) {
            break;
        }
        ++index; ++vItr;
    }
    if (vItr == vertices.end())
    {
        // this vertex does not exist yet.
        vertices.push_back(v);
        index = vertices.size() - 1;
    }
    indices.push_back(index);
}

void ObjLoader::loadMtl(NSString* name)
{
    
}








