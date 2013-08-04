//
//  UserDataManager.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/08/04.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__UserDataManager__
#define __Shooter__UserDataManager__

#include <iostream>

namespace userdata {
    
    bool writeTextData(const std::string& key, const std::string& data);
    bool deleteAllTextData();
    std::string readTextData(const std::string& key);
    bool saveShooterData();
}

#endif /* defined(__Shooter__UserDataManager__) */
