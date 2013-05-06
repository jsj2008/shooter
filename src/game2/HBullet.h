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
        BULLET_TYPE_NORMAL,
    } BulletType;
    class Bullet : public Actor
    {
        typedef Actor base;
    public:
        Bullet():
        base()
        {
            pMoveOwner = new HGProcessOwner();
        }
        ~Bullet()
        {
            pOwner->release();
            pMoveOwner->release();
            //Actor::~Actor();
        }
        inline void init(BulletType type, float speed, int power, Actor* pOwner, float x, float y, float directionDegree, SideType side)
        {
            assert(pOwner);
            base::init(pLayerPlayer);
            this->power = power;
            this->pOwner = pOwner;
            pOwner->retain();
            this->type = type;
            this->directionDegree = directionDegree;
            this->directionRadian = toRad(directionDegree);
            this->side = side;
            this->setPosition(x, y);
            
            vx = cos(directionRadian) * speed;
            vy = sin(directionRadian) * speed * -1;
            
            // move process
            CallFunctionRepeadedlyProcess<Bullet>* p = new CallFunctionRepeadedlyProcess<Bullet>();
            p->init(pMoveOwner, &Bullet::move, this);
            HGProcessManager::sharedProcessManager()->addPrcoess(p);
            p->release();
            
            switch (type) {
                case BULLET_TYPE_NORMAL:
                {
                    setSizeByPixel(80, 80);
                    setCollisionId(1);
                    this->life = v(20);
                    
                    // core
                     HGSprite* pSprite = new HGSprite();
                    pSprite->setType(SPRITE_TYPE_BILLBOARD);
                    pSprite->init("divine.png");
                    pSprite->setScale(getWidth()*1.1, getHeight()*1.1);
                    pSprite->shouldRenderAsAlphaMap(true);
                    pSprite->setColor({1,1,1,1});
                    pSprite->setBlendFunc(GL_ALPHA, GL_ALPHA);
                    getNode()->addChild(pSprite);
                    pSprite->release();
                    
                    // light
                    HGSprite* pSprGlow = new HGSprite();
                    pSprGlow->setType(SPRITE_TYPE_BILLBOARD);
                    pSprGlow->init("star.png");
                    
                    if (side == SideTypeFriend)
                    {
                        pSprGlow->setColor({0.7, 0.7, 1.0, 0.5});
                    }
                    else
                    {
                        pSprGlow->setColor({1.0, 0.7, 0.7, 0.5});
                    }
                    pSprGlow->setScale(getWidth()*3, getHeight()*3);
                    pSprGlow->shouldRenderAsAlphaMap(true);
                    pSprGlow->setBlendFunc(GL_ALPHA, GL_ALPHA);
                    getNode()->addChild(pSprGlow);
                    pSprGlow->release();
                    break;
                }
                default:
                    break;
            }
#if IS_DEBUG_COLLISION
            CollisionManager::sharedCollisionManager()->addDebugMark(getCollisionId(), getNode(), getWidth(), getHeight());
#endif
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
            HGNode* n = this->getNode();
            n->addPosition(vx, vy);
            
            --life;
            if (life <= 10)
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
        BulletType type;
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
