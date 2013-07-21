//G
         //  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "HGLObjLoader.h"
#import "HGLVertexBuffer.h"
#import "HGLIndexBuffer.h"
#import "HGLUtil.h"
#import "HGLTypes.h"
#import "HGLMesh.h"
#import "HGLObject3D.h"
#import "HGLMaterial.h"
#import "HGLTexture.h"
#import "HGLCommon.h"

#import <string>
#import <vector>
#import <algorithm>

namespace hgles {
    
    std::vector<Position> HGLObjLoader::positions;
    std::vector<Normal> HGLObjLoader::normals;
    std::vector<UV> HGLObjLoader::uvs;
    
    std::vector<Vertex> HGLObjLoader::vertices; // position+uv+normal
    std::vector<Index> HGLObjLoader::indices;
    std::map<std::string, HGLMaterial*> HGLObjLoader::materials;
    
    HGLObject3D* HGLObjLoader::load(NSString* name)
    {
        using namespace std;
        
        // ファイルを文字列に読み込む
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"obj"];
        NSData *modelData = [NSData dataWithContentsOfFile:path];
        NSString *modelDataStr = [[[NSString alloc] initWithData:modelData encoding:NSUTF8StringEncoding] autorelease];
        string* s_dat = new string([modelDataStr UTF8String]);
        
        // １行ずつ処理
        HGLObject3D* obj3d = new HGLObject3D();
        bool mesh_flg = false;
        string::size_type current = 0;
        string::size_type eol = 0;
        string l;
        long len = s_dat->length();
        
        std::string material_name = ""; // マテリアル名
        
        while (current != string::npos)
        {
            eol = s_dat->find_first_of("\r\n", current);
            if (eol == string::npos)
            {
                eol = len - 1;
            }
            string l;
            l = string(s_dat->substr(current, eol - current));
            
            // 現在の行を単語ごとに分解する。
            current = s_dat->find_first_not_of("\r\n", eol + 1);
            vector<string> words;
            split(&words, &l, " ");
            if (!words.size()) {
                continue;
            }
            
            // １つめの単語でデータの種類を判定する
            // コメント
            if (words[0] == "#")
            {
                continue;
            }
            // マテリアルファイル名
            else if (words[0] == "mtllib")
            {
                loadMtl(&(words[1]));
            }
            // マテリアル名
            else if (words[0] == "usemtl")
            {
                material_name = words[1];
            }
            // position
            else if (words[0] == "v")
            {
                positions.push_back({
                    s2f(&(words)[1]),
                    s2f(&(words)[2]),
                    s2f(&(words)[3])
                });
            }
            // uv
            else if (words[0] == "vt")
            {
                uvs.push_back({
                    s2f(&(words)[1]),
                    1.0f - s2f(&(words)[2])
                });
            }
            // normal
            else if (words[0] == "vn")
            {
                normals.push_back({
                    s2f(&(words)[1]),
                    s2f(&(words)[2]),
                    s2f(&(words)[3])
                });
            }
            // index
            else if (words[0] == "f")
            {
                mesh_flg = true;
                vector<string>::iterator wItr = words.begin();
                while (++wItr != words.end())
                {
                    addIndex(&(*wItr));
                }
            }
        }
        addMeshTo(obj3d, material_name);
        
        // メモリ解放
        delete s_dat;
        for (std::map<std::string, HGLMaterial*>::iterator itr = materials.begin(); itr != materials.end(); itr++)
        {
            delete itr->second;
        }
        materials.clear();
        
