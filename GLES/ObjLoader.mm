//
         //  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "ObjLoader.h"
#import "VertexBuffer.h"
#import "IndexBuffer.h"
#import "HayoUtil.h"
#import "GLTypes.h"

#import <string>
#import <vector>
#import <algorithm>

Object3D* ObjLoader::load(NSString* name)
{
    std::vector<Position> positions;
    std::vector<Normal> normals;
    std::vector<UV> uvs;
    
    std::vector<Vertex> vertices; // position+uv+normal
    std::vector<GLubyte> indices;
    
    // load file
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:name ofType:@"obj"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    using namespace std;
    const string* dataStr = new std::string([[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] UTF8String]);
    
    t_string_list* line_list = split_string(dataStr, "¥n");
    t_string_list::iterator line_itr = line_list->begin();
    
    bool mesh_flg = false;
    
    while (line_itr != line_list->end())
    {
        string* line = *line_itr;
        t_string_list* words = split_string(line, " ");
        string* line_type = (*words)[0];
        if (*line_type == "mtlib")
        {
            //TODO:後で
            //loadMtl(materials, (*word)[1]);
        }
        else if (*line_type == "usemtl")
        {
            // TODO:後で
        }
        // position
        else if (*line_type == "v")
        {
            positions.push_back({
                s2f((*words)[1]),
                s2f((*words)[2]),
                s2f((*words)[3])
            });
        }
        // uv
        else if (*line_type == "vt")
        {
            uvs.push_back({
                s2f((*words)[1]),
                1.0f - s2f((*words)[2])
            });
        }
        // normal
        else if (*line_type == "vn")
        {
            normals.push_back({
                s2f((*words)[1]),
                s2f((*words)[2]),
                s2f((*words)[3])
            });
        }
        // index
        else if (*line_type == "f")
        {
            mesh_flg = true;
            t_string_list::iterator wordItr = words->begin();
            wordItr++;
            while (wordItr != words->end())
            {
                Position tmp_pos = positions[s2i((*words)[1])];
                UV tmp_uv = uvs[s2i((*words)[2])];
                Normal tmp_normal = normals[s2i((*words)[3])];
                
                t_string_list *m = split_string(*wordItr, "/");
                Vertex v(tmp_pos, tmp_uv, tmp_normal);
                
                std::vector<Vertex>::iterator vItr = find(vertices.begin(), vertices.end(), v);
                short index = 0;
                if (vItr != vertices.end())
                {
                    vertices.push_back(v);
                    index++;
                }
                indices.push_back(index);
                delete m;
                wordItr++;
            }
        }
        else if (mesh_flg)
        {
            mesh_flg = false;
            //Mesh mesh = new Mesh();
            
        }
        delete words;
    }
    delete line_list;
    
    if (mesh_flg)
    {
        
    }
    
    return nil;
}

void ObjLoader::loadMtl(NSString* name)
{
    
}








