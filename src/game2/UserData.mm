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
#import "UserDataManager.h"
#import <sstream>
#import <algorithm>

#import <Foundation/Foundation.h>
//#import "CHCSVParser.h"

#define STATUS_UP_PROB_BASE 1000

namespace hg {
    
    double getNextExp(hg::FighterInfo* fighterInfo)
    {
        return (int) ((fighterInfo->level + 1) * (fighterInfo->level + 1) * 40) + 500;
    }
    
    void levelupInner(hg::FighterInfo* fighterInfo)
    {
        // ステータス変更
        std::srand(fighterInfo->seed);
        // 攻撃力
        if (std::rand() % STATUS_UP_PROB_BASE <= 1000 + fighterInfo->powerPotential)
        {
            int up = ceil(std::rand()%fighterInfo->powerPotential);
            fighterInfo->power += up;
        }
        // life
        if (std::rand() % STATUS_UP_PROB_BASE <= 3000 + fighterInfo->defencePotential)
        {
            fighterInfo->lifeMax += std::rand()%(fighterInfo->defencePotential*fighterInfo->defencePotential/20);
        }
        // shield
        if (std::rand() % STATUS_UP_PROB_BASE <= 100 + (fighterInfo->defencePotential/10))
        {
            fighterInfo->shieldMax += std::rand()%fighterInfo->defencePotential;
        }
        // shieldHeal
        if (std::rand() % STATUS_UP_PROB_BASE <= 300 + (fighterInfo->defencePotential/30))
        {
            fighterInfo->shieldHeal += (std::rand()%fighterInfo->defencePotential/30);
        }
        fighterInfo->isStatusChanged = true;
    }
    
    LevelupInfo levelup(hg::FighterInfo* fighterInfo)
    {
        hg::FighterInfo before = *fighterInfo;
        if (fighterInfo->level > 10000)
        {
            return {
                before,
                fighterInfo,
                0,
                false,
            };
        }
        long addExp = fighterInfo->tmpExp;
        fighterInfo->exp += addExp;
        fighterInfo->tmpExp = 0;
        bool isLevelup = false;
        while (1)
        {
            if (fighterInfo->exp < fighterInfo->expNext)
            {
                break;
            }
            // levelup
            isLevelup = true;
            fighterInfo->level++;
            levelupInner(fighterInfo);
            
            // set next exp
            fighterInfo->exp -= fighterInfo->expNext;
            fighterInfo->expNext = getNextExp(fighterInfo);
        }
        return {
            before,
            fighterInfo,
            addExp,
            isLevelup,
        };
    }
    
    
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
        ////////////////////
        // fighter list
        
        hg::FighterInfo* pPlayerInfo = new hg::FighterInfo();
        UserData::setDefaultInfo(pPlayerInfo, FighterTypeRobo1);
        pPlayerInfo->life = 3000;
        pPlayerInfo->lifeMax = 3000;
        pPlayerInfo->shield = 3000;
        pPlayerInfo->shieldMax = 3000;
        pPlayerInfo->speed = 0.5;
        pPlayerInfo->isPlayer = true;
        pPlayerInfo->name = "Fighter";
        fighterList.push_back(pPlayerInfo);
        
        for (int j = 0; j < 15; j++)
        {
            hg::FighterInfo* i = new hg::FighterInfo();
            UserData::setDefaultInfo(i, FighterTypeRobo2);
            std::stringstream ss;
            ss << "Fighter-" << (j + 1) << "号";
            i->name = ss.str();
            fighterList.push_back(i);
        }
        {
            hg::FighterInfo* i = new hg::FighterInfo();
            UserData::setDefaultInfo(i, FighterTypeShip1);
            fighterList.push_back(i);
            std::stringstream ss;
            ss << "Vesarius";
            i->name = ss.str();
        }
        
        ////////////////////
        // shop list
        for (int j = 0; j < 5; j++)
        {
            hg::FighterInfo* i = new hg::FighterInfo();
            UserData::setDefaultInfo(i, FighterTypeRobo1);
            std::stringstream ss;
            ss << "Fighter-" << (j + 1) << "号";
            i->name = ss.str();
            shopList.push_back(i);
        }
        for (int j = 0; j < 5; j++)
        {
            hg::FighterInfo* i = new hg::FighterInfo();
            UserData::setDefaultInfo(i, FighterTypeRobo2);
            std::stringstream ss;
            ss << "Fighter-" << (j + 1) << "号";
            i->name = ss.str();
            shopList.push_back(i);
        }
        
