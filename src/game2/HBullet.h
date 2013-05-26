//
//  HBullet.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/03.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__HBullet__
#define __Shooter__HBullet__

#include <iostream>
#include "HActor.h"
#include "HGameCommon.h"
#include "CallFunctionRepeatedlyProcess.h"

namespace hg {
    
    ////////////////////
    // Bullet
    typedef enum BulletType
    {
        BulletTypeNormal,
        BulletTypeMagic,
        BulletTypeVulcan,
    } BulletType;
    
    class Bullet : public Actor
    {
        typedef Actor base;
    public:
        Bullet():
        base()
        {
            pMoveOwner = new HGProcessOwner();
            pMoveOwner->retain();
        }
        ~Bullet()
        {
            pOwner->release();
            pMoveOwner->release();
            //Actor::~Actor();
        }
        inline void init(int type, float speed, float distance, int power, Actor* pOwner, float x, float y, float directionDegree, SideType side)
        {
            assert(pOwner);
            base::init(pLayerBullet);
            this->power = power;
            this->pOwner = pOwner;
            pOwner->retain();
            this->type = type;
            this->directionDegree = directionDegree;
            this->directionRadian = toRad(directionDegree);
            this->side = side;
            this->setPosition(x, y);
            this->life = distance/speed;
            
            vx = cos(directionRadian) * speed;
            vy = sin(directionRadian) * speed * -1;
            
            // move process
            CallFunctionRepeadedlyProcess<Bullet>* p = new CallFunctionRepeadedlyProcess<Bullet>();
            p->init(pMoveOwner, &Bullet::move, this);
            HGProcessManager::sharedProcessManager()->addProcess(p);
            
            static Color sideColor = {0.2, 0.2, 1.0, 0.5};
            static Color coreColor = {0.2, 0.2, 1.0, 0.5};
            if (side == SideTypeFriend)
            {
                sideColor = {0.7, 0.7, 1.0, 0.5};
                coreColor = {1,1,1,1};
            }
            else
            {
                sideColor = {1.0, 0.7, 0.7, 0.5};
                coreColor = {1,1,1,1};
            }
            
            switch (type) {
                case BulletTypeMagic:
                {
                    setSizeByPixel(560, 560);
                    setCollisionId(CollisionId_BulletNormal);
                    
                    // core
                    AlphaMapSprite* pSpr = new AlphaMapSprite();
                    pSpr->init("sparkle.png", {0.95, 0.95, 1.0, 1.0});
                    pSpr->setScale(getWidth()*2, getHeight()*2);
                    getNode()->addChild(pSpr);
                    {
                        // 縮小
                        HGProcessOwner* po = new HGProcessOwner();
                        ChangeScaleProcess* ssp2 = new ChangeScaleProcess();
                        ssp2->init(po, pSpr, getWidth()*1.1, getHeight()*1.1, v(15));
                        ssp2->setEaseFunc(&ease_out);
                        HGProcessManager::sharedProcessManager()->addProcess(ssp2);
                    }
                    
                    // effect
                    {
                        // 回転
                        HGProcessOwner* po = new HGProcessOwner();
                        RotateNodeProcess* rnp = new RotateNodeProcess();
                        Vector r = Vector(0,0,1200);
                        rnp->init(po, pSpr, r, v(80));
                        rnp->setEaseFunc(&ease_in);
                        HGProcessManager::sharedProcessManager()->addProcess(rnp);
                    }
                    
                    break;
                }
                case BulletTypeNormal:
                {
                    setSizeByPixel(160, 160);
                    setCollisionId(CollisionId_BulletNormal);
                    
                    // core
                    AlphaMapSprite* pSpr = new AlphaMapSprite();
                    pSpr->init("divine.png", coreColor);
                    pSpr->setScale(getWidth()*1.1, getHeight()*1.1);
                    getNode()->addChild(pSpr);
                    
                    // light
                    AlphaMapSprite* pSprGlow = new AlphaMapSprite();
                    pSprGlow->init("star.png", sideColor);
                    pSprGlow->setScale(getWidth()*3, getHeight()*3);
                    getNode()->addChild(pSprGlow);
                    
                    break;
                }
                case BulletTypeVulcan:
                {
                    setSizeByPixel(60, 60);
                    setCollisionId(CollisionId_BulletVulcan);
                    
                    // core
                    AlphaMapSprite* pSpr = new AlphaMapSprite();
                    pSpr->init("divine.png", coreColor);
                    pSpr->setScale(getWidth()*1.1, getHeight()*1.1);
                    getNode()->addChild(pSpr);
                    
                    // light
                    AlphaMapSprite* pSprGlow = new AlphaMapSprite();
                    pSprGlow->init("star.png", sideColor);
                    pSprGlow->setScale(getWidth()*3, getHeight()*3);
                    getNode()->addChild(pSprGlow);
                    
                    break;
                }
                default:
                    assert(0);
                    break;
            }
#if IS_DEBUG_COLLISION
            CollisionManager::sharedCollisionManager()->addDebugMark(getCollisionId(), getNode(), getWidth(), getHeight());
#endif
        }
        inline int getPower()
        {
            return power;
        }
        inline Actor* getOwner()
        {
            return pOwner;
        }
        inline SideType getSide()
        {
            return this->side;
        }
        bool move()
        {
            if (!this->isActive())
            {
                return true;
            }
            HGNode* n = this->getNode();
            n->addPosition(vx, vy);
            
            --life;
            if (life <= 5)
            {
                this->getNode()->setScale(this->getNode()->getScaleX() * 0.5, this->getNode()->getScaleY() * 0.5);
                if (life <= 0)
                {
                    this->setActive(false);
                }
            }
            if (!this->isActive())
            {
                return true;
            }
            
            return false;
        }
        void setActive(bool isActive)
        {
            if (!isActive)
            {
                this->getNode()->removeFromParent();
            }
            base::setActive(isActive);
        }
    private:
        int power;
        float speed;
        int type;
        Actor* pOwner;
        HGProcessOwner* pMoveOwner;
        SideType side;
        int life;
        
        float vx;
        float vy;
        float directionDegree;
        float directionRadian;
    };
}

#endif /* defined(__Shooter__HBullet__) */
