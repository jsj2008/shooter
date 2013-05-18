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

#define IS_DEBUG_COLLISION 0
#define ENEMY_NUM 10
#define BULLET_NUM 100
#define ENEMY_BULLET_NUM 100
#define FIELD_SIZE 100
#define ZPOS 0
#define BACKGROUND_SCALE 2000
#define STAGE_SCALE 100
#define PIXEL_SCALE 0.01
#define PXL2REAL(var) ((var)*(PIXEL_SCALE))

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
    
    typedef struct KeyInfo
    {
        bool isFire;
        int degree;
        float power;
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
    
}


#endif
