//
//  UserData.cpp
//  Shooter
//
//  Created by 濱田 洋太 on 13/06/09.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#include "UserData.h"
#import "HGame.h"
#import "HGUser.h"
#import <sstream>

namespace hg {
    
    UserData* UserData::instance = NULL;
    UserData* UserData::sharedUserData()
    {
        if (instance == NULL)
        {
            instance = new UserData();
        }
        return instance;
    }
    void UserData::loadData()
    {
        hg::FighterInfo* pPlayerInfo = new hg::FighterInfo();
        pPlayerInfo->fighterType = 0;
        pPlayerInfo->life = 3000;
        pPlayerInfo->lifeMax = 3000;
        pPlayerInfo->shield = 3000;
        pPlayerInfo->shieldMax = 3000;
        pPlayerInfo->speed = 0.5;
        pPlayerInfo->isPlayer = true;
        pPlayerInfo->name = "Fighter";
        pPlayerInfo->cost = 5000;
        fighterList.push_back(pPlayerInfo);
        
        for (int j = 0; j < 15; j++)
        {
            hg::FighterInfo* i = new hg::FighterInfo();
            i->fighterType = 1;
            i->life = 2000;
            i->lifeMax = 2000;
            i->shield = 1000;
            i->shieldMax = 1000;
            i->speed = 0.3;
            i->cost = 1000;
            std::stringstream ss;
            ss << "Fighter-" << (j + 1) << "号";
            i->name = ss.str();
            fighterList.push_back(i);
        }
        {
            hg::FighterInfo* i = new hg::FighterInfo();
            i->fighterType = 2;
            i->life = 00;
            i->lifeMax = 4000;
            i->shield = 11000;
            i->shieldMax = 11000;
            i->speed = 0.1;
            i->cost = 10000;
            fighterList.push_back(i);
            std::stringstream ss;
            ss << "battle star galactica";
            i->name = ss.str();
        }
        
    }
    int UserData::getRepairCost(hg::FighterInfo* fInfo)
    {
        int cost = ((fInfo->lifeMax - fInfo->life)/fInfo->lifeMax * 0.5 * fInfo->cost);
        if (fInfo->life == 0)
        {
            cost = fInfo->cost;
        }
        return cost;
    }
    FighterList UserData::getFighterList()
    {
        return fighterList;
    }
    
}

