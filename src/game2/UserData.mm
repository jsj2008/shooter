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
    
    const std::string IntKeyMoney = "money";
    const std::string IntKeyStageId = "stage_id";
    const std::string IntKeyCompPoint = "comp_point";
    const std::string IntKeyCameraPos = "camera_pos";
    const std::string IntKeyScore = "score";
    const std::string IntKeyTotalKill = "total_kill";
    const std::string IntKeyTotalDead = "total_dead";
    const std::string IntKeyWinCount = "win_count";
    const std::string IntKeyLoseCount = "lose_count";
    const std::string IntKeyRetreatCount = "retreat_count";
    
    const float MaxCamera = -15;
    const float MinCamera = -40;
    
    int status_rand(int from, int to) {
        if (from == to) return from;
        int r = std::rand()%(to - from + 1);
        int ret = r+from;
        return ret;
    }
    
    double getNextExp(hg::FighterInfo* fighterInfo)
    {
        return (int) ((fighterInfo->level + 1) * (fighterInfo->level + 1) * 40) + 500;
    }
    
    int ceiling(int value, int figure) {
        int a = pow(10, figure);
        float b = (float)value / (float)a;
        return ceil(b) * a;
    }
    
    void levelupInner(hg::FighterInfo* fighterInfo)
    {
        // ステータス変更
        std::srand(fighterInfo->seed);
        // 攻撃力
        if (std::rand()%100 < 33) {
            fighterInfo->power += ceil(std::rand()%(fighterInfo->powerPotential * 3));
        }
        // life
        int addLife = ceil(std::rand()%(fighterInfo->defencePotential));
        fighterInfo->lifeMax += addLife;
        fighterInfo->life += addLife;
        
        // shield
        if (std::rand()%100 < 25) {
            if (fighterInfo->shield > 0 && fighterInfo->shieldPotential > 0) {
                fighterInfo->shieldMax += ceil(std::rand()%fighterInfo->shieldPotential * 4);
            }
        }
        // flag
        fighterInfo->isStatusChanged = true;
        fighterInfo->seed = std::rand();
    }
    
    LevelupInfo levelup(hg::FighterInfo* fighterInfo)
    {
        hg::FighterInfo before = *fighterInfo;
        if (fighterInfo->level >= 300)
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
    
    void UserData::upCamera()
    {
        this->cameraPositionY -= 0.3;
        this->cameraPositionY = MAX(MinCamera, this->cameraPositionY);
    }
    
    void UserData::downCamera()
    {
        this->cameraPositionY += 0.3;
        this->cameraPositionY = MIN(MaxCamera, this->cameraPositionY);
    }
    
    float UserData::getCameraPosition()
    {
        return this->cameraPositionY;
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
    BattleResult UserData::getLatestBattleResult()
    {
        return lastBattleResult;
    }
    void UserData::addBattleScore(int val) {
        score += val;
        score = MAX(0, score);
        score = MIN(99999999, score);
        calcGrade();
    }
    void UserData::setBattleResult(BattleResult br)
    {
        is_cleared = false;
        checkLevelup();
        br.allShotMoney = ceil(br.allShotPower*0.01);
        int income = br.allShotMoney * -1;
        //br.battleScore = -1 * ceil(br.deadValue * 0.0001);
        totalDead += br.killedFriend;
        totalDead = MIN(totalDead, 99999999);
        totalKill += br.killedEnemy;
        totalKill = MIN(totalKill, 99999999);
        if (br.isWin)
        {
            income += br.earnedMoney;
            this->addPoint(getStageInfo().win_point);
            
            // 戦果
            br.battleScore += ceil(br.killedValue * 0.001);
            
            // clear?
            if (this->getCurrentClearRatio() >= 1) {
                is_cleared = true;
            }
            winCount++;
        }
        else if (br.isRetreat)
        {
            this->addPoint(getStageInfo().retrieve_point * -1);
            retreatCount++;
        }
        else
        {
            this->addPoint(getStageInfo().lose_point * -1);
            loseCount++;
        }
        br.finalIncome = income;
        addMoney(income);
        addBattleScore(br.battleScore);
        
        StageInfo stageInfo = this->getStageInfo();
        if (is_cleared) {
            for (FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it)
            {
                (*it)->life = (*it)->lifeMax;
            }
            rewardInfoList.push_back({
                "All Fighters are repaired!"
            });
            float battleScoreReward = 0;
            float battleMoneyReward = 0;
            switch (stage_id) {
                case 1: // earth
                    battleScoreReward = 1000;
                    battleMoneyReward = 25000;
                    break;
                case 2:
                    battleScoreReward = 10000;
                    battleMoneyReward = 50000;
                    break;
                case 3:
                    battleScoreReward = 50000;
                    battleMoneyReward = 100000;
                    break;
                case 4:
                    battleScoreReward = 150000;
                    battleMoneyReward = 300000;
                    break;
                case 5:
                    battleScoreReward = 300000;
                    battleMoneyReward = 1000000;
                    break;
                    /*
                case 6:
                    battleScoreReward = 300000;
                    battleMoneyReward = 800000;
                    break;
                case 7:
                    battleScoreReward = 500000;
                    battleMoneyReward = 1000000;
                    break;
                case 8:
                    battleScoreReward = 1000000;
                    battleMoneyReward = 2000000;
                    break;*/
                default:
                    break;
            }
            if (battleScoreReward > 0) {
                addBattleScore(battleScoreReward);
                std::stringstream ss;
                ss << "You got " << battleScoreReward << "Bonus Pt!";
                rewardInfoList.push_back({
                    ss.str()
                });
            }
            if (battleMoneyReward > 0) {
                addBattleScore(battleScoreReward);
                std::stringstream ss;
                ss << "You got " << battleScoreReward << "Bonus Gold!";
                rewardInfoList.push_back({
                    ss.str()
                });
            }
            std::stringstream ss;
            ss << "Congraturation!!\nYou cleared ";
            ss << stageInfo.stage_name_short << " Stage!!";
            rewardInfoList.push_back({
                ss.str()
            });
        }
        this->lastBattleResult = br;
    }
    
    void UserData::calcGrade()
    {
        if (score <= 250) {
            grade = "学生";
            maxAllyNum = 1;
            maxPowerUpNum = 1;
        }
        else if (score <= 500) {
            grade = "研修生";
            maxAllyNum = 2;
            maxPowerUpNum = 1;
        }
        else if (score <= 1000) {
            grade = "上等兵";
            maxAllyNum = 2;
            maxPowerUpNum = 2;
        }
        else if (score <= 2500) {
            grade = "伍長";
            maxAllyNum = 3;
            maxPowerUpNum = 2;
        }
        else if (score <= 5000) {
            grade = "曹長";
            maxAllyNum = 3;
            maxPowerUpNum = 2;
        }
        else if (score <= 20000) {
            grade = "准尉";
            maxAllyNum = 4;
            maxPowerUpNum = 4;
        }
        else if (score <= 50000) {
            grade = "少尉";
            maxAllyNum = 4;
            maxPowerUpNum = 4;
        }
        else if (score <= 100000) {
            grade = "中尉";
            maxAllyNum = 5;
            maxPowerUpNum = 4;
        }
        else if (score <= 200000) {
            grade = "大尉";
            maxAllyNum = 5;
            maxPowerUpNum = 5;
        }
        else if (score <= 300000) {
            grade = "少佐";
            maxAllyNum = 6;
            maxPowerUpNum = 5;
        }
        else if (score <= 500000) {
            grade = "大佐";
            maxAllyNum = 6;
            maxPowerUpNum = 5;
        }
        else if (score <= 800000) {
            grade = "准将";
            maxAllyNum = 7;
            maxPowerUpNum = 5;
        }
        else if (score <= 1200000) {
            grade = "少将";
            maxAllyNum = 8;
            maxPowerUpNum = 5;
        }
        else if (score <= 1500000) {
            grade = "中将";
            maxAllyNum = 9;
            maxPowerUpNum = 5;
        }
        else if (score <= 2000000) {
            grade = "大将";
            maxAllyNum = 10;
            maxPowerUpNum = 6;
        }
        else if (score <= 10000000) {
            grade = "元帥";
            maxAllyNum = 15;
            maxPowerUpNum = 10;
        }
    }
    
    std::string UserData::getGrade()
    {
        if (grade == "")
        {
            this->calcGrade();
        }
        return grade;
    }
    
    void UserData::loadData()
    {
        // データをロード
        userdata::initDatabase();
        userdata::open();
        fighterList = userdata::readFighter(userdata::FighterRecordTypeFighter);
        shopList = userdata::readFighter(userdata::FighterRecordTypeShop);
        
        // money
        money = userdata::readIntegerData(IntKeyMoney);
        // stage id
        this->setStageId(userdata::readIntegerData(IntKeyStageId));
        // comp point
        complete_point = userdata::readIntegerData(IntKeyCompPoint);
        // camera pos
        cameraPositionY = userdata::readIntegerData(IntKeyCameraPos) * 0.1;
        if (cameraPositionY < MinCamera || cameraPositionY > MaxCamera) {
            cameraPositionY = -18;
        }
        // score
        score = userdata::readIntegerData(IntKeyScore);
        // kill
        totalKill = userdata::readIntegerData(IntKeyTotalKill);
        // dead
        totalDead = userdata::readIntegerData(IntKeyTotalDead);
        // win
        winCount = userdata::readIntegerData(IntKeyWinCount);
        // lose
        loseCount = userdata::readIntegerData(IntKeyLoseCount);
        // retreat
        retreatCount = userdata::readIntegerData(IntKeyRetreatCount);
        // calc grade
        calcGrade();
        
        userdata::close();
        
        // データあり
        if (fighterList.size() > 0) {
            for (FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it) {
                if ((*it)->isPlayer || !(*it)->isReady) {
                    continue;
                }
                readyList.push_back(*it);
            }
        }
        // データがない場合新規
        else {
            srand((unsigned int)time(NULL));
            
            ////////////////////
            // fighter list
            ////////////////////
            
            hg::FighterInfo* pPlayerInfo = new hg::FighterInfo();
            if (IS_DEBUG_SHOOTER) {
                hg::UserData::sharedUserData()->setDefaultInfo(pPlayerInfo, FighterTypePegasus);
            } else {
                hg::UserData::sharedUserData()->setDefaultInfo(pPlayerInfo, FighterTypeViperC);
            }
            fighterList.push_back(pPlayerInfo);
            pPlayerInfo->isPlayer = true;
            if (IS_DEBUG_SHOOTER) {
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeRaderC);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeVesariusC);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeViper);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypePegasus);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeRapter);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeRapter2);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeAstray);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeAstray2);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeStarFighter);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeViperL);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeFox);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeGloire);
                    fighterList.push_back(i);
                }
                {
                    hg::FighterInfo* i = new hg::FighterInfo();
                    hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypelambda);
                    fighterList.push_back(i);
                }
            }
            
            ////////////////////
            // shop list
            ////////////////////
            for (int j = 0; j < 3; j++)
            {
                hg::FighterInfo* i = new hg::FighterInfo();
                hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeViper);
                shopList.push_back(i);
            }
            for (int j = 0; j < 3; j++)
            {
                hg::FighterInfo* i = new hg::FighterInfo();
                hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypeRapter);
                shopList.push_back(i);
            }
            hg::FighterInfo* i = new hg::FighterInfo();
            hg::UserData::sharedUserData()->setDefaultInfo(i, FighterTypePegasus);
            shopList.push_back(i);
            
            // stage
            this->setStageId(1);
            
            money = 30000;
        }
    }
    
    bool UserData::DeleteAllData()
    {
        bool ret = true;
        try {
            if (!userdata::open()) throw "open failed";
            if (!userdata::begin()) throw "begin failed";
            
            if (!userdata::deleteAllData()) throw "delete all data failed";
            if (!userdata::commit()) throw "commit failed";
            userdata::close();
        } catch (const char* err) {
            userdata::rollback();
            userdata::close();
            NSLog(@"delete error!");
            ret = false;
        }
        if (ret) {
            userdata::deleteDatabase();
            delete instance;
            instance = new UserData();
            if (!instance->saveData()) return false;
            instance->loadData();
        }
        return true;
    }
    
    // データ保存
    bool UserData::saveData()
    {
        try {
            userdata::initDatabase();
            if (!userdata::open()) throw "open failed";
            if (!userdata::begin()) throw "begin failed";
            
            // 一旦全部消してから全部をインサート
            userdata::deleteAllFighterData();
            
            int inc_id = -1;
            // fighter list
            for (FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it) {
                inc_id++;
                bool ret = userdata::insertFighterInfo(inc_id, userdata::FighterRecordTypeFighter, *it);
                if (!ret) throw "insert fighter failed";
            }
            
            // shop list
            for (FighterList::iterator it = shopList.begin(); it != shopList.end(); ++it) {
                inc_id++;
                bool ret = userdata::insertFighterInfo(inc_id, userdata::FighterRecordTypeShop, *it);
                if (!ret) throw "insert shop failed";
            }
            
            // money
            if (!userdata::updateOrInsertIntegerData(IntKeyMoney, (long)this->money))throw "write money failed";
            
            // stageId
            if (!userdata::updateOrInsertIntegerData(IntKeyStageId, (long)this->stage_id))throw "write stageId failed";
            
            // complete point
            if (!userdata::updateOrInsertIntegerData(IntKeyCompPoint, (long)this->complete_point))throw "write comp point failed";
            
            // camera pos
            if (!userdata::updateOrInsertIntegerData(IntKeyCameraPos, (long)this->cameraPositionY*10))throw "write camera pos failed";
            
            // score
            if (!userdata::updateOrInsertIntegerData(IntKeyScore, (long)this->score))throw "write score failed";
            
            // total_kill
            if (!userdata::updateOrInsertIntegerData(IntKeyTotalKill, (long)this->totalKill))throw "write total kill failed";
            
            // total_dead
            if (!userdata::updateOrInsertIntegerData(IntKeyTotalDead, (long)this->totalDead))throw "write total dead failed";
            
            // win
            if (!userdata::updateOrInsertIntegerData(IntKeyWinCount, (long)this->winCount))throw "write win count failed";
            
            // lose
            if (!userdata::updateOrInsertIntegerData(IntKeyLoseCount, (long)this->loseCount))throw "write lose count failed";
            
            // retreat
            if (!userdata::updateOrInsertIntegerData(IntKeyRetreatCount, (long)this->retreatCount))throw "write retreat count failed";
            
            if (!userdata::commit()) throw "commit failed";
            userdata::close();
        } catch (const char* err) {
            userdata::rollback();
            userdata::close();
            NSLog(@"insert error!(%s)", err);
            return false;
        }
        return true;
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
        double ratio = (double)complete_point/100.0;
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
    int UserData::getStageNum()
    {
        return 5;
    }
    void UserData::setStageId(int next_stage_id)
    {
        if (next_stage_id == 0) {
            next_stage_id = 1;
        }
        stage_id = next_stage_id;
        currentStageInfo = getStageInfo(next_stage_id);
        complete_point = 0;
    }
    long UserData::getTotalScore()
    {
        return score;
    }
    long UserData::getTotalDead()
    {
        return totalDead;
    }
    long UserData::getTotalKill()
    {
        return totalKill;
    }
    long UserData::getWinCount()
    {
        return winCount;
    }
    long UserData::getLoseCount()
    {
        return loseCount;
    }
    long UserData::getRetreatCount()
    {
        return retreatCount;
    }
    StageInfo UserData::getStageInfo(int stage_id)
    {
        StageInfo info;
        info.stage_id = stage_id;
        info.win_point = 20;
        info.lose_point = 0;
        info.retrieve_point = 0;
        
        // name
        std::string stage_name = "";
        switch (stage_id) {
            case 1:
                stage_name = "地球";
                info.win_point = 100;
                info.model_name = "pl_earth";
                info.small_size = 40;
                info.big_size = 160;
                break;
            case 2:
                stage_name = "火星";
                info.win_point = 12;
                info.lose_point = 8;
                info.model_name = "pl_mars";
                info.small_size = 30;
                info.big_size = 150;
                break;
            case 3:
                stage_name = "木星";
                info.win_point = 10;
                info.lose_point = 10;
                info.model_name = "pl_jupiter";
                info.small_size = 100;
                info.big_size = 250;
                break;
            case 4:
                stage_name = "金星";
                info.win_point = 3;
                info.lose_point = 3;
                info.model_name = "pl_venus";
                info.small_size = 50;
                info.big_size = 170;
                break;
            case 5:
                stage_name = "太陽";
                info.win_point = 1;
                info.lose_point = 1;
                info.model_name = "pl_sun";
                info.small_size = 150;
                info.big_size = 260;
                break;
                /*
                 case 2:
                stage_name = "月";
                info.win_point = 16;
                info.lose_point = 5;
                info.model_name = "pl_luna";
                info.small_size = 20;
                info.big_size = 120;
                break;
            case 5:
                stage_name = "天王星";
                info.win_point = 8;
                info.lose_point = 8;
                info.model_name = "pl_uranus";
                info.small_size = 80;
                info.big_size = 220;
                break;
            case 6:
                stage_name = "海王星";
                info.win_point = 5;
                info.lose_point = 5;
                info.model_name = "pl_neptune";
                info.small_size = 60;
                info.big_size = 200;
                break;*/
            default:
                assert(0);
                break;
        }
        
        char stage_name_str[1000];
        info.stage_name_short = stage_name;
        sprintf(stage_name_str, "STAGE %d : %s", stage_id, stage_name.c_str());
        info.stage_name = std::string(stage_name_str);
        return info;
    }
    StageInfo UserData::getStageInfo()
    {
        return currentStageInfo;
    }
    void UserData::addPoint(int add)
    {
        complete_point += add;
        complete_point = MAX(0, complete_point);
        complete_point = MIN(100, complete_point);
    }
    int UserData::getExp(FighterInfo* info)
    {
        int cost = getCost(info);
        double ret = (double)cost * 0.105;
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
    bool UserData::isCleared()
    {
        bool a = is_cleared;
        is_cleared = false;
        return a;
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
           << "\tHP :%d → %d\n"
           << "\tAtk/Sec :%.0lf → %.0lf\n"
        ;
        if (info.fighterInfo->shieldMax > 0) {
           ss << "\tShield :%d → %d\n";
        }
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
    
    bool UserData::hasRewardInfo()
    {
        if (this->rewardInfoList.size() == 0)
            return false;
        return true;
    }
    std::string UserData::popRewardMessage()
    {
        if (rewardInfoList.size() <= 0) return "";
        RewardInfo info = rewardInfoList.back();
        rewardInfoList.pop_back();
        return info.message;
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
        return ceiling(cost, 2);
    }
    int UserData::getSellValue(hg::FighterInfo* fInfo)
    {
        int cost = this->getCost(fInfo);
        return ceiling(cost, 2);
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
        int cost = hg::UserData::sharedUserData()->getCost(fInfo);
        int ret = 0;
        if (fInfo->life >= 0) {
            float lifeToRepair = fInfo->lifeMax - fInfo->life;
            float lifeToRepairRatio = lifeToRepair/fInfo->lifeMax;
            int value = hg::UserData::sharedUserData()->getCost(fInfo) * 0.5;
            ret = ceil(lifeToRepairRatio * value);
            ret = ceiling(ret, 2);
        }
        else {
            ret = ceiling(cost * 0.8, 2);
        }
        return ret;
    }
    int UserData::getKillReward(hg::FighterInfo* fInfo)
    {
        int cost = hg::UserData::sharedUserData()->getCost(fInfo);
        return cost*0.1;
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
    void UserData::addShop(int type)
    {
        hg::FighterInfo* info = new hg::FighterInfo();
        this->setDefaultInfo(info, type);
        shopList.push_back(info);
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
    
    void UserData::returnToBase()
    {
        for (FighterList::iterator it = fighterList.begin(); it != fighterList.end(); ++it)
        {
            (*it)->life = (*it)->lifeMax;
        }
        if (complete_point < 1.0) {
            this->addMoney(-1*money/2);
        }
        complete_point = 0;
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
            double dps = 0;
            for (WeaponInfoList::iterator it = info->weaponList.begin(); it != info->weaponList.end(); ++it)
            {
                dps += (*it).getDamagePerSecond(info->power);
            }
            double weaponNumRatio = 1 + ((info->weaponList.size() - 1) / 10);
            double speedRatio = 0.5 + info->speed;
            double isShipRatio = info->isShip?1.2:1;
            
            int cost = dps*10 + dps*5 + dps + info->lifeMax + info->shieldMax*5;
            
            cost *= weaponNumRatio;
            cost *= speedRatio;
            cost *= isShipRatio;
            cost = ceiling(cost, 2);
            if (cost < 0 || cost > 99999999) {
                cost = 99999999;
            }
            
            info->cachedCost = cost;
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
        std::srand((unsigned int)time(NULL));
        pInfo->fighterType = type;
        float stageProgressRatio = stage_id/getStageNum();
        // 種類別の初期化
        switch (type)
        {
            ////////////////////
            // Friend
            ////////////////////
            case FighterTypeAstray:
            {
                pInfo->name = "Astray";
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 16;
                pInfo->textureSrcHeight = 16;
                pInfo->showPixelWidth = 256;
                pInfo->showPixelHeight = 256;
                pInfo->collisionId = CollisionId_P_ROBO1;
                pInfo->power = 30;
                
                pInfo->life = pInfo->lifeMax = 800;
                pInfo->shield = pInfo->shieldMax = 0;
                pInfo->speed = 0.60;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeShotgun, BulletTypeFriendNormal, 0, 0, 1.55, 0.30));
                break;
            }
            case FighterTypeAstray2:
            {
                pInfo->name = "Astray MkⅡ";
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 16;
                pInfo->textureSrcHeight = 16;
                pInfo->showPixelWidth = 256;
                pInfo->showPixelHeight = 256;
                pInfo->collisionId = CollisionId_P_ROBO1;
                pInfo->power = 50;
                
                pInfo->life = pInfo->lifeMax = 1000;
                pInfo->shield = pInfo->shieldMax = 1000;
                pInfo->speed = 0.78;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeStraight, BulletTypeFriendLaser, 0, 0, 1.75, 0.15));
                break;
            }
            case FighterTypeViper:
            {
                pInfo->name = "Viper";
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 16;
                pInfo->textureSrcWidth = 16;
                pInfo->textureSrcHeight = 16;
                pInfo->showPixelWidth = 256;
                pInfo->showPixelHeight = 256;
                pInfo->collisionId = CollisionId_P_VIPER;
                pInfo->power = 15;
                
                pInfo->life = pInfo->lifeMax = 400;
                pInfo->shield = pInfo->shieldMax = 0;
                pInfo->speed = 0.70;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeFriendNormal, 0, 0, 1.35, 0.14));
                
                break;
            }
            case FighterTypeViperC:
            {
                pInfo->name = "Viper Custom";
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 16;
                pInfo->textureSrcWidth = 16;
                pInfo->textureSrcHeight = 16;
                pInfo->showPixelWidth = 256;
                pInfo->showPixelHeight = 256;
                pInfo->collisionId = CollisionId_P_VIPER;
                pInfo->power = 20;
                
                pInfo->life = pInfo->lifeMax = 1000;
                pInfo->shield = pInfo->shieldMax = 0;
                pInfo->speed = 0.85;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwin, BulletTypeFriendNormal, 0, 0, 1.1, 0.15));
                
                break;
            }
            case FighterTypeViperL:
            {
                pInfo->name = "Viper MkⅡ";
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 16;
                pInfo->textureSrcWidth = 16;
                pInfo->textureSrcHeight = 16;
                pInfo->showPixelWidth = 256;
                pInfo->showPixelHeight = 256;
                pInfo->collisionId = CollisionId_P_VIPER;
                pInfo->power = 50;
                
                pInfo->life = pInfo->lifeMax = 700;
                pInfo->shield = pInfo->shieldMax = 300;
                pInfo->speed = 0.90;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeFriendLaser, 0, 0, 1.6, 0.15));
                break;
            }
            case FighterTypeRapter:
            {
                pInfo->name = "Rapter";
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 32;
                pInfo->textureSrcWidth = 24;
                pInfo->textureSrcHeight = 24;
                pInfo->showPixelWidth = 300;
                pInfo->showPixelHeight = 300;
                pInfo->collisionId = CollisionId_P_RAPTER;
                pInfo->power = 75;
                
                pInfo->life = pInfo->lifeMax = 3500;
                pInfo->shield = pInfo->shieldMax = 500;
                pInfo->speed = 0.68;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwin, BulletTypeFriendNormal, 0, 0, 0.95, 0.10));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeFriendMedium, 0, 0, 1.05, 0.20));
                break;
            }
            case FighterTypeRapter2:
            {
                pInfo->name = "Rapter MkⅡ";
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 32;
                pInfo->textureSrcWidth = 24;
                pInfo->textureSrcHeight = 24;
                pInfo->showPixelWidth = 300;
                pInfo->showPixelHeight = 300;
                pInfo->collisionId = CollisionId_P_RAPTER;
                pInfo->power = 145;
                
                pInfo->life = pInfo->lifeMax = 5000;
                pInfo->shield = pInfo->shieldMax = 1000;
                pInfo->speed = 0.72;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwinLaser, BulletTypeFriendLaser, 0, 0, 1.5, 0.16));
                break;
            }
            case FighterTypeStarFighter:
            {
                pInfo->name = "StarFighter";
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 56;
                pInfo->textureSrcWidth = 16;
                pInfo->textureSrcHeight = 16;
                pInfo->showPixelWidth = 256;
                pInfo->showPixelHeight = 256;
                pInfo->collisionId = CollisionId_P_VIPER;
                pInfo->power = 145;
                
                pInfo->life = pInfo->lifeMax = 350;
                pInfo->shield = pInfo->shieldMax = 2000;
                pInfo->speed = 1.05;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeFriendLaser, 0, 0, 2.1, 0.13));
                break;
            }
            case FighterTypelambda:
            {
                pInfo->name = "Ramdass";
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 72;
                pInfo->textureSrcWidth = 28;
                pInfo->textureSrcHeight = 28;
                pInfo->showPixelWidth = 328;
                pInfo->showPixelHeight = 328;
                pInfo->collisionId = CollisionId_P_VIPER;
                pInfo->power = 140;
                
                pInfo->life = pInfo->lifeMax = 1800;
                pInfo->shield = pInfo->shieldMax = 1000;
                pInfo->speed = 0.85;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwinLaser, BulletTypeFriendLaser, 0, 0, 2.2, 0.10));
                break;
            }
            case FighterTypeGloire:
            {
                pInfo->name = "Gloire";
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 90;
                pInfo->textureSrcWidth = 28;
                pInfo->textureSrcHeight = 28;
                pInfo->showPixelWidth = 328;
                pInfo->showPixelHeight = 328;
                pInfo->collisionId = CollisionId_P_VIPER;
                pInfo->power = 140;
                
                pInfo->life = pInfo->lifeMax = 1500;
                pInfo->shield = pInfo->shieldMax = 800;
                pInfo->speed = 0.85;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeShotgun, BulletTypeFriendMedium, 0, 0, 1.3, 0.23));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTriple, BulletTypeFriendNormal, 0, 0, 1.4, 0.15));
                break;
            }
            case FighterTypeFox:
            {
                pInfo->name = "Falcon";
                pInfo->textureName = "p_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 118;
                pInfo->textureSrcWidth = 28;
                pInfo->textureSrcHeight = 28;
                pInfo->showPixelWidth = 328;
                pInfo->showPixelHeight = 328;
                pInfo->collisionId = CollisionId_P_VIPER;
                pInfo->power = 150;
                
                pInfo->life = pInfo->lifeMax = 3000;
                pInfo->shield = pInfo->shieldMax = 1500;
                pInfo->speed = 0.92;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMegaLaser, BulletTypeFriendBig, 0, 0, 1.9, 0.30));
                break;
            }
            case FighterTypePegasus:
            {
                pInfo->name = "Pegasus Class";
                pInfo->textureName = "p_ship1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 141;
                pInfo->textureSrcHeight = 62;
                pInfo->showPixelWidth = 141*10;
                pInfo->showPixelHeight = 62*10;
                pInfo->collisionId = CollisionId_P_PEGASUS;
                pInfo->power = 40;
                
                pInfo->life = pInfo->lifeMax = 20000;
                pInfo->shield = pInfo->shieldMax = 5000;
                pInfo->speed = 0.65;
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwin, BulletTypeFriendBig, 0, 0, 1.4, 0.68));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveWay, BulletTypeFriendNormal, -35*10, 0, 0.6, 0.28));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeThreeWay, BulletTypeFriendNormal, 34*10, -140, 0.6, 0.38));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeCircle, BulletTypeFriendMedium, 0, 0, 0.5, 1.28));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveWay, BulletTypeFriendNormal, -240, 0, 0.9, 0.40));
                
                pInfo->isShip = true;
                break;
            }
            case FighterTypeRaderC:
            {
                pInfo->name = "Rader";
                pInfo->textureName = "e_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 24;
                pInfo->textureSrcHeight = 24;
                pInfo->showPixelHeight = 420;
                pInfo->showPixelWidth = 420;
                pInfo->collisionId = CollisionId_P_RADER;
                pInfo->power = 50;
                
                pInfo->life = pInfo->lifeMax = 1000;
                pInfo->shield = pInfo->shieldMax = 1000;
                pInfo->speed = 0.75;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeThreeWay, BulletTypeFriendNormal, 0, 0, 0.80, 0.2));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveWay, BulletTypeFriendMedium, 0, 0, 0.85, 0.4));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwin, BulletTypeFriendNormal, 0, 0, 0.94, 0.6));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeFriendMedium, 0, 0, 1.00, 0.3));
                
                break;
            }
            case FighterTypeVesariusC:
            {
                pInfo->name = "Vesalius Class";
                pInfo->textureName = "e_senkan1_4.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 204;
                pInfo->textureSrcHeight = 78;
                pInfo->showPixelWidth = 204*10;
                pInfo->showPixelHeight = 78*10;
                pInfo->collisionId = CollisionId_E_SENKAN;
                pInfo->power = 40;
                
                pInfo->life = pInfo->lifeMax = 28000;
                pInfo->shield = pInfo->shieldMax = 15000;
                pInfo->speed = 0.38;
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMegaLaser, BulletTypeFriendBig, 45*10, 0, 1.7, 0.50));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwinLaser, BulletTypeFriendLaser, 90*10, 0, 1.7, 0.25));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwinLaser, BulletTypeFriendLaser, -90*10, 0, 1.9, 0.28));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeCircle, BulletTypeFriendMedium, 0, 0, 0.6, 1.38));
                
                pInfo->isShip = true;
                break;
            }
            ////////////////////
            // Enemy
            ////////////////////
            case FighterTypeBall:
            {
                pInfo->name = "Ball";
                pInfo->textureName = "e_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 24;
                pInfo->textureSrcWidth = 20;
                pInfo->textureSrcHeight = 20;
                pInfo->showPixelHeight = 320;
                pInfo->showPixelWidth = 320;
                pInfo->collisionId = CollisionId_E_BALL;
                
                pInfo->power = 20;
                
                pInfo->life = pInfo->lifeMax = 100;
                pInfo->shield = pInfo->shieldMax = 0;
                pInfo->speed = 0.4;
                
                int maxLv = 6;
                int minLv = rand(0, maxLv/2*stageProgressRatio);
                int lv = rand(minLv, maxLv*stageProgressRatio);
                switch (lv) {
                    case 0:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeNormal, 0, 0, 0.4, 0.4));
                        break;
                    case 1:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeCircle, BulletTypeNormal, 0, 0, 0.3, 0.35));
                        break;
                    case 2:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeThreeWay, BulletTypeNormal, 0, 0, 0.4, 0.35));
                        break;
                    case 3:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveWay, BulletTypeNormal, 0, 0, 0.35, 0.40));
                        break;
                    case 4:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeLaser, 0, 0, 1.75, 0.60));
                        break;
                    case 5:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeShotgun, BulletTypeNormal, 0, 0, 0.75, 0.70));
                        break;
                    case 6:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotate, BulletTypeNormal, 0, 0, 0.45, 0.15));
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateR, BulletTypeNormal, 0, 0, 0.45, 0.15));
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeAK, BulletTypeNormal, 0, 0, 0.75, 0.08));
                    default:
                        break;
                }
                
                break;
            }
            case FighterTypeRader:
            {
                pInfo->name = "Rader";
                pInfo->textureName = "e_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 24;
                pInfo->textureSrcHeight = 24;
                pInfo->showPixelHeight = 420;
                pInfo->showPixelWidth = 420;
                pInfo->collisionId = CollisionId_E_RADER;
                pInfo->power = 35;
                
                pInfo->life = pInfo->lifeMax = 300;
                pInfo->shield = pInfo->shieldMax = 0;
                pInfo->speed = 0.5;
                
                int maxLv = 5;
                int minLv = rand(0, maxLv/2*stageProgressRatio);
                int lv = rand(minLv, maxLv*stageProgressRatio);
                switch (lv) {
                    case 0:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeThreeWay, BulletTypeNormal, 0, 0, 0.3, 0.3));
                        break;
                    case 1:
                    {
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeShotgun, BulletTypeNormal, 0, 0, 0.2, 0.45));
                        int wType = WeaponTypeRotate;
                        if (rand(0, 1) == 0) {
                            wType = WeaponTypeRotateR;
                        }
                        pInfo->weaponList.push_back(WeaponInfo(wType, BulletTypeNormal, 0, 0, 0.3, 0.2));
                        break;
                }
                    case 2:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateQuad, BulletTypeNormal, 0, 0, 0.4, 0.15));
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeAK, BulletTypeNormal, 0, 0, 0.8, 0.05));
                        break;
                    case 3:
                    {
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeCircleRotate, BulletTypeMedium, 0, 0, 0.25, 0.20));
                        
                        int wType = WeaponTypeRotate;
                        if (rand(0, 1) == 0) {
                            wType = WeaponTypeRotateR;
                        }
                        pInfo->weaponList.push_back(WeaponInfo(wType, BulletTypeNormal, 0, 0, 0.3, 0.2));
                        break;
                    }
                    case 4:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeLaser, 0, 0, 1.60, 0.50));
                        break;
                    case 5:
                    {
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveWay, BulletTypeNormal, 0, 0, 0.55, 0.20));
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeStraight, BulletTypeNormal, 0, 0, 0.85, 0.50));
                        
                        int wType = WeaponTypeRotate;
                        if (rand(0, 1) == 0) {
                            wType = WeaponTypeRotateR;
                        }
                        pInfo->weaponList.push_back(WeaponInfo(wType, BulletTypeNormal, 0, 0, 0.65, 0.09));
                        break;
                    }
                    default:
                        break;
                }
                
                break;
            }
            case FighterTypeSuperRader:
            {
                pInfo->name = "Super Rader";
                pInfo->textureName = "e_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 24;
                pInfo->textureSrcHeight = 24;
                pInfo->showPixelHeight = 420;
                pInfo->showPixelWidth = 420;
                pInfo->collisionId = CollisionId_E_RADER;
                pInfo->power = 75;
                
                pInfo->life = pInfo->lifeMax = 10000;
                pInfo->shield = pInfo->shieldMax = 5000;
                pInfo->speed = 0.5;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeThreeWay, BulletTypeNormal, 0, 0, 0.3, 0.3));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeShotgun, BulletTypeNormal, 0, 0, 0.2, 0.45));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateQuad, BulletTypeNormal, 0, 0, 0.4, 0.15));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateR, BulletTypeNormal, 0, 0, 0.8, 0.05));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeCircleRotate, BulletTypeMedium, 0, 0, 0.25, 0.20));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeLaser, 0, 0, 1.60, 0.50));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveWay, BulletTypeNormal, 0, 0, 0.55, 0.20));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeCircle, BulletTypeNormal, 0, 0, 0.85, 0.50));
                break;
            }
            case FighterTypeGates:
            {
                pInfo->name = "Gates";
                pInfo->textureName = "e_robo2.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 64;
                pInfo->textureSrcHeight = 64;
                pInfo->showPixelHeight = 550;
                pInfo->showPixelWidth = 550;
                pInfo->collisionId = CollisionId_E_GATES;
                pInfo->power = 35;
                
                pInfo->life = pInfo->lifeMax = 800;
                pInfo->shield = pInfo->shieldMax = 0;
                pInfo->speed = 0.6;
                
                int maxLv = 6;
                int minLv = rand(0, 0*stageProgressRatio);
                int lv = rand(minLv, maxLv*stageProgressRatio);
                switch (lv) {
                    case 0:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeStraight, BulletTypeNormal, 0, 0, 0.4, 0.4));
                        break;
                    case 1:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeLaser, 0, 0, 1.4, 0.85));
                        break;
                    case 2:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeThreeWay, BulletTypeMedium, 0, 0, 0.5, 0.10));
                        break;
                    case 3:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeLaser, 0, 0, 1.40, 0.80));
                        break;
                    case 4:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeAK, BulletTypeMedium, 0, 0, 1.05, 0.08));
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeCircle, BulletTypeMedium, 0, 0, 0.35, 0.58));
                        break;
                    case 5:
                    {
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeShotgun, BulletTypeMedium, 0, 0, 0.85, 0.30));
                        
                        int wType = WeaponTypeRotate;
                        if (rand(0, 1) == 0) {
                            wType = WeaponTypeRotateR;
                        }
                        pInfo->weaponList.push_back(WeaponInfo(wType, BulletTypeNormal, 0, 0, 0.55, 0.18));
                        break;
                    }
                    case 6:
                        {
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeShotgun, BulletTypeNormal, 0, 0, 0.95, 0.25));
                            
                        int wType = WeaponTypeRotate;
                        if (rand(0, 1) == 0) {
                            wType = WeaponTypeRotateR;
                        }
                            pInfo->weaponList.push_back(WeaponInfo(wType, BulletTypeMedium, 0, 0, 0.35, 0.22));
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwinLaser, BulletTypeLaser, 0, 0, 1.85, 0.55));
                        }
                    default:
                        break;
                }
                
                
                break;
            }
            case FighterTypeSuperGates:
            {
                pInfo->name = "Super Gates";
                pInfo->textureName = "e_robo2.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 64;
                pInfo->textureSrcHeight = 64;
                pInfo->showPixelHeight = 550;
                pInfo->showPixelWidth = 550;
                pInfo->collisionId = CollisionId_E_GATES;
                pInfo->power = 95;
                
                pInfo->life = pInfo->lifeMax = 12000;
                pInfo->shield = pInfo->shieldMax = 5000;
                pInfo->speed = 0.6;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeStraight, BulletTypeNormal, 0, 0, 0.4, 0.4));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeLaser, 0, 0, 1.4, 0.85));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeThreeWay, BulletTypeMedium, 0, 0, 0.5, 0.10));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeLaser, 0, 0, 1.40, 0.80));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeAK, BulletTypeMedium, 0, 0, 1.05, 0.08));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeCircle, BulletTypeMedium, 0, 0, 0.35, 0.58));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeShotgun, BulletTypeMedium, 0, 0, 0.85, 0.30));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeShotgun, BulletTypeNormal, 0, 0, 0.95, 0.25));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwinLaser, BulletTypeLaser, 0, 0, 1.85, 0.55));
                
                break;
            }
            case FighterTypeDestroyer:
            {
                pInfo->name = "Destroyer";
                pInfo->textureName = "e_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 44;
                pInfo->textureSrcWidth = 48;
                pInfo->textureSrcHeight = 48;
                pInfo->showPixelHeight = 600;
                pInfo->showPixelWidth = 600;
                pInfo->collisionId = CollisionId_E_DESTROYER;
                pInfo->power = 50;
                
                pInfo->life = pInfo->lifeMax = 1500;
                pInfo->shield = pInfo->shieldMax = 300;
                pInfo->speed = 0.60;
                
                int maxLv = 6;
                int minLv = rand(0, 0*stageProgressRatio);
                int lv = rand(minLv, maxLv*stageProgressRatio);
                switch (lv) {
                    case 0:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTriple, BulletTypeBig, 0, 0, 0.9, 0.2));
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeAK, BulletTypeMedium, 0, 0, 0.5, 0.14));
                        break;
                    case 1:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateShotgun, BulletTypeNormal, 0, 0, 1.5, 0.38));
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeLaser, 0, 0, 1.45, 0.84));
                        break;
                    case 2:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateShotgun, BulletTypeMedium, 0, 0, 1.5, 0.12));
                        break;
                    case 3:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveWay, BulletTypeMedium, 0, 0, 0.95, 0.18));
                        break;
                    case 4:
                    {
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveStraights, BulletTypeBig, 0, 0, 0.95, 0.30));
                            
                        int wType = WeaponTypeRotate;
                        if (rand(0, 1) == 0) {
                            wType = WeaponTypeRotateR;
                        }
                        pInfo->weaponList.push_back(WeaponInfo(wType, BulletTypeMedium, 0, 0, 0.35, 0.18));
                        break;
                    }
                    case 5:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateQuad, BulletTypeMedium, 0, 0, 0.85, 0.19));
                        break;
                    case 6:
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveStraights, BulletTypeBig, 0, 0, 0.95, 0.30));
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeNormal, 0, 0, 0.35, 0.10));
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeNormal, 0, 0, 0.55, 0.20));
                        pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeMedium, 0, 0, 0.85, 0.50));
                    default:
                        break;
                }
                
                break;
            }
            case FighterTypeSuperDestroyer:
            {
                pInfo->name = "Super Destroyer";
                pInfo->textureName = "e_robo1.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 44;
                pInfo->textureSrcWidth = 48;
                pInfo->textureSrcHeight = 48;
                pInfo->showPixelHeight = 600;
                pInfo->showPixelWidth = 600;
                pInfo->collisionId = CollisionId_E_DESTROYER;
                pInfo->power = 100;
                
                pInfo->life = pInfo->lifeMax = 15000;
                pInfo->shield = pInfo->shieldMax = 8000;
                pInfo->speed = 0.60;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTriple, BulletTypeBig, 0, 0, 0.9, 0.2));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeAK, BulletTypeMedium, 0, 0, 0.5, 0.14));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateShotgun, BulletTypeNormal, 0, 0, 1.5, 0.38));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeLaser, 0, 0, 1.45, 0.84));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateShotgun, BulletTypeMedium, 0, 0, 1.5, 0.12));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveWay, BulletTypeMedium, 0, 0, 0.95, 0.18));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveStraights, BulletTypeBig, 0, 0, 0.95, 0.30));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateQuad, BulletTypeMedium, 0, 0, 0.85, 0.19));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveStraights, BulletTypeBig, 0, 0, 0.95, 0.30));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeNormal, 0, 0, 0.35, 0.10));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeNormal, 0, 0, 0.55, 0.20));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeMedium, 0, 0, 0.85, 0.50));
                
                break;
            }
            case FighterTypeVesarius:
            {
                pInfo->name = "Vesalius Class";
                pInfo->textureName = "e_senkan1_4.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 204;
                pInfo->textureSrcHeight = 78;
                pInfo->showPixelWidth = 204*10;
                pInfo->showPixelHeight = 78*10;
                pInfo->collisionId = CollisionId_E_SENKAN;
                pInfo->power = 25;
                
                pInfo->life = pInfo->lifeMax = 10000;
                pInfo->shield = pInfo->shieldMax = 10000;
                pInfo->speed = 0.33;
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeNormal, 45*10, 0, 0.7, 0.08));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeLaser, BulletTypeLaser, -45*10, 0, 1.5, 0.55));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveStraights, BulletTypeBig, 90*10, 0, 0.35, 0.58));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotate, BulletTypeMedium, 0, 0, 0.3, 0.28));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateR, BulletTypeMedium, 0, 0, 0.3, 0.28));
                
                pInfo->isShip = true;
                break;
            }
            case FighterTypeTriangle:
            {
                pInfo->name = "Squad";
                pInfo->textureName = "e_boss2.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 182;
                pInfo->textureSrcHeight = 207;
                pInfo->showPixelWidth = 182*20;
                pInfo->showPixelHeight = 207*20;
                pInfo->collisionId = CollisionId_E_TRIANGLE;
                pInfo->power = 50;
                
                pInfo->life = pInfo->lifeMax = 12000;
                pInfo->speed = 0.25;
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateShotgun, BulletTypeNormal, 0, 0, 0.5, 0.55));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotate, BulletTypeMedium, 0, 0, 0.3, 0.20));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveWay, BulletTypeMedium, 0, 0, 0.4, 0.18));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateR, BulletTypeMedium, 0, 0, 0.3, 0.20));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTriple, BulletTypeBig, 0, 0, 0.3, 0.58));
                
                pInfo->isShip = true;
                break;
            }
            case FighterTypeQuad:
            {
                pInfo->name = "BigBall";
                pInfo->textureName = "e_boss3.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 177;
                pInfo->textureSrcHeight = 143;
                pInfo->showPixelWidth = 177*20;
                pInfo->showPixelHeight = 143*20;
                pInfo->collisionId = CollisionId_E_QUAD;
                pInfo->power = 80;
                
                pInfo->life = pInfo->lifeMax = 14000;
                pInfo->speed = 0.35;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeMedium, 0, 0, 0.5, 0.30));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeNormal, 0, 0, 0.7, 0.40));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeNormal, 0, 0, 0.9, 0.50));
                
                pInfo->isShip = true;
                break;
            }
            case FighterTypeColony:
            {
                pInfo->name = "Colony";
                pInfo->textureName = "colony1_s.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 130;
                pInfo->textureSrcHeight = 174;
                pInfo->showPixelWidth = 130*20;
                pInfo->showPixelHeight = 174*20;
                pInfo->collisionId = CollisionId_E_COLONY;
                pInfo->power = 100;
                
                pInfo->life = pInfo->lifeMax = 16000;
                pInfo->speed = 0.1;
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwinLaser, BulletTypeLaser, 0, 0, 1.5, 0.50));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwinLaser, BulletTypeLaser, 0, -66*20, 1.5, 0.51));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwinLaser, BulletTypeLaser, 0, 60*20, 1.5, 0.52));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwinLaser, BulletTypeLaser, 44*20, 0, 1.5, 0.53));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeTwinLaser, BulletTypeLaser, -44*20, 0, 1.5, 0.54));
                
                pInfo->isShip = true;
                break;
            }
            case FighterTypeSnake:
            {
                pInfo->name = "Snake";
                pInfo->textureName = "e_boss.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 223;
                pInfo->textureSrcHeight = 114;
                pInfo->showPixelWidth = 223*20;
                pInfo->showPixelHeight = 114*20;
                pInfo->collisionId = CollisionId_E_SNAKE;
                pInfo->power = 120;
                
                pInfo->life = pInfo->lifeMax = 20000;
                pInfo->speed = 0.15;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeFiveWay, BulletTypeBig, 0, 0, 0.8, 0.28));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeCircle, BulletTypeMedium, 0, 0, 0.2, 0.50));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotate, BulletTypeMedium, 0, 0, 0.3, 0.20));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateR, BulletTypeMedium, 0, 0, 0.3, 0.20));
                
                pInfo->isShip = true;
                break;
            }
            case FighterTypeLastBoss:
            {
                pInfo->name = "Alien's God";
                pInfo->textureName = "ship_011.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 512;
                pInfo->textureSrcHeight = 512;
                pInfo->showPixelWidth = 512*5;
                pInfo->showPixelHeight = 512*5;
                pInfo->collisionId = CollisionId_E_LASTBOSS;
                pInfo->power = 150;
                
                pInfo->life = pInfo->lifeMax = 300000;
                pInfo->speed = 0.25;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMegaLaser, BulletTypeBig, 0, 0, 1.5, 0.28));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeMedium, 0, 0, 0.6, 0.30));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeMedium, 0, 0, 0.6, 0.40));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeMad, BulletTypeNormal, 0, 0, 0.7, 0.20));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeRotateShotgun, BulletTypeNormal, 0, 0, 0.8, 0.50));
                
                
                pInfo->isShip = true;
                break;
            }
            default:
            {
                NSLog(@"ERROR: invalid fighter type%d", type);
            }
        }
        pInfo->powerPotential = ((float)status_rand(90, 110) * 0.01 * (float)pInfo->power);
        pInfo->defencePotential = ((float)status_rand(30, 70) * 0.01 * (float)pInfo->lifeMax);
        if (pInfo->shieldMax > 0) {
            pInfo->shieldPotential = ((float)status_rand(10, 30) * 0.01 * (float)pInfo->shieldMax);
        }
    }
    
    
    
}

