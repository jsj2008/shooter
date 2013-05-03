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

namespace hg {
    
    ////////////////////
    // Weapon
    typedef enum WeaponType
    {
        WEAPON_TYPE_NORMAL,
    } WeaponType;
    class Weapon : public HGObject
    {
    public:
        Weapon():
        relativePosition(0,0),
        lastFireTime(0),
        fireInterval(0),
        type(WEAPON_TYPE_NORMAL),
        bulletType(BULLET_TYPE_NORMAL)
        {}
        
        ~Weapon()
        {
            
        }
        
        inline void init(WeaponType type, BulletType bulletType, float pixelX, float pixelY)
        {
            switch (type) {
                case WEAPON_TYPE_NORMAL:
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
        
        inline void fire(Actor* pOwner, float directionDegree)
        {
            if (getNowTime() - lastFireTime < fireInterval)
            {
                return;
            }
            lastFireTime = getNowTime();
            Bullet* bp = new Bullet();
            float x = pOwner->getPositionX() + relativePosition.x;
            float y = pOwner->getPositionY() + relativePosition.y;
            bp->init(bulletType, power, pOwner, x, y, directionDegree);
            bp->release();
        }
        
        int power;
        HGPoint relativePosition;
        double lastFireTime;
        double fireInterval;
        WeaponType type;
        BulletType bulletType;
    };
}

#endif /* defined(__Shooter__HWeapon__) */
