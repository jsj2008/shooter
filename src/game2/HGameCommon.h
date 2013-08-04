//
//  HDefine.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/03.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef Shooter_HDefine_h
#define Shooter_HDefine_h

#include "HGameEngine.h"
#include "HActorList.h"
#include "CellManager.h"
#include <deque>

#define IS_DEBUG_COLLISION 0
#define ENEMY_NUM 10
#define BULLET_NUM 100
#define ENEMY_BULLET_NUM 100
#define FIELD_SIZE 150
#define ZPOS 0
#define BACKGROUND_SCALE 2000
#define STAGE_SCALE 100
#define PIXEL_SCALE 0.01
#define PXL2REAL(var) ((var)*(PIXEL_SCALE))
#define SHILD_SIZE_GAP (50*(PIXEL_SCALE))

namespace hg {
    class HGNode;
    class Bullet;
    class Fighter;
    
    // typedef
    typedef enum SideType
    {
        SideTypeEnemy,
        SideTypeFriend,
    } SideType;
    
    // Fighter
    typedef enum FighterType
    {
        FighterTypeRobo1,
        FighterTypeRobo2,
        FighterTypeShip1,
    } FighterType;
    
    // Bullet
    typedef enum BulletType
    {
        BulletTypeNormal,
        BulletTypeMagic,
        BulletTypeVulcan,
    } BulletType;
    
    // Weapon
    typedef enum WeaponType
    {
        WeaponTypeNormal,
    } WeaponType;
    
    
    typedef struct WeaponInfo
    {
        WeaponInfo(
            int _weaponType,
            int _bulletType,
            double _x,
            double _y,
            float _speed,
            float _fireInterval):
        bulletType(_bulletType),
        weaponType(_weaponType),
        x(_x),
        y(_y),
        speed(_speed),
        bulletPower(0),
        fireInterval(_fireInterval)
        {
            float ratio = 1;
            switch (_bulletType)
            {
                case BulletTypeNormal:
                    break;
                case BulletTypeMagic:
                    ratio = 3;
                    break;
                case BulletTypeVulcan:
                    ratio = 0.5;
                    break;
            }
            bulletPower = ratio;
        }
        int bulletType;
        int weaponType;
        float speed;
        float fireInterval;
        float bulletPower;
        double x;
        double y;
        float getDamagePerSecond(int power)
        {
            return (float)ceil(power*bulletPower)/fireInterval;
        }
    } WeaponInfo;
    
    typedef std::vector<WeaponInfo> WeaponInfoList;
    
    typedef struct BattleResult
    {
        bool isWin = false;
        int earnedMoney = 0;
        int yourShot = 0;
        int allShotMoney = 0;
        int killedFriend = 0;
        int killedEnemy = 0;
    } BattleResult;
    
    typedef enum CollisionId
    {
        CollisionIdStart,
        CollisionIdNone,
        CollisionId_BulletNormal,
        CollisionId_BulletVulcan,
        CollisionId_P_ROBO1,
        CollisionId_E_SENKAN,
        CollisionId_E_ROBO2,
        CollisionIdEnd,
    } CollisionId;
    
    typedef struct FighterInfo
    {
        FighterInfo():
        fighterType(0),
        level(1),
        life(0),
        lifeMax(0),
        shield(0),
        shieldMax(0),
        shieldHeal(0),
        speed(0),
        power(1),
        exp(0),
        expNext(300),
        isReady(false),
        isPlayer(false),
        isOnBattleGround(0),
        textureName(""),
        textureSrcOffsetX(0),
        textureSrcOffsetY(0),
        textureSrcWidth(0),
        textureSrcHeight(0),
        showPixelWidth(0),
        showPixelHeight(0),
        collisionId(0),
        isShip(0),
        dieCnt(0),
        killCnt(0),
        totalKill(0),
        totalDie(0),
        cpu_lv(0),
        tmpExp(0),
        powerPotential(100),
        defencePotential(100),
        seed(1331124),
        isStatusChanged(true),
        cachedCost(0)
        {
        }
        int fighterType;
        int level;
        int power;
        int life;
        int lifeMax;
        int shield;
        int shieldMax;
        int shieldHeal;
        long tmpExp;
        long exp;
        long expNext;
        bool isReady;
        float speed;
        int isOnBattleGround;
        WeaponInfoList weaponList;
        bool isPlayer;
        std::string name;
        // innner data
        std::string textureName;
        double textureSrcOffsetX;
        double textureSrcOffsetY;
        double textureSrcWidth;
        double textureSrcHeight;
        double showPixelWidth;
        double showPixelHeight;
        int collisionId;
        bool isShip;
        int killInStage;
        int dieCnt;
        int killCnt;
        int totalKill;
        int totalDie;
        int cpu_lv;
        int powerPotential;
        int defencePotential;
        int seed;
        bool isStatusChanged;
        int cachedCost;
        int cachedDamageExpPerLife;
    } FighterInfo;
    
    typedef std::vector<FighterInfo*> SpawnGroup;
    typedef std::deque<SpawnGroup> SpawnData;
    typedef std::vector<FighterInfo*> FriendData;
    
    typedef struct KeyInfo
    {
        bool isFire;
        int degree;
        float power;
        bool isTouchBegan = false;
        bool isTouchEnd = false;
        bool shouldDeployFriend = false;
        bool shouldCollectFriend = false;
    } KeyInfo;
    
    // global
    extern HGNode* pLayerBullet;
    extern HGNode* pLayerFriend;
    extern HGNode* pLayerEffect;
    
    extern KeyInfo keyInfo;
    extern HGSize sizeOfField;
    extern HGPoint pointOfFieldCenter;
    
    extern ActorList<Bullet> friendBulletList;
    extern ActorList<Bullet> enemyBulletList;
    extern ActorList<Fighter> friendFighterList;
    extern ActorList<Fighter> enemyFighterList;
    
    extern CellManager<Fighter> enemyCellManager;
    extern CellManager<Fighter> friendCellManager;
    
    extern BattleResult battleResult;
    
    
    
}


#endif
