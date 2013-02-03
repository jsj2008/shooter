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
#import "Material.h"

#import <string>
#import <vector>
#import <algorithm>

std::vector<Position> ObjLoader::positions;
std::vector<Normal> ObjLoader::normals;
std::vector<UV> ObjLoader::uvs;

std::vector<Vertex> ObjLoader::vertices; // position+uv+normal
std::vector<Index> ObjLoader::indices;
std::map<std::string, Material*> ObjLoader::materials;

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
    vector<string>::iterator itr = v_dat.begin();
    
    Object3D* obj3d = new Object3D();
    
    string::size_type current = 0;
    string::size_type eol = 0;
    string l;
    long len = s_dat->length();
    
    while (current != string::npos)
    {
        eol = s_dat->find_first_of("\r\n", current);
        if (eol == string::npos)
        {
            eol = len - 1;
        }
        string l;
        l = string(s_dat->substr(current, eol - current));
        current = s_dat->find_first_not_of("\r\n", eol + 1);
        //string* l = &(*itr);
        ++itr;
        vector<string> words;
        //split(&words, l, " ");
        split(&words, &l, " ");
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
    addMeshTo(obj3d);
    delete s_dat;
    return obj3d;
}

void ObjLoader::addMeshTo(Object3D* obj3d)
{
    VertexBuffer* v = new VertexBuffer(&vertices[0], vertices.size());
    IndexBuffer* i = new IndexBuffer(&indices[0], indices.size());
#warning TODO
    loadMtl(@"block"); // fixme
    Material* m = materials["block"];
    Mesh* mesh = new Mesh(v, i, m);
    obj3d->addMesh(mesh);
    
    positions.clear();
    normals.clear();
    uvs.clear();
    
    vertices.clear();
    indices.clear();
}

void ObjLoader::addIndex(std::string* index_str)
{
    
    using namespace std;
    vector<string> m;
    split(&m, index_str, "/");
    
    int i1, i2, i3;
    i1 = s2i(&(m[0]))-1;
    i2 = i3 = i1;
    if (m.size() >= 2)
    {
        i2 = s2i(&(m[1]))-1;
        i3 = i1;
    }
    if (m.size() >= 3)
    {
        i2 = i1;
        i3 = s2i(&(m[2]))-1;
    }
    Position p = positions[i1];
    UV uv = {0,0};
    if (uvs.size() > i2)
    {
        uv = uvs[i2];
    }
    Normal n = {0, 0, 0};
    if (normals.size() > i3)
    {
        n = normals[i3];
    }
    
    Vertex v(p, uv, n);
    
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
#warning TODO
    Material* m = new Material();
    m->ambient  = {0.9, 0.7, 0.7, 1.0};
    m->diffuse  = {0.7, 0.7, 0.7, 1.0};
    m->specular = {0.7, 0.7, 0.7, 1.0};
    m->shininess = 80;
    materials["block"] = m;
}








