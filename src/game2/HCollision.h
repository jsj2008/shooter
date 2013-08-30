//
//  HCollision.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/05.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__HCollision__
#define __Shooter__HCollision__

#include <iostream>
#include <vector>
#include "HTypes.h"
#include "HGameCommon.h"

namespace hg {
    
    class CollisionManager;
    
    class CollisionManager
    {
        typedef std::vector<HGRect> Collision;
        typedef std::vector<Collision*> CollisionList;
    public:
        inline static CollisionManager* sharedCollisionManager()
        {
            static CollisionManager* pCollisionManager = NULL;
            if (!pCollisionManager)
            {
                pCollisionManager = new CollisionManager();
                pCollisionManager->init();
            }
            return pCollisionManager;
        }
        inline bool isIntersect(int& ida, Vector& posa, HGSize& sizea,
                                int& idb, Vector& posb, HGSize& sizeb)
        {
            assert(ida != CollisionIdNone);
            assert(ida < list.size());
            assert(idb != CollisionIdNone);
            assert(idb < list.size());
            Collision* cola = list[ida];
            Collision* colb = list[idb];
            int lena = cola->size();
            int lenb = colb->size();
            float offxa = posa.x - sizea.width/2;
            float offya = posa.y - sizea.height/2;
            float offxb = posb.x - sizeb.width/2;
            float offyb = posb.y - sizeb.height/2;
            for (int i = 0; i < lena; ++i)
            {
                HGRect& ra = (*cola)[i];
                for (int j = 0; j < lenb; ++j)
                {
                    HGRect& rb = (*colb)[j];
                    if (offxa + ra.point.x <= offxb + rb.point.x + rb.size.width
                        && offxb + rb.point.x <= offxa + ra.point.x + ra.size.width
                        && offya + ra.point.y <= offyb + rb.point.y + rb.size.height
                        && offyb + rb.point.y <= offya + ra.point.y + ra.size.height)
                    {
                        return true;
                    }
                }
            }
            return false;
        }
        
        inline bool isIntersect(int& ida, Vector& posa, HGSize& sizea,
                                HGRect& rb)
        {
            assert(ida != CollisionIdNone);
            assert(ida < list.size());
            Collision* cola = list[ida];
            int lena = cola->size();
            float offxa = posa.x - sizea.width/2;
            float offya = posa.y - sizea.height/2;
            for (int i = 0; i < lena; ++i)
            {
                HGRect& ra = (*cola)[i];
                if (offxa + ra.point.x <= rb.point.x + rb.size.width
                    && rb.point.x <= offxa + ra.point.x + ra.size.width
                    && offya + ra.point.y <= rb.point.y + rb.size.height
                    && rb.point.y <= offya + ra.point.y + ra.size.height)
                {
                    return true;
                }
            }
            return false;
        }
        
