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
#include "HGameCommon.h"

namespace userdata {
    
    typedef enum FighterRecordType
    {
        FighterRecordTypeFighter,
        FighterRecordTypeShop,
    } FighterRecordType;
    
    hg::FighterList readFighter(int fighterRecordType);
    bool insertFighterInfo(int inc_id, int fighterRecordType, hg::FighterInfo* info);
    bool deleteAllFighterData();
    bool updateOrInsertTextData(const std::string& key, const std::string& data);
    bool deleteAllTextData();
    std::string readTextData(const std::string& key);
    void initDatabase();
    void deleteDatabase();
    bool deleteAllData();
    bool open();
    bool close();
    bool begin();
    bool commit();
    bool rollback();
    bool deleteAllIntegerData();
    long readIntegerData(const std::string& key);
    bool updateOrInsertIntegerData(const std::string& k, const long& d);
}

#endif /* defined(__Shooter__UserDataManager__) */