        return obj3d;
    }
    
    // メッシュを作る
    void HGLObjLoader::addMeshTo(HGLObject3D* obj3d, std::string material_name)
    {
        HGLVertexBuffer* v = new HGLVertexBuffer(&vertices[0], vertices.size());
        HGLIndexBuffer* i = new HGLIndexBuffer(&indices[0], indices.size());
        
        HGLMaterial* m = NULL;
        HGLTexture* t = NULL;
        if (material_name.length())
        {
            HGLMaterial* temp = materials[material_name];
            if (temp)
            {
                m = new HGLMaterial();
                m->name      = temp->name;
                m->ambient   = temp->ambient;
                m->diffuse   = temp->diffuse;
                m->specular  = temp->specular;
                m->shininess = temp->shininess;
                m->texture_name = temp->texture_name;
                if (m->texture_name.length())
                {
                    t = HGLTexture::createTextureWithAsset(m->texture_name);
                }
            }
        }
        HGLMesh* mesh = new HGLMesh(v, i, m, t);
        obj3d->addMesh(mesh);
        
        positions.clear();
        normals.clear();
        uvs.clear();
        
        vertices.clear();
        indices.clear();
    }
    
    // インデックスが示す頂点を作成する
    void HGLObjLoader::addIndex(std::string* index_str)
    {
        
        using namespace std;
        
        // インデックスが指す座標、UV座標、法線を探して頂点を作る
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
        
        // このインデックスが指す頂点が既にリストにある場合は再利用する
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
        // 追加した(または既にリストに入っていた)頂点を指すインデックスを追加する
        indices.push_back(index);
    }
    
    void HGLObjLoader::loadMtl(std::string* name)
    {
        
        using namespace std;
        
        materials.clear();
        HGLMaterial* m = NULL; // メッシュに渡すときにcopyする
        
        // ファイルを文字列に読み込む
        NSString* s = [NSString stringWithCString:name->c_str() encoding:NSUTF8StringEncoding];
        NSString *path = [[NSBundle mainBundle] pathForResource:s ofType:@""];
        NSData *modelData = [NSData dataWithContentsOfFile:path];
        NSString *modelDataStr = [[[NSString alloc] initWithData:modelData encoding:NSUTF8StringEncoding] autorelease];
        string* s_dat = new string([modelDataStr UTF8String]);
        
        // １行ずつ処理
        string::size_type current = 0;
        string::size_type eol = 0;
        string l;
        long len = s_dat->length();
        
        try {
            while (current != string::npos)
            {
                eol = s_dat->find_first_of("\r\n", current);
                if (eol == string::npos)
                {
                    eol = len - 1;
                }
                string l;
                l = string(s_dat->substr(current, eol - current));
                
                // 現在の行を単語ごとに分解する。
                current = s_dat->find_first_not_of("\r\n", eol + 1);
                vector<string> words;
                split(&words, &l, " ");
                if (!words.size()) {
                    continue;
                }
                
                // １つめの単語でデータの種類を判定する
                // マテリアル名
                if (words[0] == "newmtl")
                {
                    m = new HGLMaterial();
                    m->name = words[1];
                    materials[words[1]] = m;
                }
                // 環境光
                else if (words[0] == "Ka")
                {
                    if (m == NULL) throw 1;
                    m->ambient = {s2f(&words[1]), s2f(&words[2]), s2f(&words[3]), 1.0};
                }
                // 拡散光
                else if (words[0] == "Kd")
                {
                    if (m == NULL) throw 1;
                    m->diffuse = {s2f(&words[1]), s2f(&words[2]), s2f(&words[3]), 1.0};
                }
                // 鏡面光
                else if (words[0] == "Ks")
                {
                    if (m == NULL) throw 1;
                    m->specular = {s2f(&words[1]), s2f(&words[2]), s2f(&words[3]), 1.0};
                }
                // 鏡面反射角度
                else if (words[0] == "Ns")
                {
                    if (m == NULL) throw 1;
                    m->shininess = s2f(&words[1]);
                }
                // テクスチャ
                else if (words[0] == "map_Kd")
                {
                    if (m == NULL) throw 1;
                    m->texture_name = words[1];
                }
            }
        } catch (...) {
            LOG(@"%@", @"failed to load material");
        }
        //delete s_dat;
    }
    
}







