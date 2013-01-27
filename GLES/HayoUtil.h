//
//  IndexBuffer.h
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//
#import <string>
#import <vector>

typedef std::vector<std::string*> t_string_list;

t_string_list* split_string(const std::string* str, const std::string delims);
