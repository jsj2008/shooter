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
        }
        inline void init(BulletType type, int power, Actor* pOwner, float x, float y, float directionDegree)
        {
            assert(pOwner);
            base::init(pLayerBullet);
            this->power = power;
            this->pOwner = pOwner;
            pOwner->retain();
            this->type = type;
            switch (type) {
                case BULLET_TYPE_NORMAL:
                {
                    setSizeByPixel(200, 200);
                    HGSprite* pSprite = new HGSprite();
                    pSprite->setType(SPRITE_TYPE_BILLBOARD);
                    pSprite->init("divine.png");
                    pSprite->setScale(getWidth(), getHeight());
                    pSprite->shouldRenderAsAlphaMap(true);
                    pSprite->setColor({1,1,1,1});
                    pSprite->setBlendFunc(GL_ALPHA, GL_ALPHA);
                    pSprite->setPosition(x, y);
                    getNode()->addChild(pSprite);
                    pSprite->release();
                    
                    //BulletMoveProcess* bmp = new BulletMoveProcess();
                    //bmp->init(pMoveOwner, this, speed, directionDegree)
                    
                    //HGProcessManager::sharedProcessManager()->addPrcoess(ProcessPtr(new BulletMoveProcess(moveProcessOwner, speed,)))
                    break;
                }
                default:
                    break;
            }
        }
    private:
        int power;
        float speed;
        BulletType type;
        Actor* pOwner;
        HGProcessOwner* pMoveOwner;
    };
}

#endif /* defined(__Shooter__HBullet__) */
