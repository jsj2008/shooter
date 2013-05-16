//
//  ControlPlayerProcess.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/03.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__ControlPlayerProcess__
#define __Shooter__ControlPlayerProcess__

#include <iostream>
#include "HGameEngine.h"
#include "HGameCommon.h"
#include "HFighter.h"

namespace hg {
    // 自キャラ移動プロセス
    class ControlPlayerProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        ControlPlayerProcess() :
        base(),
        vx(0),
        vy(0),
        pFighter(NULL),
        isControllable(true)
        {
        };
        ~ControlPlayerProcess()
        {
            pFighter->release();
        }
        void init(HGProcessOwner* pProcOwner, Fighter* inFighter)
        {
            base::init(pProcOwner);
            pFighter = inFighter;
            pFighter->retain();
        }
    protected:
        void onUpdate()
        {
            if (keyInfo.power != 0 && !keyInfo.isFire)
            {
                pFighter->setAspectDegree(keyInfo.degree);
            }
            if (pFighter->getLife() > 0)
            {
                float speed = pFighter->getSpeed()*keyInfo.power;
                float r = toRad(keyInfo.degree);
                vx = cos(r) * speed;
                vy = sin(r) * speed * -1;
            }
            else
            {
                if (isControllable)
                {
                    pFighter->explode();
                    isControllable = false;
                }
            }
            pFighter->getNode()->addPosition(vx, vy);
            
            if (pFighter->getLife() > 0)
            {
                // フィールド外チェック
                float x = pFighter->getPositionX();
                float y = pFighter->getPositionY();
                float w = pFighter->getWidth();
                float h = pFighter->getHeight();
                if (x + w/2 > sizeOfField.width)
                {
                    pFighter->setPositionX(sizeOfField.width - w/2);
                }
                if (y + h/2 > sizeOfField.height)
                {
                    pFighter->setPositionY(sizeOfField.height - h/2);
                }
                if (x - w/2 < 0)
                {
                    pFighter->setPositionX(w/2);
                }
                if (y - h/2 < 0)
                {
                    pFighter->setPositionY(h/2);
                }
            }
            if (keyInfo.isFire)
            {
                pFighter->fire();
            }
            if (!pFighter->isActive())
            {
                this->setEnd();
            }
            
        }
        std::string getName()
        {
            return "PlayerControlProcess";
        }
    private:
        Fighter* pFighter;
        float vx;
        float vy;
        bool isControllable;
    };
}

#endif /* defined(__Shooter__ControlPlayerProcess__) */
