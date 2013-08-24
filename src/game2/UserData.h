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
        int win_point;
        int lose_point;
        int retrieve_point;
        std::string stage_name;
        std::string stage_name_short;
        std::string model_name;
        float small_size;
        float big_size;
    } StageInfo;
    
    typedef struct LevelupInfo
    {
        hg::FighterInfo beforeInfo;
        hg::FighterInfo* fighterInfo;
        long addExp;
        bool isLevelUp;
    } LevelupInfo;
    
    typedef std::vector<LevelupInfo> LevelupInfoList;
    typedef std::vector<StageInfo> StageInfoList;
    
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
        bool saveData();
        static bool DeleteAllData();
        FighterList getFighterList();
        FighterList getReadyList();
        FighterList getShopList();
        long getMoney()
        {
            return money;
        }
        void addMoney(long add)
        {
            money += add;
            if (money < 0) money = 0;
        }
        void returnToBase();
        int getStageNum();
        int getRepairCost(hg::FighterInfo* fInfo);
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
        StageInfo getStageInfo(int stageId);
        StageInfo getStageInfo();
        void addPoint(int add);
        FighterInfo* getPlayerFighterInfo();
        int getRepairAllCost();
        int getCost(FighterInfo* info);
        int getExp(FighterInfo* info);
        int getDamageExp(FighterInfo* info, int damage);
        void addExp(FighterInfo* info, int exp);
        void checkLevelup();
        double getDamagePerSecond(FighterInfo* info);
        FighterInfo* getPlayerInfo();
        static void setDefaultInfo(FighterInfo* pInfo, int type);
        void deployAllFighter();
        void undeployAllFighter();
        std::string popLevelupMessage();
        bool hasLevelUpInfo();
        LevelupInfo popLevelupInfo();
        void setBattleResult(BattleResult br);
        //std::string fighterDataToCSV();
        int getKillReward(hg::FighterInfo* fInfo);
        void upCamera();
        void downCamera();
        float getCameraPosition();
        void setStageId(int next_stage_id);
    private:
        LevelupInfoList levelUpList;
        int complete_point = 0;
        int stage_id = 0;
        StageInfo currentStageInfo;
        FighterListSortType currentSortType;
        FighterList shopList;
        FighterList readyList;
        FighterList fighterList;
        long money = 900000;
        float cameraPositionY = -18;
        int enemyLevel = 0;
        static UserData* instance;
        friend LevelupInfo levelup(hg::FighterInfo* fighterInfo);
    };
}

#endif /* defined(__Shooter__UserData__) */
