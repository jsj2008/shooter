//
//  UserData.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/09.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__UserData__
#define __Shooter__UserData__

#include <iostream>

#import "HGameCommon.h"
#import <vector>
#import <string>

namespace hg {
    
    typedef std::vector<hg::FighterInfo*> FighterList;
    class UserData
    {
    public:
        static UserData* sharedUserData();
        void loadData();
        FighterList getFighterList();
        int getMoney()
        {
            return money;
        }
        void addMoney(int add)
        {
            money += add;
        }
        int getRepairCost(hg::FighterInfo* fInfo);
    private:
        FighterList fighterList;
        int money = 1000;
        int enemyLevel = 0;
        int stage = 0;
        static UserData* instance;
    };
}

#endif /* defined(__Shooter__UserData__) */
