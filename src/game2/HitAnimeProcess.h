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
            float r = rand(PXL2REAL(600), PXL2REAL(850));
            size.width = r;
            size.height = r;
            
            pSprBom = new HGSprite();
            pSprBom->init("hit_small.png");
            pSprBom->setPosition(position.x, position.y, position.z);
            pSprBom->setScale(size.width, size.height);
            pSprBom->setTextureRect(offsetOfTexSrc.x, offsetOfTexSrc.y, sizeOfTexSrc.width, sizeOfTexSrc.height);
            pSprBom->setRotateZ(rand(0, 359) * M_PI/180);
            pSprBom->setBlendFunc(GL_SRC_ALPHA, GL_ONE);
            pSprBom->retain();
            
            parentNode->addChild(pSprBom);
            numOfEffect++;
        }
    protected:
        void onUpdate()
        {
            int frameCount = getFrameCount()/2;
            if (frameCount >= 8)
            {
                pSprBom->removeFromParent();
                setEnd();
                numOfEffect--;
                return;
            }
            if (frameCount >= 5)
            {
                pSprBom->setOpacity(pSprBom->getOpacity() * 0.5);
            }
            int x = sizeOfTexSrc.width * frameCount;
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
