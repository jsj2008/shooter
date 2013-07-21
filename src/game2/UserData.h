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
    typedef enum FighterListSortType
    {
        FighterListSortTypeFirst,
        FighterListSortTypeReady,
        FighterListSortTypeLife,
        FighterListSortTypeLast,
    } FighterListSortType;
    class UserData
    {
    public:
        static UserData* sharedUserData();
        void loadData();
        FighterList getFighterList();
        FighterList getReadyList();
        FighterList getShopList();
        int getMoney()
        {
            return money;
        }
        void addMoney(int add)
        {
            money += add;
        }
        int getRepairCost(hg::FighterInfo* fInfo);
        int getBuyCost(hg::FighterInfo* fInfo);
        void initBeforeBattle();
        void initAfterBattle();
        bool buy(hg::FighterInfo* fInfo);
        void repairAll();
        void setReady(FighterInfo* fighterInfo);
        void setUnReady(FighterInfo* fighterInfo);
        void sortFighterList(FighterListSortType sortType);
        void sortFighterList();
        int getRepairAllCost();
        FighterInfo* getPlayerInfo();
    private:
        FighterListSortType currentSortType;
        FighterList shopList;
        FighterList readyList;
        FighterList fighterList;
        int money = 900000;
        int enemyLevel = 0;
        int stage = 0;
        static UserData* instance;
    };
}

#endif /* defined(__Shooter__UserData__) */
