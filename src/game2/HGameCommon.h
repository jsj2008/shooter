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
#include <stdlib.h>
#include <time.h>

#define IS_DEBUG_SHOOTER 1
#define IS_DEBUG_COLLISION 0
#define ENEMY_NUM 10
#define BULLET_NUM 100
#define ENEMY_BULLET_NUM 100
#define FIELD_SIZE 100
#define CPU_LV_MAX 100
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
    const int FighterTypeAstray = 1;
    const int FighterTypeAstray2 = 2;
    const int FighterTypeViper = 10;
    const int FighterTypeViperL = 12;
    const int FighterTypeViperC = 13;
    const int FighterTypeGatesC = 20;
    const int FighterTypeVesariusC = 30;
    const int FighterTypeRapter = 40;
    const int FighterTypeRapter2 = 41;
    const int FighterTypeStarFighter = 50;
    const int FighterTypelambda = 60;
    const int FighterTypeGloire = 70;
    const int FighterTypeFox = 80;
    const int FighterTypePegasus = 90;
    
    const int FighterTypeBall = 1000;
    
    const int FighterTypeRader = 1100;
    
    const int FighterTypeGates = 1200;
    
    const int FighterTypeDestroyer = 1300;
    
    const int FighterTypeVesarius = 3000;
    
    const int FighterTypeTriangle = 3100;
    
    const int FighterTypeQuad = 3200;
    
    const int FighterTypeColony = 3300;
    
    const int FighterTypeSnake = 3400;
    
    const int FighterTypeLastBoss = 3500;
    
    /*
    typedef enum FighterType
    {
        FighterTypeRobo1,
        FighterTypeRobo2,
        FighterTypeShip1,
        FighterTypeRobo3,
    } FighterType;*/
    
    // Bullet
    typedef enum BulletType
    {
        BulletTypeVulcan,
        BulletTypeVulcan2,
        BulletTypeVulcan3,
        BulletTypeVulcan4,
        BulletTypeVulcan5,
        BulletTypeVulcan6,
        BulletTypeVulcan7,
        BulletTypeVulcan8,
        BulletTypeNormal,
        BulletTypeNormal2,
        BulletTypeNormal3,
        BulletTypeNormal4,
        BulletTypeNormal5,
        BulletTypeNormal6,
        BulletTypeNormal7,
        BulletTypeNormal8,
        BulletTypeMedium,
        BulletTypeMedium2,
        BulletTypeMedium3,
        BulletTypeMedium4,
        BulletTypeMedium5,
        BulletTypeMedium6,
        BulletTypeMedium7,
        BulletTypeMedium8,
        BulletTypeBig,
        BulletTypeBig2,
        BulletTypeBig3,
        BulletTypeBig4,
        BulletTypeBig5,
        BulletTypeBig6,
        BulletTypeBig7,
        BulletTypeBig8,
        BulletTypeLaser,
        BulletTypeFriendVulcan,
        BulletTypeFriendNormal,
        BulletTypeFriendMedium,
        BulletTypeFriendBig,
        BulletTypeFriendLaser,
    } BulletType;
    
    // Weapon
    typedef enum WeaponType
    {
        WeaponTypeNormal,
        WeaponTypeTwin,
        WeaponTypeTriple,
        WeaponTypeShotgun,
        WeaponTypeCircle,
        WeaponTypeCircleRotate,
        WeaponTypeAK,
        WeaponTypeLaser,
        WeaponTypeTwinLaser,
        WeaponTypeGatring, // 没
        WeaponTypeGatringLaser, // 没
        WeaponTypeRotate,
        WeaponTypeRotateR,
        WeaponTypeRotateQuad,
        WeaponTypeMad,
        WeaponTypeThreeWay,
        WeaponTypeFiveWay,
        WeaponTypeRotateShotgun,
        WeaponTypeFiveStraights,
        WeaponTypeStraight,
        WeaponTypeMegaLaser,
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
                case BulletTypeVulcan:
                    ratio = 0.5;
                    bulletType += rand(0,7);
                    break;
                case BulletTypeNormal:
                    ratio = 1;
                    bulletType += rand(0,7);
                    break;
                case BulletTypeMedium:
                    ratio = 1.5;
                    bulletType += rand(0,7);
                    break;
                case BulletTypeBig:
                    ratio = 3;
                    bulletType += rand(0,7);
                    break;
                case BulletTypeLaser:
                    ratio = 2;
                    break;
                case BulletTypeFriendVulcan:
                    ratio = 0.5;
                    break;
                case BulletTypeFriendNormal:
                    ratio = 1;
                    break;
                case BulletTypeFriendMedium:
                    ratio = 1.5;
                    break;
                case BulletTypeFriendBig:
                    ratio = 3;
                    break;
                case BulletTypeFriendLaser:
                    ratio = 2;
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
        bool isRetreat = false;
        int earnedMoney = 0;
        int finalIncome = 0;
        int myShot = 0;
        int myHit = 0;
        int allShot = 0;
        int allHit = 0;
        int allShotPower = 0;
        int allShotMoney = 0;
        int enemyShot = 0;
        int enemyHit = 0;
        int killedFriend = 0;
        int killedEnemy = 0;
        int killedValue = 0;
        int deadValue = 0;
        int battleScore = 0;
    } BattleResult;
    
    typedef enum CollisionId
    {
        CollisionIdStart,
        CollisionIdNone,
        CollisionId_BulletNormal,
        CollisionId_BulletMedium,
        CollisionId_BulletBig,
        CollisionId_BulletVulcan,
        CollisionId_BulletLaser,
        CollisionId_P_ROBO1,
        CollisionId_E_SENKAN,
        CollisionId_P_GATES,
        CollisionId_P_VIPER,
        CollisionId_E_GATES,
        CollisionId_E_RADER,
        CollisionId_E_BALL,
        CollisionId_E_DESTROYER,
        CollisionId_P_RAPTER,
        CollisionId_P_LAMBDAS,
        CollisionId_P_FOX,
        CollisionId_P_PEGASUS,
        CollisionId_E_TRIANGLE,
        CollisionId_E_QUAD,
        CollisionId_E_COLONY,
        CollisionId_E_SNAKE,
        CollisionId_E_LASTBOSS,
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
        powerPotential(0),
        defencePotential(0),
        shieldPotential(0),
        seed(1331124),
        isStatusChanged(true),
        cachedCost(0)
        {
            seed = std::rand()%INT32_MAX;
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
        int shieldPotential;
        int seed;
        bool isStatusChanged;
        int cachedCost;
        int cachedDamageExpPerLife;
    } FighterInfo;
    
    typedef std::vector<FighterInfo*> FighterList;
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
