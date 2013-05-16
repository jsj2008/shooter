//
//  SpawnProcess.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/12.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__SpawnProcess__
#define __Shooter__SpawnProcess__
/*
 
#include <iostream>
#include "HGameEngine.h"
#include "HGameCommon.h"

namespace hg
{
    
    class SpawnProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        SpawnProcess() :
        base(),
        position(0, 0, 0),
        sizeOfTexSrc(64,64),
        offsetOfTexSrc(0,0),
        pSpr(NULL)
        {
        };
        ~SpawnProcess()
        {
            pSpr->release();
        }
        void init(HGProcessOwner* pProcOwner, Vector& position, HGNode* parentNode)
        {
            base::init(pProcOwner);
            this->position = position;
            
            pSpr = new HGSprite();
            pSpr->init("explode_small.png");
            pSpr->setPosition(position.x, position.y, position.z);
            pSpr->setScale(PXL2REAL(500), PXL2REAL(500));
            pSpr->setTextureRect(offsetOfTexSrc.x, offsetOfTexSrc.y, sizeOfTexSrc.width, sizeOfTexSrc.height);
            pSpr->setRotateZ(rand(0, 359) * M_PI/180);
            
            parentNode->addChild(pSpr);
        }
    protected:
        void onUpdate()
        {
        }
        std::string getName()
        {
            return "SpawnProcess";
        }
    private:
        Vector position;
        HGSprite* pSpr;
        HGSize sizeOfTexSrc;
        HGPoint offsetOfTexSrc;
    };
}
*/
#endif /* defined(__Shooter__SpawnProcess__) */
