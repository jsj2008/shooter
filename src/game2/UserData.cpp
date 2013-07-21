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
#import <algorithm>

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
        ////////////////////
        // fighter list
        
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
            i->life = 1000;
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
        
        ////////////////////
        // shop list
        for (int j = 0; j < 5; j++)
        {
            hg::FighterInfo* i = new hg::FighterInfo();
            i->fighterType = 1;
            i->life = 1000;
            i->lifeMax = 2000;
            i->shield = 1000;
            i->shieldMax = 1000;
            i->speed = 0.3;
            i->cost = 1000;
            std::stringstream ss;
            ss << "Fighter-" << (j + 1) << "号";
            i->name = ss.str();
            shopList.push_back(i);
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
            std::stringstream ss;
            ss << "battle star galactica";
            i->name = ss.str();
            shopList.push_back(i);
        }
        
    }
    int UserData::getBuyCost(hg::FighterInfo* fInfo)
    {
        int cost = fInfo->cost * 3;
        return cost;
    }
    // return false if failed.
    bool UserData::buy(hg::FighterInfo* fInfo)
    {
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
        int cost = ceil(lifeToRepairRatio * fInfo->cost * 0.5);
        //int cost = ((fInfo->lifeMax - fInfo->life)/fInfo->lifeMax * 0.5 * fInfo->cost);
        if (fInfo->life == 0)
        {
            cost = ceil(fInfo->cost * 1.5);
        }
        return cost;
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
                break;
            case FighterListSortTypeLife:
                std::sort(fighterList.begin(), fighterList.end(), compare_by_life);
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
        return readyList;
    }
    
    
}

