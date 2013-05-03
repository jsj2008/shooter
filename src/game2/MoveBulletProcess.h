//
//  MoveBulletProcess.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/03.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__MoveBulletProcess__
#define __Shooter__MoveBulletProcess__

#include <iostream>
#include "HGameEngine.h"
#include "HGameCommon.h"
#include "HBullet.h"

namespace hg {
    
    ////////////////////
    // bullet移動プロセス
    class MoveBulletProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        MoveBulletProcess() :
        base(),
        vx(0),
        vy(0),
        speed(0),
        directionDegree(0),
        pBullet(NULL)
        {
        };
        ~MoveBulletProcess()
        {
            pBullet->release();
        }
    protected:
        void init(HGProcessOwner* pProcOwner, Bullet* inBullet, float speed, float directionDegree)
        {
            base::init(pProcOwner);
            pBullet = inBullet;
            pBullet->retain();
            this->speed = speed;
            this->directionDegree = directionDegree;
            float r = toRad(keyInfo.degree);
            vx = cos(r) * speed;
            vy = sin(r) * speed * -1;
        }
        void onUpdate()
        {
            HGNode* n = pBullet->getNode();
            n->addPosition(vx, vy);
            // フィールド外チェック
            float x = pBullet->getPositionX();
            float y = pBullet->getPositionY();
            float w = pBullet->getWidth();
            float h = pBullet->getHeight();
            if (x + w/2 > fieldSize.width)
            {
                pBullet->setPositionX(fieldSize.width - w/2);
            }
            if (y + h/2 > fieldSize.height)
            {
                pBullet->setPositionY(fieldSize.height - h/2);
            }
            if (x - w/2 < 0)
            {
                pBullet->setPositionX(w/2);
            }
            if (y - h/2 < 0)
            {
                pBullet->setPositionY(h/2);
            }
        }
        std::string getName()
        {
            return "BulletMoveProcess";
        }
    private:
        Bullet* pBullet;
        float vx;
        float vy;
        float directionDegree;
        float speed;
    };
}

#endif /* defined(__Shooter__MoveBulletProcess__) */