        // test
        userdata::writeTextData("test", "brabrabra");
        std::string data = userdata::readTextData("test");
    }
    
    /*
    std::string UserData::fighterDataToCSV()
    {
        CHCSVWriter* w = [[[CHCSVWriter alloc] init] autorelease];
        for (FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it)
        {
            FighterInfo* info = *it;
            [w writeField:[NSString stringWithFormat:@"%s", info->name.c_str()]];
            [w finishLine];
        }
        std::string ret = [w ]
    }*/
    
    FighterInfo* UserData::getPlayerFighterInfo()
    {
        for (FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it)
        {
            if ((*it)->isPlayer)
            {
                return *it;
            }
        }
        return NULL;
    }
    
    double UserData::getCurrentClearRatio()
    {
        double ratio = (double)current_point/1000.0;
        if (ratio >= 1.0)
        {
            return 1;
        }
        else
        {
            return ratio;
        }
    }
    int UserData::getStageId()
    {
        return stage_id;
    }
    void UserData::setStageId(int next_stage_id)
    {
        stage_id = next_stage_id;
    }
    StageInfoList UserData::getStageInfoList()
    {
        StageInfoList list;
        list.clear();
        for (int i = MIN_STAGE_ID; i <= MAX_STAGE_ID; i++)
        {
            list.push_back(this->getStageInfo(i));
        }
        return list;
    }
    StageInfo UserData::getStageInfo()
    {
        return this->getStageInfo(stage_id);
    }
    StageInfo UserData::getStageInfo(int stage_id)
    {
        int enemy_level = 1;
        int win_point = 100;
        int lose_point = -100;
        std::string stage_name = "";
        switch (stage_id) {
            case 0:
            {
                enemy_level = 1;
                win_point = 100;
                lose_point = - 100;
                stage_name = "Earth";
                break;
            }
            default:
                break;
        }
        return {
            stage_id,
            enemy_level,
            win_point,
            lose_point,
            stage_name,
        };
    }
    void UserData::addPoint(int add)
    {
        current_point += add;
        if (current_point > 1000)
        {
            current_point = 1000;
        }
    }
    int UserData::getExp(FighterInfo* info)
    {
        int cost = getCost(info);
        double ret = (double)cost * 0.025;
        return ceil(ret);
    }
    int UserData::getDamageExp(FighterInfo* info, int damage)
    {
        getCost(info); // for calculation
        return damage*info->cachedDamageExpPerLife;
    }
    void UserData::addExp(FighterInfo* info, int exp)
    {
        info->exp += exp;
    }
    bool UserData::hasLevelUpInfo()
    {
        if (this->levelUpList.size() == 0)
            return false;
        return true;
    }
    std::string UserData::popLevelupMessage()
    {
        LevelupInfo info = this->popLevelupInfo();
        char levelupMessageChar[1000];
        std::stringstream ss;
        ss << "%s has reached Level %d!!\n"
           << "\tLevel :%d → %d\n"
           << "\tShield :%d → %d\n"
           << "\tAtk/Sec :%.2lf → %.2lf\n"
           << "\tBarriar :%d → %d\n"
        ;
        sprintf(levelupMessageChar,
                ss.str().c_str(),
                info.beforeInfo.name.c_str(), info.fighterInfo->level,
                info.beforeInfo.level, info.fighterInfo->level,
                info.beforeInfo.lifeMax, info.fighterInfo->lifeMax,
                this->getDamagePerSecond(&(info.beforeInfo)), this->getDamagePerSecond(info.fighterInfo),
                info.beforeInfo.shieldMax, info.fighterInfo->shieldMax
                );
        std::string ret = std::string(levelupMessageChar);
        return ret;
    }
    
    LevelupInfo UserData::popLevelupInfo()
    {
        assert(this->hasLevelUpInfo());
        LevelupInfo info = levelUpList.back();
        levelUpList.pop_back();
        return info;
    }
    void UserData::checkLevelup()
    {
        LevelupInfoList list;
        list.clear();
        for (FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it)
        {
            LevelupInfo info = levelup(*it);
            if (info.isLevelUp) {
                list.push_back(info);
            }
        }
        levelUpList = list;
    }
    int UserData::getBuyCost(hg::FighterInfo* fInfo)
    {
        int cost = this->getCost(fInfo)*3;
        return cost;
    }
    int UserData::getSellValue(hg::FighterInfo* fInfo)
    {
        int cost = this->getCost(fInfo);
        return cost;
    }
    // return false if failed.
    bool UserData::buy(hg::FighterInfo* fInfo)
    {
        fInfo->isReady = false;
        fInfo->isPlayer = false;
        int cost = this->getBuyCost(fInfo);
        if (this->getMoney() < cost)
        {
            assert(0);
            return false;
        }
        this->addMoney(cost * -1);
        FighterList::iterator buy_it = std::find(shopList.begin(), shopList.end(), fInfo);
        if (shopList.end() == buy_it)
        {
            assert(0);
            return false;
        }
        shopList.erase(buy_it);
        fighterList.push_back(fInfo);
        return true;
    }
    int UserData::getRepairCost(hg::FighterInfo* fInfo)
    {
        float lifeToRepair = fInfo->lifeMax - fInfo->life;
        float lifeToRepairRatio = lifeToRepair/fInfo->lifeMax;
        int value = hg::UserData::sharedUserData()->getCost(fInfo);
        int cost = ceil(lifeToRepairRatio * value*0.5);
        //int cost = ((fInfo->lifeMax - fInfo->life)/fInfo->lifeMax * 0.5 * fInfo->cost);
        if (fInfo->life == 0)
        {
            cost = ceil(value * 0.5);
        }
        return cost;
    }
    // return false if failed.
    bool UserData::sell(hg::FighterInfo* fInfo)
    {
        fInfo->isReady = false;
        fInfo->isPlayer = false;
        int cost = this->getSellValue(fInfo);
        this->addMoney(cost);
        FighterList::iterator buy_it = std::find(fighterList.begin(), fighterList.end(), fInfo);
        if (shopList.end() == buy_it)
        {
            assert(0);
            return false;
        }
        fighterList.erase(buy_it);
        shopList.push_back(fInfo);
        return true;
    }
    void UserData::repairAll()
    {
        for (FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it)
        {
            int cost = this->getRepairCost(*it);
            this->addMoney(-1*cost);
            (*it)->life = (*it)->lifeMax;
        }
    }
    int UserData::getRepairAllCost()
    {
        int cost = 0;
        for (FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it)
        {
            cost += this->getRepairCost(*it);
        }
        return cost;
    }
    void UserData::initBeforeBattle()
    {
        for (FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it)
        {
            (*it)->isOnBattleGround = false;
            (*it)->shield = (*it)->shieldMax;
        }
    }
    void UserData::initAfterBattle()
    {
        for (FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it)
        {
            (*it)->shield = (*it)->shieldMax;
        }
    }
    double UserData::getDamagePerSecond(FighterInfo* info)
    {
        double sum = 0;
        for (WeaponInfoList::iterator it = info->weaponList.begin(); it != info->weaponList.end(); ++it)
        {
            sum += (*it).getDamagePerSecond(info->power);
        }
        return sum;
    }
    int UserData::getCost(FighterInfo* info)
    {
        if (info->isStatusChanged) {
            int cost = info->lifeMax * 3;
            cost += info->shieldMax * 200;
            cost += info->speed * 10000;
            int num = 0;
            for (WeaponInfoList::iterator it = info->weaponList.begin(); it != info->weaponList.end(); ++it)
            {
                num++;
                double tmp = (*it).getDamagePerSecond(info->power)*500*num*num;
                cost += tmp;
            }
            cost += info->shieldHeal * 300000;
            cost += (info->textureSrcHeight * info->textureSrcWidth)*5;
            cost += info->cpu_lv * 1000;
            if (info->isShip)
            {
                cost *= 1.2;
            }
            info->cachedCost = ceil(cost*0.1);
            info->isStatusChanged = false;
            
            info->cachedDamageExpPerLife = ceil(this->getExp(info) / info->lifeMax);
        }
        return info->cachedCost;
    }
    void UserData::setReady(FighterInfo* fighterInfo)
    {
        fighterInfo->isReady = true;
        FighterList::iterator it = std::find(readyList.begin(), readyList.end(), fighterInfo);
        if (readyList.end() != it)
        {
            return;
        }
        readyList.push_back(fighterInfo);
    }
    // sort
    bool compare_by_ready(const FighterInfo* left, const FighterInfo* right)
    {
        if (left->isPlayer)
        {
            return true;
        }
        if (right->isPlayer)
        {
            return false;
        }
        if (left->isReady)
        {
            return true;
        }
        return false;
    }
    bool compare_by_life(const FighterInfo* left, const FighterInfo* right)
    {
        if (left->life > right->life)
        {
            return true;
        }
        return false;
    }
    void UserData::sortFighterList(FighterListSortType sortType)
    {
        switch (sortType) {
            case FighterListSortTypeReady:
                std::sort(fighterList.begin(), fighterList.end(), compare_by_ready);
                std::sort(readyList.begin(), readyList.end(), compare_by_ready);
                break;
            case FighterListSortTypeLife:
                std::sort(fighterList.begin(), fighterList.end(), compare_by_life);
                std::sort(readyList.begin(), readyList.end(), compare_by_life);
                break;
            default:
                break;
        }
        currentSortType = sortType;
    }
    void UserData::sortFighterList()
    {
        currentSortType++;
        if (currentSortType == FighterListSortTypeLast)
        {
            currentSortType = FighterListSortTypeFirst;
            currentSortType++;
        }
        this->sortFighterList(currentSortType);
    }
    void UserData::setUnReady(FighterInfo* fighterInfo)
    {
        fighterInfo->isReady = false;
        FighterList::iterator it = std::find(readyList.begin(), readyList.end(), fighterInfo);
        if (readyList.end() == it)
        {
            assert(0);
        }
        readyList.erase(it);
    }
    FighterList UserData::getFighterList()
    {
        return fighterList;
    }
    FighterInfo* UserData::getPlayerInfo()
    {
        for (hg::FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it)
        {
            hg::FighterInfo* info = *it;
            if (info->isPlayer)
            {
                return info;
            }
        }
        return NULL;
    }
    FighterList UserData::getShopList()
    {
        return shopList;
    }
    FighterList UserData::getReadyList()
    {
        FighterList l;
        for (FighterList::iterator it = readyList.begin(); it != readyList.end(); it++)
        {
            if ((*it)->isPlayer) continue;
            l.push_back(*it);
        }
        return l;
    }
    void UserData::deployAllFighter()
    {
        for (FighterList::iterator it = readyList.begin(); it != readyList.end(); it++)
        {
            if ((*it)->isPlayer) continue;
            (*it)->isOnBattleGround = true;
        }
    }
    void UserData::undeployAllFighter()
    {
        for (FighterList::iterator it = readyList.begin(); it != readyList.end(); it++)
        {
            if ((*it)->isPlayer) continue;
            (*it)->isOnBattleGround = false;
        }
    }
    
    void UserData::setDefaultInfo(FighterInfo* pInfo, int type)
    {
        pInfo->fighterType = type;
        // 種類別の初期化
        switch (type)
        {
            case FighterTypeRobo1:
            {
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 16;
                pInfo->textureSrcHeight = 16;
                pInfo->showPixelWidth = 128;
                pInfo->showPixelHeight = 128;
                pInfo->collisionId = CollisionId_P_ROBO1;
                pInfo->power = 100;
                
                pInfo->life = pInfo->lifeMax = 1000;
                pInfo->shield = pInfo->shieldMax = 0;
                pInfo->speed = 0.1;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeMagic, 0, 0, 0.9, 0.05));
                break;
            }
            case FighterTypeRobo2:
            {
                pInfo->textureName = "e_robo2.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 64;
                pInfo->textureSrcHeight = 64;
                pInfo->showPixelHeight = 256;
                pInfo->showPixelWidth = 256;
                pInfo->collisionId = CollisionId_E_ROBO2;
                pInfo->power = 50;
                
                pInfo->life = pInfo->lifeMax = 1000;
                pInfo->shield = pInfo->shieldMax = 0;
                pInfo->speed = 0.13;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeNormal, 0, 0, 0.6, 0.2));
                
                break;
            }
            case FighterTypeShip1:
            {
                pInfo->textureName = "e_senkan1_4.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 204;
                pInfo->textureSrcHeight = 78;
                pInfo->showPixelWidth = 204*10;
                pInfo->showPixelHeight = 78*10;
                pInfo->collisionId = CollisionId_E_SENKAN;
                pInfo->power = 50;
                
                pInfo->life = pInfo->lifeMax = 10000;
                pInfo->shield = pInfo->shieldMax = 10000;
                pInfo->speed = 0.13;
                pInfo->shieldHeal = 1.5;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeVulcan, 45*10, 0, 0.4, 0.08));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeVulcan, -45*10, 0, 0.4, 0.08));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeVulcan, -90*10, 0, 0.4, 0.08));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeVulcan, 90*10, 0, 0.4, 0.08));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeVulcan, 0, 0, 0.4, 0.08));
                
                pInfo->isShip = true;
                break;
            }
            default:
                assert(0);
        }
    }
    
    
    
}

