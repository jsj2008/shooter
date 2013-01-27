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

#import <string>
#import <vector>

struct vector3f
{
    float x = 0;
    float y = 0;
    float z = 0;
};

struct vector2f
{
    float x = 0;
    float y = 0;
};

Object3D* ObjLoader::load(NSString* name)
{
    std::vector<vector3f*> positions;
    std::vector<vector3f*> normals;
    std::vector<vector2f*> uvs;
    
    std::vector<Vertex*> vertices;
    std::vector<GLubyte> indices;
    
    // load file
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:name ofType:@"obj"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    const std::string* dataStr = new std::string([[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease] UTF8String]);
    
    t_string_list* line_list = split_string(dataStr, "¥n");
    t_string_list::iterator line_itr = line_list->begin();
    while (line_itr != line_list->end())
    {
        
    }
    
    return nil;
    
}





