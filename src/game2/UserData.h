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
    
    const int MIN_STAGE_ID = 0;
    const int MAX_STAGE_ID = 5;
    
    typedef struct StageInfo
    {
        int stage_id;
        int enemy_level;
        int win_point;
        int lose_point;
        std::string stage_name;
    } StageInfo;
    
    typedef struct LevelupInfo
    {
        hg::FighterInfo* fighterInfo;
        std::string text;
    } LevelupInfo;
    
    typedef std::vector<LevelupInfo> LevelupInfoList;
    typedef std::vector<StageInfo> StageInfoList;
    
    typedef std::vector<hg::FighterInfo*> FighterList;
    typedef enum FighterListSortType
    {
        FighterListSortTypeFirst,
        FighterListSortTypeReady,
        FighterListSortTypeLife,
        FighterListSortTypeLast,
    } FighterListSortType;
    
    LevelupInfo levelup(hg::FighterInfo* fighterInfo);
    
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
        StageInfoList getStageInfoList();
        int getBuyCost(hg::FighterInfo* fInfo);
        int getSellValue(hg::FighterInfo* fInfo);
        void initBeforeBattle();
        void initAfterBattle();
        bool buy(hg::FighterInfo* fInfo);
        bool sell(hg::FighterInfo* fInfo);
        void repairAll();
        void setReady(FighterInfo* fighterInfo);
        void setUnReady(FighterInfo* fighterInfo);
        void sortFighterList(FighterListSortType sortType);
        void sortFighterList();
        double getCurrentClearRatio();
        int getStageId();
        StageInfo getStageInfo(int stage_id);
        StageInfo getStageInfo();
        void setStageId(int next_stage_id);
        void addPoint(int add);
        FighterInfo* getPlayerFighterInfo();
        int getRepairAllCost();
        int getCost(FighterInfo* info);
        int getExp(FighterInfo* info);
        void addExp(FighterInfo* info, int exp);
        LevelupInfoList checkLevelup();
        double getDamagePerSecond(FighterInfo* info);
        FighterInfo* getPlayerInfo();
        static void setDefaultInfo(FighterInfo* pInfo, int type);
    private:
        int current_point = 0;
        int stage_id = 0;
        FighterListSortType currentSortType;
        FighterList shopList;
        FighterList readyList;
        FighterList fighterList;
        int money = 900000;
        int enemyLevel = 0;
        static UserData* instance;
        friend LevelupInfo levelup(hg::FighterInfo* fighterInfo);
    };
}

#endif /* defined(__Shooter__UserData__) */
