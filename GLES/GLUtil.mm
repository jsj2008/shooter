//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "GLUtil.h"

void split(std::vector<std::string>* v, const std::string* str, const std::string delims)
{
    using namespace std;
    size_t start = 0;
    size_t end = 0;
    while ((end = str->find_first_of(delims, start))!= string::npos)
    {
        string tok(str->substr(start, end - start));
        if (tok.size())
        {
            v->push_back(tok);
        }
        start = str->find_first_not_of(delims, ++end);
    }
    if (start != string::npos) {
        v->push_back(string(str->substr(start, str->size() - start)));
    }
}
