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
    class Fighter;
    extern void retainFighter(Fighter* fighter);
    extern void releaseFighter(Fighter* fighter);
    
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
            releaseFighter(pOwner);
            pMoveOwner->release();
            //Actor::~Actor();
        }
        inline void init(int type, float speed, float distance, int power, Fighter* pOwner, float x, float y, float directionDegree, SideType side)
        {
            assert(pOwner);
            base::init(pLayerBullet);
            this->power = power;
            this->pOwner = pOwner;
            retainFighter(pOwner);
            this->type = type;
            this->directionDegree = directionDegree;
            this->directionRadian = toRad(directionDegree);
            this->side = side;
            this->setPosition(x, y);
            this->life = this->lifeMax = distance;
            
            vx = cos(directionRadian) * speed;
            vy = sin(directionRadian) * speed * -1;
            
            // move process
            CallFunctionRepeadedlyProcess<Bullet>* p = new CallFunctionRepeadedlyProcess<Bullet>();
            p->init(pMoveOwner, &Bullet::move, this);
            HGProcessManager::sharedProcessManager()->addProcess(p);
            
            /*
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
            }*/
            
            switch (type) {
                case BulletTypeVulcan:
                case BulletTypeVulcan2:
                case BulletTypeVulcan3:
                case BulletTypeVulcan4:
                case BulletTypeVulcan5:
                case BulletTypeVulcan6:
                case BulletTypeVulcan7:
                case BulletTypeVulcan8:
                {
                    setSizeByPixel(60, 60);
                    setCollisionId(CollisionId_BulletVulcan);
                    
                    // core
                    HGSprite* pSprBom = new HGSprite();
                    pSprBom->init("shotpack.png");
                    getNode()->addChild(pSprBom);
                    pSprBom->setScale(getWidth(), getHeight());
                    
                    switch (type) {
                        case BulletTypeVulcan:
                            pSprBom->setTextureRect(0, 20, 20, 20);
                            break;
                        case BulletTypeVulcan2:
                            pSprBom->setTextureRect(0, 84, 20, 20);
                            break;
                        case BulletTypeVulcan3:
                            pSprBom->setTextureRect(0, 148, 20, 20);
                            break;
                        case BulletTypeVulcan4:
                            pSprBom->setTextureRect(0, 212, 20, 20);
                            break;
                        case BulletTypeVulcan5:
                            pSprBom->setTextureRect(0, 276, 20, 20);
                            break;
                        case BulletTypeVulcan6:
                            pSprBom->setTextureRect(0, 340, 20, 20);
                            break;
                        case BulletTypeVulcan7:
                            pSprBom->setTextureRect(0, 404, 20, 20);
                            break;
                        case BulletTypeVulcan8:
                            pSprBom->setTextureRect(0, 468, 20, 20);
                            break;
                    }
                    
                    break;
                }
                case BulletTypeNormal:
                case BulletTypeNormal2:
                case BulletTypeNormal3:
                case BulletTypeNormal4:
                case BulletTypeNormal5:
                case BulletTypeNormal6:
                case BulletTypeNormal7:
                case BulletTypeNormal8:
                {
                    setSizeByPixel(180, 180);
                    setCollisionId(CollisionId_BulletNormal);
                    
                    // core
                    HGSprite* pSprBom = new HGSprite();
                    pSprBom->init("shotpack.png");
                    getNode()->addChild(pSprBom);
                    pSprBom->setScale(getWidth(), getHeight());
                    
                    switch (type) {
                        case BulletTypeNormal:
                            pSprBom->setTextureRect(0, 20, 20, 20);
                            break;
                        case BulletTypeNormal2:
                            pSprBom->setTextureRect(0, 84, 20, 20);
                            break;
                        case BulletTypeNormal3:
                            pSprBom->setTextureRect(0, 148, 20, 20);
                            break;
                        case BulletTypeNormal4:
                            pSprBom->setTextureRect(0, 212, 20, 20);
                            break;
                        case BulletTypeNormal5:
                            pSprBom->setTextureRect(0, 276, 20, 20);
                            break;
                        case BulletTypeNormal6:
                            pSprBom->setTextureRect(0, 340, 20, 20);
                            break;
                        case BulletTypeNormal7:
                            pSprBom->setTextureRect(0, 404, 20, 20);
                            break;
                        case BulletTypeNormal8:
                            pSprBom->setTextureRect(0, 468, 20, 20);
                            break;
                    }
                    
                    break;
                }
                case BulletTypeMedium:
                case BulletTypeMedium2:
                case BulletTypeMedium3:
                case BulletTypeMedium4:
                case BulletTypeMedium5:
                case BulletTypeMedium6:
                case BulletTypeMedium7:
                case BulletTypeMedium8:
                {
                    setSizeByPixel(250, 250);
                    setCollisionId(CollisionId_BulletMedium);
                    
                    // core
                    HGSprite* pSprBom = new HGSprite();
                    pSprBom->init("shotpack.png");
                    getNode()->addChild(pSprBom);
                    pSprBom->setScale(getWidth(), getHeight());
                    
                    switch (type) {
                        case BulletTypeMedium:
                            pSprBom->setTextureRect(257, 0, 64, 64);
                            break;
                        case BulletTypeMedium2:
                            pSprBom->setTextureRect(257, 64, 64, 64);
                            break;
                        case BulletTypeMedium3:
                            pSprBom->setTextureRect(257, 128, 64, 64);
                            break;
                        case BulletTypeMedium4:
                            pSprBom->setTextureRect(257, 192, 64, 64);
                            break;
                        case BulletTypeMedium5:
                            pSprBom->setTextureRect(257, 256, 64, 64);
                            break;
                        case BulletTypeMedium6:
                            pSprBom->setTextureRect(257, 320, 64, 64);
                            break;
                        case BulletTypeMedium7:
                            pSprBom->setTextureRect(257, 384, 64, 64);
                            break;
                        case BulletTypeMedium8:
                            pSprBom->setTextureRect(257, 448, 64, 64);
                            break;
                    }
                    
                    break;
                }
                case BulletTypeBig:
                case BulletTypeBig2:
                case BulletTypeBig3:
                case BulletTypeBig4:
                case BulletTypeBig5:
                case BulletTypeBig6:
                case BulletTypeBig7:
                case BulletTypeBig8:
                {
                    setSizeByPixel(400, 400);
                    setCollisionId(CollisionId_BulletBig);
                    
                    // core
                    AlphaMapSprite* pSpr = new AlphaMapSprite();
                    pSpr->init("sparkle.png", {1.00, 0.5, 0.5, 1.0});
                    pSpr->setScale(getWidth()*5, getHeight()*5);
                    getNode()->addChild(pSpr);
                    
                    break;
                }
                case BulletTypeLaser:
                {
                    setSizeByPixel(140, 140);
                    setCollisionId(CollisionId_BulletLaser);
                    
                    // light
                    AlphaMapSprite* pSpr = new AlphaMapSprite();
                    pSpr->init("corona.png", {1.00, 0.40, 0.4, 1.0});
                    pSpr->setScale(getWidth()*2.5, getHeight()*2.5);
                    getNode()->addChild(pSpr);
                    break;
                }
                case BulletTypeFriendVulcan:
                {
                    setSizeByPixel(60, 60);
                    setCollisionId(CollisionId_BulletVulcan);
                    
                    // core
                    HGSprite* pSprBom = new HGSprite();
                    pSprBom->init("shot1.png");
                    getNode()->addChild(pSprBom);
                    pSprBom->setScale(getWidth(), getHeight());
                    
                    /*
                    // light
                    AlphaMapSprite* pSpr = new AlphaMapSprite();
                    pSpr->init("sparkle.png", {9.00, 9.00, 1.0, 1.0});
                    pSpr->setScale(getWidth()*5, getHeight()*5);
                    getNode()->addChild(pSpr);
                     */
                    
                    break;
                }
                case BulletTypeFriendNormal:
                {
                    setSizeByPixel(180, 180);
                    setCollisionId(CollisionId_BulletNormal);
                    
                    // core
                    HGSprite* pSprBom = new HGSprite();
                    pSprBom->init("shot1.png");
                    getNode()->addChild(pSprBom);
                    pSprBom->setScale(getWidth(), getHeight());
                    
                    break;
                }
                case BulletTypeFriendMedium:
                {
                    setSizeByPixel(250, 250);
                    setCollisionId(CollisionId_BulletMedium);
                    
                    // core
                    HGSprite* pSprBom = new HGSprite();
                    pSprBom->init("shot1.png");
                    getNode()->addChild(pSprBom);
                    pSprBom->setScale(getWidth(), getHeight());
                    
                    break;
                }
                case BulletTypeFriendBig:
                {
                    setSizeByPixel(400, 400);
                    setCollisionId(CollisionId_BulletBig);
                    
                    // core
                    AlphaMapSprite* pSpr = new AlphaMapSprite();
                    pSpr->init("sparkle.png", {0.50, 0.50, 1.0, 1.0});
                    pSpr->setScale(getWidth()*5, getHeight()*5);
                    getNode()->addChild(pSpr);
                    
                    break;
                }
                case BulletTypeFriendLaser:
                {
                    setSizeByPixel(140, 140);
                    setCollisionId(CollisionId_BulletLaser);
                    
                    // light
                    AlphaMapSprite* pSpr = new AlphaMapSprite();
                    pSpr->init("corona.png", {0.40, 0.40, 1.0, 1.0});
                    pSpr->setScale(getWidth()*2.5, getHeight()*2.5);
                    getNode()->addChild(pSpr);
                    
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
            /*
            life = MAX(life, 0);
            return power * life/lifeMax;*/
            return power;
        }
        inline Fighter* getOwner()
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
            this->life--;
            
            float x = getPositionX();
            float y = getPositionY();
            if (x < -10 || x > FIELD_SIZE + 10
                || y < - 10 || y > FIELD_SIZE + 10) {
                this->setActive(false);
            }
            
            /*
            --life;
            if (life <= 5)
            {
                this->getNode()->setScale(this->getNode()->getScaleX() * 0.5, this->getNode()->getScaleY() * 0.5);
                if (life <= 0)
                {
                    this->setActive(false);
                }
            }*/
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
        Fighter* pOwner;
        HGProcessOwner* pMoveOwner;
        SideType side;
        int life;
        int lifeMax;
        
        float vx;
        float vy;
        float directionDegree;
        float directionRadian;
    };
}

#endif /* defined(__Shooter__HBullet__) */