        inline void addDebugMark(int ida, HGNode* node, float width, float height)
        {
            assert(ida != CollisionIdNone);
            Collision* col = list[ida];
            for (Collision::iterator it = col->begin(); it != col->end(); ++it)
            {
                HGSprite* spr = new HGSprite();
                spr->init("square.png");
                spr->shouldRenderAsAlphaMap(true);
                spr->setBlendFunc(GL_ONE, GL_ONE);
                spr->setColor({1,0,0,0.9});
                spr->setScale((*it).size.width, (*it).size.height);
                spr->setPosition(-width/2 + (*it).point.x + (*it).size.width/2, -height/2 + (*it).point.y + (*it).size.height/2);
                spr->setType(SPRITE_TYPE_BILLBOARD);
                node->addChild(spr);
            }
        }
        ~CollisionManager()
        {
            
        }
    private:
        CollisionList list;
        void init()
        {
            Collision* c;
            for (int i = (int)CollisionIdStart; i < (int)CollisionIdEnd; ++i)
            {
                switch (i) {
                    ////////////////////
                    // bullet
                    case CollisionId_BulletVulcan:
                        c = new Collision();
                        c->push_back({-2, -2, 64, 64});
                        list.push_back(c);
                        break;
                    case CollisionId_BulletNormal:
                        c = new Collision();
                        c->push_back({-6, -6, 192, 192});
                        list.push_back(c);
                        break;
                    case CollisionId_BulletMedium:
                        c = new Collision();
                        c->push_back({10, 10, 230, 230});
                        list.push_back(c);
                        break;
                    case CollisionId_BulletBig:
                        c = new Collision();
                        c->push_back({-8, -8, 416, 416});
                        list.push_back(c);
                        break;
                    case CollisionId_BulletLaser:
                        c = new Collision();
                        c->push_back({-4, -4, 148, 148});
                        list.push_back(c);
                        break;
                        ////////////////////
                    // fighter
                    // astray
                    case CollisionId_P_ROBO1:
                        c = new Collision();
                        c->push_back({88, 88, 80, 80});
                        list.push_back(c);
                        break;
                    // viper
                    case CollisionId_P_VIPER:
                        c = new Collision();
                        c->push_back({104, 104, 48, 48});
                        list.push_back(c);
                        break;
                    case CollisionId_E_SENKAN:
                        c = new Collision();
                        c->push_back({220, 200, 1530, 350});
                        list.push_back(c);
                        break;
                    case CollisionId_P_PEGASUS:
                        c = new Collision();
                        c->push_back({290, 120, 770, 260});
                        c->push_back({1030, 120, 320, 220});
                        list.push_back(c);
                        break;
                    case CollisionId_P_GATES:
                        c = new Collision();
                        c->push_back({40, 40, 176, 176});
                        list.push_back(c);
                        break;
                    case CollisionId_P_RAPTER:
                        c = new Collision();
                        c->push_back({50, 50, 200, 200});
                        list.push_back(c);
                        break;
                    case CollisionId_E_GATES:
                        c = new Collision();
                        c->push_back({0, 0, 550, 550});
                        list.push_back(c);
                        break;
                    case CollisionId_E_RADER:
                        c = new Collision();
                        c->push_back({0, 0, 420, 420});
                        list.push_back(c);
                        break;
                    case CollisionId_E_BALL:
                        c = new Collision();
                        c->push_back({0, 0, 320, 320});
                        list.push_back(c);
                        break;
                    case CollisionId_E_DESTROYER:
                        c = new Collision();
                        c->push_back({0, 0, 600, 600});
                        list.push_back(c);
                        break;
                    case CollisionId_P_LAMBDAS:
                        c = new Collision();
                        c->push_back({100, 100, 128, 128});
                        list.push_back(c);
                        break;
                    case CollisionId_P_FOX:
                        c = new Collision();
                        c->push_back({100, 100, 128, 128});
                        list.push_back(c);
                        break;
                    case CollisionId_E_TRIANGLE:
                    {
                        c = new Collision();
                        float multiply = 20;
                        c->push_back({72*multiply, 7*multiply, 46*multiply, 178*multiply});
                        c->push_back({26*multiply, 18*multiply, 44*multiply, 123*multiply});
                        c->push_back({111*multiply, 18*multiply, 35*multiply, 120*multiply});
                        c->push_back({5*multiply, 85*multiply, 166*multiply, 31*multiply});
                        c->push_back({22*multiply, 52*multiply, 136*multiply, 27*multiply});
                        list.push_back(c);
                        break;
                    }
                    case CollisionId_E_QUAD:
                    {
                        float multiply = 20;
                        c = new Collision();
                        c->push_back({4*multiply, 3*multiply, 170*multiply, 34*multiply});
                        c->push_back({27*multiply, 37*multiply, 130*multiply, 80*multiply});
                        c->push_back({71*multiply, 120*multiply, 34*multiply, 20*multiply});
                        list.push_back(c);
                        break;
                    }
                    case CollisionId_E_COLONY:
                    {
                        float multiply = 20;
                        c = new Collision();
                        c->push_back({2*multiply, 42*multiply, 126*multiply, 60*multiply});
                        c->push_back({32*multiply, 16*multiply, 65*multiply, 26*multiply});
                        c->push_back({43*multiply, 104*multiply, 46*multiply, 67*multiply});
                        list.push_back(c);
                        break;
                    }
                    case CollisionId_E_SNAKE:
                    {
                        float multiply = 20;
                        c = new Collision();
                        c->push_back({2*multiply, 42*multiply, 181*multiply, 36*multiply});
                        c->push_back({113*multiply, 4*multiply, 92*multiply, 30*multiply});
                        c->push_back({34*multiply, 65*multiply, 186*multiply, 9*multiply});
                        c->push_back({52*multiply, 68*multiply, 120*multiply, 27*multiply});
                        c->push_back({97*multiply, 97*multiply, 16*multiply, 15*multiply});
                        list.push_back(c);
                        break;
                    }
                    case CollisionId_E_LASTBOSS:
                    {
                        float multiply = 5;
                        c = new Collision();
                        c->push_back({191*multiply, 0*multiply, 116*multiply, 503*multiply});
                        c->push_back({59*multiply, 64*multiply, 407*multiply, 307*multiply});
                        c->push_back({7*multiply, 135*multiply, 496*multiply, 238*multiply});
                        list.push_back(c);
                        break;
                    }
                    case CollisionIdStart:
                    case CollisionIdNone:
                        c = new Collision();
                        list.push_back(c);
                        break;
                    default:
                        assert(0);
                        HDebug(@"invalid collision id %d", i);
                        break;
                }
            }
            
            // convert to pixel to real size
            for (CollisionList::iterator it = list.begin(); it != list.end(); ++it)
            {
                Collision* c = *it;
                for (Collision::iterator it2 = c->begin(); it2 != c->end(); ++it2)
                {
                    (*it2).point.x = PXL2REAL((*it2).point.x);
                    (*it2).point.y = PXL2REAL((*it2).point.y);
                    (*it2).size.width = PXL2REAL((*it2).size.width);
                    (*it2).size.height = PXL2REAL((*it2).size.height);
                }
            }
        }
        
        CollisionManager():
        list(NULL)
        {
            
        }
    };
    
}

#endif /* defined(__Shooter__HCollision__) */
