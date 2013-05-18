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
#include "ExplodeAnimeProcess.h"

#include <list>

namespace hg {

    ////////////////////
    // Fighter
    typedef enum FighterType
    {
        FighterTypeRobo1,
        FighterTypeRobo2,
        FighterTypeShip1,
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
        isInitialized(false),
        isShip(false),
        explodeProcessCount(0)
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
            processOwner->retain();
            
            // 種類別の初期化
            switch (type)
            {
                case FighterTypeRobo1:
                {
                    textureName = "p_robo1.png";
                    textureSrcOffset = {0, 0};
                    textureSrcSize = {16, 16};
                    setSizeByPixel(128, 128);
                    setCollisionId(CollisionId_P_ROBO1);
                    speed = v(0.6);
                    life = lifeMax = 5500;
                    Weapon* wp = new Weapon();
                    wp->init(WeaponTypeNormal, BulletTypeNormal, 0, 0);
                    weaponList.push_back(wp);
                    wp->retain();
                    break;
                }
                case FighterTypeRobo2:
                {
                    textureName = "e_robo2.png";
                    textureSrcOffset = {0, 0};
                    textureSrcSize = {64, 64};
                    setSizeByPixel(256, 256);
                    setCollisionId(CollisionId_E_ROBO2);
                    speed = v(0.3);
                    if (side == SideTypeFriend)
                    {
                    life = lifeMax = 2150;
                    }
                    else
                    {
                    life = lifeMax = 1150;
                    }
                    Weapon* wp = new Weapon();
                    wp->init(WeaponTypeNormal, BulletTypeNormal, 0, 0);
                    weaponList.push_back(wp);
                    wp->retain();
                    break;
                }
                case FighterTypeShip1:
                {
                    float sizeRatio = 10;
                    textureName = "e_senkan1_4.png";
                    textureSrcOffset = {0, 0};
                    textureSrcSize = {204, 78};
                    setSizeByPixel(204*sizeRatio, 78*sizeRatio);
                    setCollisionId(CollisionId_E_SENKAN);
                    speed = v(0.1);
                    life = lifeMax = 5000;
                    
                    {
                        Weapon* wp = new Weapon();
                        wp->init(WeaponTypeNormal, BulletTypeVulcan, 45*sizeRatio, 0);
                        weaponList.push_back(wp);
                        wp->retain();
                    }
                    
                    {
                        Weapon* wp = new Weapon();
                        wp->init(WeaponTypeNormal, BulletTypeVulcan, -45*sizeRatio, 0);
                        weaponList.push_back(wp);
                        wp->retain();
                    }
                    
                    {
                        Weapon* wp = new Weapon();
                        wp->init(WeaponTypeNormal, BulletTypeVulcan, -90*sizeRatio, 0);
                        wp->setInterval(0.1);
                        weaponList.push_back(wp);
                        wp->retain();
                    }
                    
                    
                    {
                        Weapon* wp = new Weapon();
                        wp->init(WeaponTypeNormal, BulletTypeVulcan, 0, 0);
                        wp->setInterval(0.1);
                        weaponList.push_back(wp);
                        wp->retain();
                    }
                    
                    {
                        Weapon* wp = new Weapon();
                        wp->init(WeaponTypeNormal, BulletTypeVulcan, 90*sizeRatio, 0);
                        wp->setInterval(0.1);
                        weaponList.push_back(wp);
                        wp->retain();
                    }
                    
                    isShip = true;
                    break;
                }
                default:
                    assert(0);
            }
            
            pSprite = new HGSprite();
            pSprite->setType(SPRITE_TYPE_BILLBOARD);
            pSprite->init(textureName);
            pSprite->setScale(getWidth(), getHeight());
            pSprite->setTextureRect(textureSrcOffset.x, textureSrcOffset.y, textureSrcSize.width, textureSrcSize.height);
            pSprite->retain();
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
            if (!isShip)
            {
                int spIdx = getSpriteIndex(aspectDegree + 0.5);
                int x = textureSrcSize.width * spIdx + textureSrcOffset.x;
                pSprite->setTextureRect(x - 1, textureSrcOffset.y, textureSrcSize.width, textureSrcSize.height);
            }
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
        
        inline void addLife(int life)
        {
            this->life += life;
        }
        
        inline void setMaxLife(int life)
        {
            this->lifeMax = life;
        }
        
        inline float getAspectDegree()
        {
            return aspectDegree;
        }
        
        inline void explode()
        {
            CallFunctionRepeadedlyProcess<Fighter>* cfrp = new CallFunctionRepeadedlyProcess<Fighter>();
            HGProcessOwner* hpo = new HGProcessOwner();
            cfrp->init(hpo, &Fighter::explodeProcess, this);
            HGProcessManager::sharedProcessManager()->addProcess(cfrp);
        }
        
        // call function repeatedly processから呼び出される
        inline bool explodeProcess()
        {
            explodeProcessCount++;
            if (isShip)
            {
                if (explodeProcessCount > 90)
                {
                    pSprite->setOpacity(pSprite->getOpacity()*0.9);
                }
                if (explodeProcessCount > 100)
                {
                    this->setActive(false);
                    this->getNode()->removeFromParent();
                    return true;
                }
                if (rand(0, 10) > 3)
                {
                    ExplodeAnimeProcess* eap = new ExplodeAnimeProcess();
                    HGProcessOwner* hpo = new HGProcessOwner();
                    float x = rand(getPositionX() - getWidth()/2, getPositionX() + getWidth()/2);
                    float y = rand(getPositionY() - getHeight()/2, getPositionY() + getHeight()/2);
                    Vector position(x, y, getPositionZ());
                    eap->init(hpo, position, pLayerEffect);
                    HGProcessManager::sharedProcessManager()->addProcess(eap);
                }
            }
            else
            {
                if (explodeProcessCount > 20)
                {
                    pSprite->setOpacity(pSprite->getOpacity()*0.9);
                }
                if (explodeProcessCount > 30)
                {
                    this->setActive(false);
                    this->getNode()->removeFromParent();
                    return true;
                }
                if (rand(0, 10) > 7)
                {
                    ExplodeAnimeProcess* eap = new ExplodeAnimeProcess();
                    HGProcessOwner* hpo = new HGProcessOwner();
                    float x = rand(getPositionX() - getWidth()/2, getPositionX() + getWidth()/2);
                    float y = rand(getPositionY() - getHeight()/2, getPositionY() + getHeight()/2);
                    Vector position(x, y, getPositionZ());
                    eap->init(hpo, position, pLayerEffect);
                    HGProcessManager::sharedProcessManager()->addProcess(eap);
                }
                
            }
            return false;
        }
        
        inline void fire(Fighter* pTarget)
        {
            float x = this->getPositionX();
            float y = this->getPositionY();
            float tx = pTarget->getPositionX();
            float ty = pTarget->getPositionY();
            for (WeaponList::iterator it = weaponList.begin(); it != weaponList.end(); ++it)
            {
                if (rand(0, 10) < 2)
                {
                    float wx = (*it)->getRelativeX();
                    float wy = (*it)->getRelativeY();
                    // tgの方向を向く
                    float r = atan2f(tx - (x + wx),
                                     ty - (y + wy));
                    float d = toDeg(r)-90;
                    (*it)->setAspect(d);
                }
                (*it)->fire(this, side);
            }
        }
        
        inline void fire()
        {
            for (WeaponList::iterator it = weaponList.begin(); it != weaponList.end(); ++it)
            {
                (*it)->setAspect(this->aspectDegree);
                (*it)->fire(this, side);
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
        bool isShip;
        int explodeProcessCount;
        
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
