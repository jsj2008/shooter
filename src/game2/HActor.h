//
//  File.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/03.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__File__
#define __Shooter__File__

#include <iostream>
#include "HTypes.h"
#include "HDefine.h"
#include "HGameEngine.h"

namespace hg
{
    ////////////////////
    // Actor
    class Actor : public HGObject
    {
    public:
        Actor():
        pNode(NULL),
        pixelSize(0,0),
        realSize(0,0),
        isInitialized(false)
        {
        };
        
        virtual void init(HGNode* pNodeParent)
        {
            this->pNode = new HGNode();
            pNodeParent->addChild(this->pNode);
            isInitialized = true;
        }
        
        inline void setPosition(float x, float y)
        {
            pNode->setPosition(x, y);
        }
        inline void setPositionX(float x)
        {
            pNode->setPositionX(x);
        }
        inline void setPositionY(float y)
        {
            pNode->setPositionY(y);
        }
        inline float getPositionX()
        {
            return pNode->getPositionX();
        }
        inline float getPositionY()
        {
            return pNode->getPositionY();
        }
        inline float getWidth()
        {
            return realSize.width;
        }
        inline float getHeight()
        {
            return realSize.height;
        }
        inline HGNode* getNode()
        {
            return pNode;
        }
        inline void setSizeByPixel(float width, float height)
        {
            pixelSize.width = width;
            pixelSize.height = height;
            realSize.width = pixelSize.width*PIXEL_SCALE;
            realSize.height = pixelSize.height*PIXEL_SCALE;
        }
        
    protected:
        HGNode* pNode;
    private:
        HGSize pixelSize;
        HGSize realSize;
        bool isInitialized;
    };
    
}

#endif /* defined(__Shooter__File__) */
