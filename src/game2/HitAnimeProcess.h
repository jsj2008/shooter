//
//  HitAnimeProcess.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/06.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__HitAnimeProcess__
#define __Shooter__HitAnimeProcess__

#include <iostream>
#include "HGameEngine.h"
#include "HGameCommon.h"

namespace hg
{
    
    class HitAnimeProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        HitAnimeProcess() :
        base(),
        pSprBom(NULL),
        sizeOfTexSrc(0,0),
        offsetOfTexSrc(0,0),
        size(0,0)
        {
        };
        ~HitAnimeProcess()
        {
            pSprBom->release();
        }
        void init(HGProcessOwner* pProcOwner, Vector& position, HGNode* parentNode)
        {
            base::init(pProcOwner);
            this->position = position;
            
            sizeOfTexSrc.width  = 64;
            sizeOfTexSrc.height = 64;
            offsetOfTexSrc.x = 0;
            offsetOfTexSrc.y = 0;
            float r = rand(PXL2REAL(200), PXL2REAL(300));
            size.width = r;
            size.height = r;
            
            pSprBom = new HGSprite();
            pSprBom->init("hit_small.png");
            pSprBom->setPosition(position.x, position.y, position.z);
            pSprBom->setScale(size.width, size.height);
            pSprBom->setTextureRect(offsetOfTexSrc.x, offsetOfTexSrc.y, sizeOfTexSrc.width, sizeOfTexSrc.height);
            parentNode->addChild(pSprBom);
        }
    protected:
        void onUpdate()
        {
            if (getFrameCount() >= 8)
            {
                pSprBom->removeFromParent();
                setEnd();
                return;
            }
            if (getFrameCount() >= 5)
            {
                pSprBom->setOpacity(pSprBom->getOpacity() * 0.5);
            }
            int x = sizeOfTexSrc.width * getFrameCount();
            pSprBom->setTextureRect(x, 0, sizeOfTexSrc.width, sizeOfTexSrc.height);
        }
        std::string getName()
        {
            return "HitAnimeProcess";
        }
    private:
        HGSize sizeOfTexSrc;
        Vector position;
        HGPoint offsetOfTexSrc;
        HGSize size;
        HGSprite* pSprBom;
    };
}

#endif /* defined(__Shooter__HitAnimeProcess__) */
