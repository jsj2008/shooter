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
                    case CollisionId_BulletNormal:
                        c = new Collision();
                        c->push_back({-6, -6, 172, 172});
                        list.push_back(c);
                        break;
                    case CollisionId_BulletMagic:
                        c = new Collision();
                        c->push_back({0, 0, 200, 200});
                        list.push_back(c);
                        break;
                    case CollisionId_BulletVulcan:
                        c = new Collision();
                        c->push_back({-2, -2, 64, 64});
                        list.push_back(c);
                        break;
                    case CollisionId_P_ROBO1:
                        c = new Collision();
                        c->push_back({20, 20, 88, 88});
                        list.push_back(c);
                        break;
                    case CollisionId_E_SENKAN:
                        c = new Collision();
                        c->push_back({220, 200, 1530, 350});
                        list.push_back(c);
                        break;
                    case CollisionId_E_ROBO2:
                        c = new Collision();
                        c->push_back({30, 30, 196, 196});
                        list.push_back(c);
                        break;
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
