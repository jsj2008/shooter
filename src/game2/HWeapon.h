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

#define FORHEAD_NORMAL 180

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
            switch (type) {
                case WeaponTypeNormal:
                    shotFunc = &Weapon::normalShot;
                    break;
                case WeaponTypeTwin:
                    shotFunc = &Weapon::twinShot;
                    break;
                case WeaponTypeTriple:
                    shotFunc = &Weapon::tripleShot;
                    break;
                case WeaponTypeShotgun:
                    shotFunc = &Weapon::shotGun;
                    break;
                case WeaponTypeCircle:
                    shotFunc = &Weapon::circle;
                    break;
                case WeaponTypeAK:
                    shotFunc = &Weapon::shotAK;
                    break;
                case WeaponTypeLaser:
                    shotFunc = &Weapon::shotLaser;
                    break;
                case WeaponTypeTwinLaser:
                    shotFunc = &Weapon::shotTwinLaser;
                    break;
                case WeaponTypeGatring:
                    shotFunc = &Weapon::shotGatring;
                    break;
                case WeaponTypeGatringLaser:
                    shotFunc = &Weapon::shotGatringLaser;
                    break;
                case WeaponTypeRotate:
                    shotFunc = &Weapon::shotRotate;
                    break;
                case WeaponTypeRotateR:
                    shotFunc = &Weapon::shotRotateR;
                    break;
                case WeaponTypeRotateQuad:
                    shotFunc = &Weapon::shotRotateQuad;
                    break;
                case WeaponTypeCircleRotate:
                    shotFunc = &Weapon::shotCircleRotate;
                    break;
                case WeaponTypeMad:
                    shotFunc = &Weapon::shotMad;
                    break;
                case WeaponTypeThreeWay:
                    shotFunc = &Weapon::shotThreeWay;
                    break;
                case WeaponTypeFiveWay:
                    shotFunc = &Weapon::shotFiveWay;
                    break;
                case WeaponTypeRotateShotgun:
                    shotFunc = &Weapon::shotRotateShotgun;
                    break;
                case WeaponTypeFiveStraights:
                    shotFunc = &Weapon::shotFiveStraights;
                    break;
                case WeaponTypeStraight:
                    shotFunc = &Weapon::shotStraight;
                    break;
                case WeaponTypeMegaLaser:
                    shotFunc = &Weapon::shotMegaLaser;
                    break;
                default:
                    break;
            }
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
        
        inline Bullet* createBullet(float x, float y, float degree, float speed, float power)
        {
            if (side ==SideTypeEnemy)
            {
                if (enemyBulletList.size() > ENEMY_BULLET_NUM) {
                    return NULL;
                }
                Bullet* bp = new Bullet();
                bp->init(bulletType, speed, 80, power, pOwner, x, y, degree, side);
                enemyBulletList.addActor(bp);
                battleResult.enemyShot++;
                return bp;
            }
            else
            {
                if (isPlayer) {
                    battleResult.myShot++;
                } else {
                    if (friendBulletList.size() > BULLET_NUM) {
                        return NULL;
                    }
                }
                Bullet* bp = new Bullet();
                bp->init(bulletType, speed, 80, power, pOwner, x, y, degree, side);
                friendBulletList.addActor(bp);
                battleResult.allShot++;
                battleResult.allShotPower += power;
                return bp;
            }
        }
        
        inline Bullet* createBullet(float x, float y, float degree, float speed)
        {
            return this->createBullet(x, y, degree, speed, this->power);
        }
        
        inline Bullet* createBullet(float x, float y, float degree)
        {
            return createBullet(x, y, degree, this->speed);
        }
        
        inline bool fire(Fighter* pOwner, SideType side, bool isPlayer)
        {
            if (getNowTime() - lastFireTime < fireInterval)
            {
                return false;
            }
            this->pOwner = pOwner;
            this->side = side;
            this->isPlayer = isPlayer;
            lastFireTime = getNowTime();
            (this->*shotFunc)();
            return true;
        }
        
        inline void setInterval(float interval)
        {
            fireInterval = interval;
        }
        
        inline void setAspect(float degree)
        {
            this->aspectDegree = degree;
        }
        
        inline HGPoint getForeheadPos(float diffPixel) {
            if (diffPixel == 0) {
                return {
                    (getPositionX(pOwner) + relativePosition.x),
                    (getPositionY(pOwner) + relativePosition.y)
                };
            }
            float offset = PXL2REAL(diffPixel);
            float tmpX = cosf(toRad(this->aspectDegree)) * offset;
            float tmpY = sinf(toRad(this->aspectDegree)) * offset * -1;
            tmpX += (getPositionX(pOwner) + relativePosition.x);
            tmpY += (getPositionY(pOwner) + relativePosition.y);
            return {
                tmpX, tmpY
            };
        }
        
        inline HGPoint getOffsetPoint(HGPoint& srcPoint, float diffPixel, float inDegree) {
            float deg = ((int)(inDegree) + 36000)%360;
            float diff = PXL2REAL(diffPixel);
            float offX = cosf(toRad(deg)) * diff;
            float offY = sinf(toRad(deg)) * diff * -1;
            float x = srcPoint.x + offX;
            float y = srcPoint.y + offY;
            return {
                x, y
            };
        }
        
        inline void shotLongLaserSub(HGPoint& src, float sumPower, float degree) {
            int bulletNum = 12;
            int power = ceil(sumPower/(float)bulletNum);
            float diff = 50;
            float offset = -diff;
            for (int i = 0; i < bulletNum; i++) {
                offset += diff;
                HGPoint p = getOffsetPoint(src, offset, degree);
                createBullet(p.x, p.y, degree, speed, power);
            }
        }
        
        inline void shotLaserSub(HGPoint& src, float sumPower, float degree, float speed, int bulletNum) {
            int power = ceil(sumPower/(float)bulletNum);
            float diff = 50;
            float offset = -diff;
            for (int i = 0; i < bulletNum; i++) {
                offset += diff;
                HGPoint p = getOffsetPoint(src, offset, degree);
                createBullet(p.x, p.y, degree, speed, power);
            }
        }
        
        inline void shotLaserSub(HGPoint& src, float sumPower, float degree, float speed) {
            shotLaserSub(src, sumPower, degree, speed, 7);
        }
        
        inline void shotLaserSub(HGPoint& src, float sumPower, float degree) {
            shotLaserSub(src, sumPower, degree, speed);
        }
        
        ////////////////////
        void shotMegaLaser() {
            int bulletNum = 10;
            int power = ceil(this->power/(float)bulletNum);
            float diff = 200;
            float offset = -diff;
            HGPoint src = getForeheadPos(0);
            for (int i = 0; i < bulletNum; i++) {
                offset += diff;
                HGPoint p = getOffsetPoint(src, offset, this->aspectDegree);
                createBullet(p.x, p.y, this->aspectDegree, speed, power);
            }
        }
        
        void normalShot()
        {
            HGPoint p = getForeheadPos(FORHEAD_NORMAL);
            createBullet(p.x, p.y, this->aspectDegree);
        }
        void twinShot()
        {
            HGPoint tmpPoint = getForeheadPos(FORHEAD_NORMAL);
            HGPoint p1 = getOffsetPoint(tmpPoint, 150, this->aspectDegree - 90);
            HGPoint p2 = getOffsetPoint(tmpPoint, 150, this->aspectDegree + 90);
            float power = this->power/2;
            createBullet(p1.x, p1.y, this->aspectDegree, speed, power);
            createBullet(p2.x, p2.y, this->aspectDegree, speed, power);
        }
        void tripleShot()
        {
            HGPoint tmpPoint = getForeheadPos(FORHEAD_NORMAL);
            HGPoint p1 = getOffsetPoint(tmpPoint, 200, this->aspectDegree - 90);
            HGPoint p2 = getOffsetPoint(tmpPoint, 200, this->aspectDegree + 90);
            HGPoint p3 = getOffsetPoint(tmpPoint, 200, this->aspectDegree);
            float power = this->power/3;
            createBullet(p1.x, p1.y, this->aspectDegree, speed, power);
            createBullet(p2.x, p2.y, this->aspectDegree, speed, power);
            createBullet(p3.x, p3.y, this->aspectDegree, speed, power);
        }
        void shotStraight()
        {
            /*
            HGPoint p = getForeheadPos(FORHEAD_NORMAL);
            int bNum = 8;
            float power = this->power/bNum;
            float speed = this->speed * 0.8;
            float speedDiff = 0.18;
            for (int i = 0; i < bNum; i++) {
                speed += speedDiff;
                createBullet(p.x, p.y, this->aspectDegree, speed, power);
            }*/
            int bulletNum = 5;
            int power = ceil((float)this->power/(float)bulletNum);
            HGPoint p = getForeheadPos(FORHEAD_NORMAL);
            for (int i = 0; i < bulletNum; i++) {
                float aspectDiff = sinf(toRad(rand(0, 360))) * 5;
                float speed = (float)rand(90, 110) * 0.01 * this->speed;
                shotLaserSub(p, power, this->aspectDegree + aspectDiff, speed, 3);
            }
        }
        void shotFiveStraights()
        {
            HGPoint tmpPoint = getForeheadPos(FORHEAD_NORMAL);
            float power = this->power/7;
            HGPoint p1 = getOffsetPoint(tmpPoint, 200, this->aspectDegree);
            HGPoint p2 = getOffsetPoint(tmpPoint, 200, this->aspectDegree + 45);
            HGPoint p3 = getOffsetPoint(tmpPoint, 200, this->aspectDegree + 90);
            HGPoint p4 = getOffsetPoint(tmpPoint, 200, this->aspectDegree + 180);
            HGPoint p5 = getOffsetPoint(tmpPoint, 200, this->aspectDegree + 225);
            HGPoint p6 = getOffsetPoint(tmpPoint, 200, this->aspectDegree + 270);
            HGPoint p7 = getOffsetPoint(tmpPoint, 200, this->aspectDegree + 315);
            createBullet(p1.x, p1.y, this->aspectDegree, speed, power);
            createBullet(p2.x, p2.y, this->aspectDegree, speed, power);
            createBullet(p3.x, p3.y, this->aspectDegree, speed, power);
            createBullet(p4.x, p4.y, this->aspectDegree, speed, power);
            createBullet(p5.x, p5.y, this->aspectDegree, speed, power);
            createBullet(p6.x, p6.y, this->aspectDegree, speed, power);
            createBullet(p7.x, p7.y, this->aspectDegree, speed, power);
        }
        void shotThreeWay()
        {
            HGPoint p = getForeheadPos(FORHEAD_NORMAL);
            float degreeDiff = 10;
            float power = this->power/3;
            createBullet(p.x, p.y, this->aspectDegree - degreeDiff, speed, power);
            createBullet(p.x, p.y, this->aspectDegree, speed, power);
            createBullet(p.x, p.y, this->aspectDegree + degreeDiff, speed, power);
        }
        void shotFiveWay()
        {
            HGPoint p = getForeheadPos(FORHEAD_NORMAL);
            float degreeDiff = 5;
            float power = this->power/3;
            createBullet(p.x, p.y, this->aspectDegree - degreeDiff*2, speed, power);
            createBullet(p.x, p.y, this->aspectDegree - degreeDiff, speed, power);
            createBullet(p.x, p.y, this->aspectDegree, speed, power);
            createBullet(p.x, p.y, this->aspectDegree + degreeDiff, speed, power);
            createBullet(p.x, p.y, this->aspectDegree + degreeDiff*2, speed, power);
        }
        void shotGun()
        {
            int bulletNum = 8;
            int power = ceil((float)this->power/(float)bulletNum);
            HGPoint p = getForeheadPos(FORHEAD_NORMAL);
            for (int i = 0; i < bulletNum; i++) {
                float aspectDiff = sinf(toRad(rand(0, 360))) * 20;
                float speed = (float)rand(90, 110) * 0.01 * this->speed;
                createBullet(p.x, p.y, this->aspectDegree + aspectDiff, speed, power);
            }
        }
        void shotRotateShotgun()
        {
            int bulletNum = 8;
            int power = ceil((float)this->power/(float)bulletNum);
            HGPoint p = getForeheadPos(FORHEAD_NORMAL);
            workDeg1 += 30;
            workDeg1 %= 360;
            for (int i = 0; i < bulletNum; i++) {
                float aspectDiff = sinf(toRad(rand(0, 360))) * 20;
                float speed = (float)rand(90, 110) * 0.01 * this->speed;
                createBullet(p.x, p.y, this->aspectDegree + aspectDiff + workDeg1, speed, power);
            }
        }
        void shotAK()
        {
            HGPoint p = getForeheadPos(FORHEAD_NORMAL);
            float aspectDiff = sinf(toRad(rand(0, 360))) * 10;
            float speed = (float)rand(95, 105) * 0.01 * this->speed;
            createBullet(p.x, p.y, this->aspectDegree + aspectDiff, speed, power);
        }
        void shotLaser()
        {
            HGPoint src = getForeheadPos(FORHEAD_NORMAL);
            shotLongLaserSub(src, power, this->aspectDegree);
        }
        void shotTwinLaser()
        {
            HGPoint tmpPoint = getForeheadPos(FORHEAD_NORMAL);
            HGPoint p1 = getOffsetPoint(tmpPoint, 150, this->aspectDegree + 45);
            HGPoint p2 = getOffsetPoint(tmpPoint, 150, this->aspectDegree - 45);
            float power = this->power/2;
            shotLaserSub(p1, power, this->aspectDegree);
            shotLaserSub(p2, power, this->aspectDegree);
        }
        void shotMad()
        {
            int bulletNum = 10;
            int power = ceil((float)this->power/(float)bulletNum);
            HGPoint p = getForeheadPos(0);
            for (int i = 0; i < bulletNum; i++) {
                float deg = rand(0, 360);
                float speed = this->speed * (float)rand(80, 120) * 0.01;
                createBullet(p.x, p.y, deg, speed, power);
            }
        }
        void circle()
        {
            int bulletNum = 16;
            float offsetDeg = 360/bulletNum;
            int power = ceil((float)this->power/(float)bulletNum);
            HGPoint p = getForeheadPos(0);
            float deg = -offsetDeg;
            for (int i = 0; i < bulletNum; i++) {
                deg += offsetDeg;
                createBullet(p.x, p.y, deg, speed, power);
            }
        }
        void shotCircleRotate()
        {
            workDeg1 += 10; workDeg1 %= 360;
            int bulletNum = 16;
            float offsetDeg = 360/bulletNum;
            int power = ceil((float)this->power/(float)bulletNum);
            HGPoint p = getForeheadPos(0);
            int deg = -offsetDeg;
            for (int i = 0; i < bulletNum; i++) {
                deg += offsetDeg + workDeg1;
                createBullet(p.x, p.y, deg%360, speed, power);
            }
        }
        void shotGatring()
        {
            workDeg1 += 20; workDeg1 %= 360;
            workDeg2 += 20; workDeg2 %= 360;
            workDeg3 += 20; workDeg3 %= 360;
            workDeg4 += 20; workDeg4 %= 360;
            HGPoint src = getForeheadPos(FORHEAD_NORMAL);
            float diff = 180;
            float power = this->power/4;
            {
                HGPoint p = getOffsetPoint(src, diff, workDeg1);
                createBullet(p.x, p.y, this->aspectDegree, speed, power);
            }
            {
                HGPoint p = getOffsetPoint(src, diff, workDeg2);
                createBullet(p.x, p.y, this->aspectDegree, speed, power);
            }
            {
                HGPoint p = getOffsetPoint(src, diff, workDeg3);
                createBullet(p.x, p.y, this->aspectDegree, speed, power);
            }
            {
                HGPoint p = getOffsetPoint(src, diff, workDeg4);
                createBullet(p.x, p.y, this->aspectDegree, speed, power);
            }
        }
        void shotGatringLaser()
        {
            workDeg1 += 20; workDeg1 %= 360;
            workDeg2 += 20; workDeg2 %= 360;
            workDeg3 += 20; workDeg3 %= 360;
            workDeg4 += 20; workDeg4 %= 360;
            HGPoint src = getForeheadPos(FORHEAD_NORMAL);
            float diff = 180;
            float power = this->power/4;
            {
                HGPoint p = getOffsetPoint(src, diff, workDeg1);
                shotLaserSub(p, power, this->aspectDegree);
            }
            {
                HGPoint p = getOffsetPoint(src, diff, workDeg2);
                shotLaserSub(p, power, this->aspectDegree);
            }
            {
                HGPoint p = getOffsetPoint(src, diff, workDeg3);
                shotLaserSub(p, power, this->aspectDegree);
            }
            {
                HGPoint p = getOffsetPoint(src, diff, workDeg4);
                shotLaserSub(p, power, this->aspectDegree);
            }
        }
        void shotRotate()
        {
            workDeg1 += 20; workDeg1 %= 360;
            /*
            workDeg2 += 20; workDeg2 %= 360;
            workDeg3 += 20; workDeg3 %= 360;
            workDeg4 += 20; workDeg4 %= 360;*/
            HGPoint p = getForeheadPos(0);
            {
                createBullet(p.x, p.y, workDeg1, speed, power);
            }
        }
        void shotRotateR()
        {
            workDeg1 -= 20; workDeg1 %= 360;
            HGPoint p = getForeheadPos(0);
            {
                createBullet(p.x, p.y, workDeg1, speed, power);
            }
        }
        void shotRotateQuad()
        {
            float power = this->power/4;
            workDeg1 += 20; workDeg1 %= 360;
            workDeg2 += 20; workDeg2 %= 360;
            workDeg3 += 20; workDeg3 %= 360;
            workDeg4 += 20; workDeg4 %= 360;
            HGPoint p = getForeheadPos(0);
            createBullet(p.x, p.y, workDeg1, speed, power);
            createBullet(p.x, p.y, workDeg2, speed, power);
            createBullet(p.x, p.y, workDeg3, speed, power);
            createBullet(p.x, p.y, workDeg4, speed, power);
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
        int workDeg1 = 0;
        int workDeg2 = 90;
        int workDeg3 = 180;
        int workDeg4 = 270;
        Fighter* pOwner;
        SideType side;
        bool isPlayer;
        void (Weapon::*shotFunc)();
    };
}

#endif /* defined(__Shooter__HWeapon__) */
