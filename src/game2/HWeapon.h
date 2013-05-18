//
//  HWeapon.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/03.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__HWeapon__
#define __Shooter__HWeapon__

#include <iostream>
#include "HGameEngine.h"
#include "HBullet.h"
#include "HGameCommon.h"

namespace hg {
    
    ////////////////////
    // Weapon
    typedef enum WeaponType
    {
        WeaponTypeNormal,
    } WeaponType;
    class Weapon : public HGObject
    {
    public:
        Weapon():
        relativePosition(0,0),
        speed(0),
        power(0),
        lastFireTime(0),
        fireInterval(0),
        type(WeaponTypeNormal),
        aspectDegree(0),
        bulletType(BulletTypeNormal)
        {}
        
        ~Weapon()
        {
            
        }
        
        inline void init(WeaponType type, BulletType bulletType, float pixelX, float pixelY)
        {
            switch (type) {
                case WeaponTypeNormal:
                    speed = v(0.4);
                    fireInterval = 0.2;
                    power = 100;
                    break;
                default:
                    break;
            }
            this->type = type;
            this->bulletType = bulletType;
            relativePosition.x = pixelX*PIXEL_SCALE;
            relativePosition.y = pixelY*PIXEL_SCALE;
        }
        
        inline void setSpeed(float spd)
        {
            speed = spd;
        }
        
        inline void setInterval(float interval)
        {
            fireInterval = interval;
        }
        
        inline float getRelativeX()
        {
            return relativePosition.x;
        }
        
        inline float getRelativeY()
        {
            return relativePosition.y;
        }
        
        inline void fire(Actor* pOwner, SideType side)
        {
            if (getNowTime() - lastFireTime < fireInterval)
            {
                return;
            }
            lastFireTime = getNowTime();
            Bullet* bp = new Bullet();
            float x = pOwner->getPositionX() + relativePosition.x;
            float y = pOwner->getPositionY() + relativePosition.y;
            bp->init(bulletType, speed, power, pOwner, x, y, this->aspectDegree, side);
            switch (side) {
                case SideTypeEnemy:
                    enemyBulletList.addActor(bp);
                    break;
                case SideTypeFriend:
                    friendBulletList.addActor(bp);
                    break;
                default:
                    assert(0);
                    break;
            }
        }
        
        inline void setAspect(float degree)
        {
            this->aspectDegree = degree;
        }
        
        float speed;
        int power;
        HGPoint relativePosition;
        double lastFireTime;
        double fireInterval;
        WeaponType type;
        BulletType bulletType;
        float aspectDegree;
    };
}

#endif /* defined(__Shooter__HWeapon__) */
