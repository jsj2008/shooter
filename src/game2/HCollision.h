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
    typedef int CollisionId;
    static CollisionManager* pCollisionManager = NULL;
    class CollisionManager
    {
        typedef std::vector<HGRect> Collision;
        typedef std::vector<Collision*> CollisionList;
    public:
        inline static CollisionManager* sharedCollisionManager()
        {
            if (!pCollisionManager)
            {
                pCollisionManager = new CollisionManager();
                pCollisionManager->init();
            }
            return pCollisionManager;
        }
        inline bool isIntersect(CollisionId& ida, Vector& posa, HGSize& sizea,
                                CollisionId& idb, Vector& posb, HGSize& sizeb)
        {
            assert(ida >= 0);
            assert(ida < list.size());
            assert(idb >= 0);
            assert(idb < list.size());
            Collision* cola = list[ida];
            Collision* colb = list[idb];
            int lena = cola->size();
            int lenb = colb->size();
            float offxa = posa.x - sizea.width/2;
            float offya = posa.y - sizeb.height/2;
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
        inline void addDebugMark(CollisionId ida, HGNode* node, float width, float height)
        {
            assert(ida >= 0);
            assert(ida < list.size());
            Collision* col = list[ida];
            for (Collision::iterator it = col->begin(); it != col->end(); ++it)
            {
                HGSprite* spr = new HGSprite();
                spr->init("square.png");
                spr->shouldRenderAsAlphaMap(true);
                spr->setBlendFunc(GL_ALPHA, GL_ALPHA);
                spr->setColor({1,0,0,0.5});
                spr->setScale((*it).size.width, (*it).size.height);
                spr->setPosition(-width/2 + (*it).point.x + (*it).size.width/2, -height/2 + (*it).point.y + (*it).size.height/2);
                spr->setType(SPRITE_TYPE_BILLBOARD);
                node->addChild(spr);
                spr->release();
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
            for (int i = 0; i <= 4; i++)
            {
                switch (i) {
                    case 0:
                        c = new Collision();
                        c->push_back({10, 10, 44, 44});
                        list.push_back(c);
                        break;
                    case 1:
                        c = new Collision();
                        c->push_back({-6, -6, 96, 96});
                        list.push_back(c);
                        break;
                    case 2:
                        c = new Collision();
                        c->push_back({20, 20, 88, 88});
                        list.push_back(c);
                        break;
                    case 3:
                        c = new Collision();
                        c->push_back({280, 230, 1700, 390});
                        list.push_back(c);
                        break;
                    case 4:
                        c = new Collision();
                        c->push_back({30, 30, 196, 196});
                        list.push_back(c);
                        break;
                    default:
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
