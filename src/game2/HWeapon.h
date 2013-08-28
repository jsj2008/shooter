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
    
    class Fighter;
    extern float getPositionX(Fighter* fighter);
    extern float getPositionY(Fighter* fighter);
    
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
        
        inline void init(int type, int bulletType, float pixelX, float pixelY, float speed, int power, float fireInterval)
        {
            this->speed = v(speed);
            this->fireInterval = fireInterval;
            this->power = power;
            this->type = type;
            this->bulletType = bulletType;
            relativePosition.x = pixelX*PIXEL_SCALE;
            relativePosition.y = pixelY*PIXEL_SCALE;
        }
        
        inline void setSpeed(float spd)
        {
            speed = spd;
        }
        
        inline float getRelativeX()
        {
            return relativePosition.x;
        }
        
        inline float getRelativeY()
        {
            return relativePosition.y;
        }
        
        Bullet* createBullet()
        {
            Bullet* bp = new Bullet();
            float x = getPositionX(pOwner) + relativePosition.x;
            float y = getPositionY(pOwner) + relativePosition.y;
            bp->init(bulletType, speed, 50, power, pOwner, x, y, this->aspectDegree, side);
            switch (side) {
                case SideTypeEnemy:
                    enemyBulletList.addActor(bp);
                    battleResult.enemyShot++;
                    break;
                case SideTypeFriend:
                    friendBulletList.addActor(bp);
                    if (isPlayer) {
                        battleResult.myShot++;
                    }
                    battleResult.allShot++;
                    battleResult.allShotPower += power;
                    break;
                default:
                    assert(0);
                    break;
            }
            return bp;
        }
        
        inline void fire(Fighter* pOwner, SideType side, bool isPlayer)
        {
            if (getNowTime() - lastFireTime < fireInterval)
            {
                return;
            }
            this->pOwner = pOwner;
            this->side = side;
            this->isPlayer = isPlayer;
            lastFireTime = getNowTime();
            normalShot();
        }
        
        inline void setInterval(float interval)
        {
            fireInterval = interval;
        }
        
        inline void setAspect(float degree)
        {
            this->aspectDegree = degree;
        }
        
        ////////////////////
        void normalShot()
        {
            createBullet();
        }
        
        ////////////////////
        float speed;
        int power;
        HGPoint relativePosition;
        double lastFireTime;
        double fireInterval;
        int type;
        int bulletType;
        float aspectDegree;
        
        ////////////////////
    private:
        Fighter* pOwner;
        SideType side;
        bool isPlayer;
    };
}

#endif /* defined(__Shooter__HWeapon__) */
