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
#include "HGameCommon.h"
#include "HGameEngine.h"
#include "HCollision.h"

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
        isInitialized(false),
        _isActive(true),
        collisionId(-1)
        {
        };
        ~Actor()
        {
            pNode->release();
        }
        virtual void init(HGNode* pNodeParent)
        {
            this->pNode = new HGNode();
            pNodeParent->addChild(this->pNode);
            isInitialized = true;
        }
        virtual void setActive(bool isActive)
        {
            assert(_isActive != isActive);
            this->_isActive = isActive;
        }
        inline bool isActive()
        {
            return this->_isActive;
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
        inline Vector& getPosition()
        {
            return pNode->getPosition();
        }
        inline HGSize& getSize()
        {
            return realSize;
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
        inline CollisionId getCollisionId()
        {
            return collisionId;
        }
        inline void setSizeByPixel(float width, float height)
        {
            pixelSize.width = width;
            pixelSize.height = height;
            realSize.width = PXL2REAL(pixelSize.width);
            realSize.height = PXL2REAL(pixelSize.height);
        }
        
    protected:
        HGNode* pNode;
        inline void setCollisionId(CollisionId cid)
        {
            collisionId = cid;
        }
    private:
        HGSize pixelSize;
        HGSize realSize;
        bool isInitialized;
        bool _isActive;
        CollisionId collisionId;
    };
    
}

#endif /* defined(__Shooter__File__) */
