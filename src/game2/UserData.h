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

#define DefCamera -25

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
        int clear_count;
        int maxEnemyWeaponLv = 0;
    } StageInfo;
    
    typedef struct LevelupInfo
    {
        hg::FighterInfo beforeInfo;
        hg::FighterInfo* fighterInfo;
        long addExp;
        bool isLevelUp;
    } LevelupInfo;
    typedef std::vector<LevelupInfo> LevelupInfoList;
    
    typedef struct RewardInfo
    {
        std::string message;
    } RewardInfo;
    typedef std::vector<RewardInfo> RewardInfoList;
    
    typedef std::vector<StageInfo> StageInfoList;
    
    typedef enum FighterListSortType
    {
        FighterListSortTypeFirst,
        FighterListSortTypeReady,
        FighterListSortTypeLife,
        FighterListSortTypeName,
        FighterListSortTypeLast,
    } FighterListSortType;
    
    LevelupInfo levelup(hg::FighterInfo* fighterInfo);
    
    class UserData
    {
    public:
        static UserData* sharedUserData();
        UserData();
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
            money = MIN(99999999, money);
        }
        int getMaxAllyNum();
        void returnToBase();
        long getSumValue();
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
        bool hasRewardInfo();
        std::string popRewardMessage();
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
        void setDefaultInfo(FighterInfo* pInfo, int type);
        void setDefaultInfo(FighterInfo* pInfo, int type, int fix_enemy_lv);
        bool isLastStageNow();
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
        bool isCleared();
        BattleResult getLatestBattleResult();
        void addBattleScore(int val);
        long getTotalScore();
        long getTotalDead();
        long getTotalKill();
        long getWinCount();
        long getLoseCount();
        long getRetreatCount();
        std::string getGrade();
        void calcGrade();
        void addShop(int type);
    private:
        long score = 0;
        long totalKill = 0;
        long totalDead = 0;
        long winCount = 0;
        long loseCount = 0;
        long retreatCount = 0;
        bool is_cleared = false;
        LevelupInfoList levelUpList;
        int complete_point = 0;
        int stage_id = 0;
        StageInfo currentStageInfo;
        FighterListSortType currentSortType;
        FighterList shopList;
        FighterList readyList;
        FighterList fighterList;
        long money = 0;
        float cameraPositionY = DefCamera;
        std::string grade = "";
        int enemyLevel = 0;
        int maxAllyNum = 0;
        int maxPowerUpNum = 0;
        std::vector<int> clear_count_list;
        static UserData* instance;
        friend LevelupInfo levelup(hg::FighterInfo* fighterInfo);
        RewardInfoList rewardInfoList;
        BattleResult lastBattleResult;
    };
}

#endif /* defined(__Shooter__UserData__) */
