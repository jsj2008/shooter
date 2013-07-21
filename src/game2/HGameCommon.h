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
    
    typedef struct WeaponInfo
    {
        WeaponInfo(int _bulletType, int _weaponType, int _power, double _x, double _y):
        bulletType(_bulletType),
        weaponType(_weaponType),
        power(_power),
        x(_x),
        y(_y)
        {}
        int bulletType;
        int weaponType;
        int power;
        double x;
        double y;
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
        expNext(0),
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
        isShip(0)
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
        long exp;
        long expNext;
        bool isReady;
        float speed;
        int isOnBattleGround;
        WeaponInfoList weaponList;
        bool isPlayer;
        std::string name;
        int cost;
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
    
    inline void setDefaultInfo(FighterInfo* pInfo)
    {
        int type = pInfo->fighterType;
        
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
                
                pInfo->life = pInfo->lifeMax = 1000;
                pInfo->shield = pInfo->shieldMax = 0;
                pInfo->speed = 0.1;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeMagic, 100, 0, 0));
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
                
                pInfo->life = pInfo->lifeMax = 1000;
                pInfo->shield = pInfo->shieldMax = 0;
                pInfo->speed = 0.13;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeNormal, 50, 0, 0));
                
                break;
            }
            case FighterTypeShip1:
            {
                pInfo->textureName = "e_senkan1_4.png";
                pInfo->textureSrcOffsetX = 0;
                pInfo->textureSrcOffsetY = 0;
                pInfo->textureSrcWidth = 204;
                pInfo->textureSrcHeight = 78;
                pInfo->showPixelHeight = 204*10;
                pInfo->showPixelWidth = 78*10;
                pInfo->collisionId = CollisionId_E_SENKAN;
                
                pInfo->life = pInfo->lifeMax = 10000;
                pInfo->shield = pInfo->shieldMax = 10000;
                pInfo->speed = 0.13;
                pInfo->shieldHeal = 1.5;
                
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeVulcan, 50, 45, 0));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeVulcan, 50, -45, 0));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeVulcan, 50, -90, 0));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeVulcan, 50, 90, 0));
                pInfo->weaponList.push_back(WeaponInfo(WeaponTypeNormal, BulletTypeVulcan, 50, 0, 0));
                
                pInfo->isShip = true;
                break;
            }
            default:
                assert(0);
        }
    }
    
}


#endif
