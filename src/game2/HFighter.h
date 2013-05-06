//
//  HFighter.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/03.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__HFighter__
#define __Shooter__HFighter__

#include <iostream>
#include "HGameCommon.h"
#include "HWeapon.h"
#include "HCollision.h"

#include <list>

namespace hg {

    ////////////////////
    // Fighter
    typedef enum FighterType
    {
        FighterTypeRobo1,
        FighterTypeRobo2,
    } FighterType;
    
    static int SPRITE_INDEX_TABLE[359] = {};
    typedef std::list<Weapon*> WeaponList;
    class Fighter : public Actor
    {
    public:
        typedef Actor base;
        
        Fighter():
        base(),
        textureSrcOffset(0,0),
        textureSrcSize(0,0),
        aspectDegree(0),
        speed(0),
        textureName(""),
        life(0),
        lifeMax(0),
        processOwner(NULL),
        side(SideTypeEnemy),
        isInitialized(false)
        {
        }
        
        ~Fighter()
        {
            for (WeaponList::iterator it = weaponList.begin(); it != weaponList.end(); ++it)
            {
                (*it)->release();
            }
            weaponList.clear();
            pSprite->release();
            processOwner->release();
        }
        inline void setActive(bool isActive)
        {
            base::setActive(isActive);
        }
        
        inline void init(HGNode* layerParent, SideType side, FighterType type)
        {
            base::init(layerParent);
            this->side = side;
            this->type = type;
            processOwner = new HGProcessOwner();
            
            // 種類別の初期化
            switch (type)
            {
                case FighterTypeRobo1:
                {
                    textureName = "p_robo1.png";
                    textureSrcOffset.x = 0;
                    textureSrcOffset.y = 0;
                    textureSrcSize.width = 16;
                    textureSrcSize.height = 16;
                    setSizeByPixel(128, 128);
                    setCollisionId(2);
                    speed = v(0.6);
                    life = lifeMax = 100;
                    Weapon* wp = new Weapon();
                    wp->init(WEAPON_TYPE_NORMAL, BULLET_TYPE_NORMAL , 0, 0);
                    weaponList.push_back(wp);
                    break;
                }
                case FighterTypeRobo2:
                {
                    textureName = "e_robo2.png";
                    textureSrcOffset.x = 0;
                    textureSrcOffset.y = 0;
                    textureSrcSize.width = 64;
                    textureSrcSize.height = 64;
                    setSizeByPixel(256, 256);
                    setCollisionId(4);
                    speed = v(0.3);
                    life = lifeMax = 50;
                    Weapon* wp = new Weapon();
                    wp->init(WEAPON_TYPE_NORMAL, BULLET_TYPE_NORMAL , 0, 0);
                    weaponList.push_back(wp);
                    break;
                }
                default:
                    assert(0);
            }
            
            pSprite = new HGSprite();
            pSprite->setType(SPRITE_TYPE_BILLBOARD);
            pSprite->init(textureName);
            pSprite->setScale(getWidth(), getHeight());
            getNode()->addChild(pSprite);
            
            setAspectDegree(0);
            
#if IS_DEBUG_COLLISION
            CollisionManager::sharedCollisionManager()->addDebugMark(getCollisionId(), getNode(), getWidth(), getHeight());
#endif
            
            // テーブル初期化
            static bool isTableInitialized = false;
            if (!isTableInitialized)
            {
                int index = 0;
                for (int i = 0; i < 360; i++)
                {
                    index = 0;
                    if (i >= 338 || i <= 23) {
                        index = 2;
                    } else if (i >= 23 && i <= 68) {
                        index = 3;
                    } else if (i >= 68 && i <= 113) {
                        index = 4;
                    } else if (i >= 113 && i <= 158) {
                        index = 5;
                    } else if (i >= 158 && i <= 203) {
                        index = 6;
                    } else if (i >= 203 && i <= 248) {
                        index = 7;
                    } else if (i >= 248 && i <= 293) {
                        index = 0;
                    } else if (i >= 293 && i <= 338) {
                        index = 1;
                    }
                    SPRITE_INDEX_TABLE[i] = index;
                }
            }
            isInitialized = true;
        }
        inline void setAspectDegree(float degree)
        {
            aspectDegree = degree;
            int spIdx = getSpriteIndex(aspectDegree + 0.5);
            int x = textureSrcSize.width * spIdx + textureSrcOffset.x;
            pSprite->setTextureRect(x - 1, textureSrcOffset.y, textureSrcSize.width, textureSrcSize.height);
        }
        inline SideType getSide()
        {
            return side;
        }
        
        inline int getLife()
        {
            return life;
        }
        
        inline void setLife(int life)
        {
            this->life = life;
        }
        
        inline void setMaxLife(int life)
        {
            this->lifeMax = life;
        }
        
        inline float getAspectDegree()
        {
            return aspectDegree;
        }
        
        inline void fire()
        {
            for (WeaponList::iterator it = weaponList.begin(); it != weaponList.end(); ++it)
            {
                (*it)->fire(this, this->aspectDegree, side);
            }
        }
        
        inline HGProcessOwner* getProcessOwner()
        {
            return this->processOwner;
        }
        
        inline float getSpeed()
        {
            return speed;
        }
    private:
        float speed;
        float aspectDegree;
        int life;
        int lifeMax;
        HGPoint textureSrcOffset;
        HGSize textureSrcSize;
        std::string textureName;
        WeaponList weaponList;
        HGSprite* pSprite;
        SideType side;
        FighterType type;
        HGProcessOwner* processOwner;
        bool isInitialized;
        
        int getSpriteIndex(int i)
        {
            while (i < 0)
            {
                i += 360;
            }
            i = i % 360;
            return SPRITE_INDEX_TABLE[i];
        }
        
    };
}
#endif /* defined(__Shooter__HFighter__) */
