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
    
    typedef struct WeaponInfo
    {
        int bulletType;
        int weaponType;
        int power;
    } WeaponInfo;
    
    typedef std::vector<WeaponInfo> WeaponInfoList;
    
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
        isPlayer(false)
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
        WeaponInfoList weaponList;
        bool isPlayer;
        std::string name;
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
    
}


#endif
