//
//  IndexBuffer.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "HayoUtil.h"

t_string_list* split_string(const std::string* str, const std::string delims)
{
    using namespace std;
    t_string_list* result = new t_string_list();
    
    int startidx = 0, endidx = 0;
    
    while (startidx != string::npos)
    {
        endidx = str->find_first_of(delims, startidx);
        startidx = str->find_first_not_of(delims, endidx);
        string* tok = new string(str->substr(startidx, endidx - startidx));
        result->push_back(tok);
        startidx = str->find_first_not_of(delims, endidx);
    }
    return result;
}
