//
//  ControlEnemyProcess.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/05.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__ControlEnemyProcess__
#define __Shooter__ControlEnemyProcess__

#include <iostream>
#include "HGameEngine.h"
#include "HFighter.h"
#include "HGameCommon.h"
#include "ExplodeAnimeProcess.h"

namespace hg {
    
    class ControlEnemyProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        ControlEnemyProcess() :
        base(),
        vx(0),
        vy(0),
        pFighter(NULL),
        pTarget(NULL),
        pointOfDestination(0,0),
        isControllable(true)
        {
        };
        ~ControlEnemyProcess()
        {
            pFighter->release();
            if (pTarget)
            {
                pTarget->release();
            }
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
            pFighter->tick();
            if (!pFighter->isActive())
            {
                this->setEnd();
                return;
            }
            if (isControllable && pFighter->getLife() <= 0)
            {
                pFighter->explode();
                isControllable = false;
            }
            if (pTarget && (pTarget->getLife() <= 0 || rand(0, 10) <= 1))
            {
                pTarget->release();
                pTarget = NULL;
            }
            if (isControllable)
            {
                if (pTarget == NULL)
                {
                    pTarget = pFighter->getFighterHated();
                    if (pTarget)
                    {
                        pTarget->retain();
                    }
                }
                if (pTarget == NULL)
                {
                    switch (pFighter->getSide()) {
                        case SideTypeFriend:
                        {
                            CellManager<Fighter>::ActorList* t = enemyCellManager.getNearbyTargetList(pFighter->getPositionX(), pFighter->getPositionY());
                            if (t && t->size()>0)
                            {
                                pTarget = t->back();
                            }
                            break;
                        }
                        case SideTypeEnemy:
                        {
                            CellManager<Fighter>::ActorList* t = friendCellManager.getNearbyTargetList(pFighter->getPositionX(), pFighter->getPositionY());
                            if (t && t->size()>0)
                            {
                                pTarget = t->back();
                            }
                            break;
                        }
                        default:
                            break;
                    }
                    if (pTarget)
                    {
                        pTarget->retain();
                    }
                }
                if (pTarget == NULL)
                {
                    switch (pFighter->getSide()) {
                        case SideTypeFriend:
                        {
                            pTarget = enemyFighterList.getRandomActor();
                            break;
                        }
                        case SideTypeEnemy:
                        {
                            pTarget = friendFighterList.getRandomActor();
                            break;
                        }
                        default:
                            break;
                    }
                    if (pTarget)
                    {
                        pTarget->retain();
                    }
                }
                
                if (pTarget)
                {
                    // tgの方向を向く
                    float dx = pTarget->getPositionX() - pFighter->getPositionX();
                    float dy = pTarget->getPositionY() - pFighter->getPositionY();
                    float r = atan2f(pTarget->getPositionX() - pFighter->getPositionX(),
                                     pTarget->getPositionY() - pFighter->getPositionY());
                    float d = r*180/M_PI-90;
                    pFighter->setAspectDegree(d);
                    
                    // 攻撃する
                    if (pTarget->getLife() > 0 && pTarget->isActive())
                    {
                        float distance = PXL2REAL(5000);
                        if (pFighter->isShip())
                        {
                            distance = PXL2REAL(10000);
                        }
                        if (abs(dx) + abs(dy) < distance)
                        {
                            pFighter->fire(pTarget);
                        }
                        // 遠すぎる
                        else
                        {
                            pTarget->release();
                            pTarget = NULL;
                        }
                    }
                    else
                    {
                        pTarget->release();
                        pTarget = NULL;
                    }
                }
                if (pointOfDestination.x == 0 && pointOfDestination.y == 0)
                {
                    setDestination();
                }
                else
                {
                    // check alived
                    float diffX = pFighter->getPositionX() - pointOfDestination.x;
                    float diffY = pFighter->getPositionY() - pointOfDestination.y;
                    if (diffX < 0) diffX *= -1;
                    if (diffY < 0) diffY *= -1;
                    if (diffX < pFighter->getWidth()/2 && diffY < pFighter->getHeight()/2)
                    {
                        setDestination();
                    }
                }
                // タゲの方向へ移動する
                float r = atan2f(pointOfDestination.x - pFighter->getPositionX(), pointOfDestination.y - pFighter->getPositionY());
                r = r - 90*M_PI/180;
                float speed = pFighter->getSpeed();
                vx = cos(r) * speed;
                vy = sin(r) * speed * -1;
            }
            
            pFighter->getNode()->addPosition(vx, vy);
            if (isControllable)
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
            
        }
        std::string getName()
        {
            return "ControlEnemyProcess";
        }
    private:
        Fighter* pFighter;
        Fighter* pTarget;
        float vx;
        float vy;
        HGPoint pointOfDestination;
        bool isControllable;
        
        void setDestination()
        {
            if (pTarget && pTarget->getLife() > 0)
            {
                float rad = toRad(rand(1, 359));
                
#warning 距離を設定
                float distance = PXL2REAL(3000);
                if (pFighter->isShip())
                {
                    distance = PXL2REAL(5000);
                }
                float viaX = (pTarget->getPositionX() + distance*cos(rad));
                float viaY = (pTarget->getPositionY() + distance*sin(rad));
                pointOfDestination.x = viaX;
                pointOfDestination.y = viaY;
            }
            else
            {
                float rad = rand(1, 359)*180/M_PI;
                float viaX = (pFighter->getPositionX() + PXL2REAL(3000)*cos(rad));
                float viaY = (pFighter->getPositionY() + PXL2REAL(3000)*sin(rad));
                pointOfDestination.x = viaX;
                pointOfDestination.y = viaY;
                
                float r = atan2f(viaX - pFighter->getPositionX(), viaY - pFighter->getPositionY()) ;
                float d = r * 180/M_PI - 90;
                pFighter->setAspectDegree(d);
            }
            
            // フィールド外チェック
            if (pointOfDestination.x + pFighter->getWidth()/2 > sizeOfField.width)
            {
                pointOfDestination.x = sizeOfField.width - pFighter->getWidth()/2;
            }
            if (pointOfDestination.y + pFighter->getHeight()/2 > sizeOfField.height)
            {
                pointOfDestination.y = sizeOfField.height - pFighter->getHeight()/2;
            }
            if (pointOfDestination.x - pFighter->getWidth()/2 < 0)
            {
                pointOfDestination.x = pFighter->getWidth()/2;
            }
            if (pointOfDestination.y - pFighter->getHeight()/2 < 0)
            {
                pointOfDestination.y = pFighter->getHeight()/2;
            }
        }
    };
}

#endif /* defined(__Shooter__ControlEnemyProcess__) */
