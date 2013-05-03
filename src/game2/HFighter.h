//
//  HFighter.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/03.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__HFighter__
#define __Shooter__HFighter__

#include <iostream>
#include "HGameCommon.h"
#include "HWeapon.h"

#include <list>

namespace hg {

    ////////////////////
    // Fighter
    static int SPRITE_INDEX_TABLE[359] = {};
    typedef std::list<Weapon*> WeaponList;
    class Fighter : public Actor
    {
    public:
        typedef Actor base;
        
        Fighter():
        base(),
        textureSrcOffset(0,0),
        textureSrcSize(0,0),
        aspectDegree(0),
        speed(0),
        textureName(""),
        life(0),
        lifeMax(0)
        {
        }
        
        ~Fighter()
        {
            for (WeaponList::iterator it = weaponList.begin(); it != weaponList.end(); ++it)
            {
                (*it)->release();
            }
            weaponList.clear();
            pSprite->release();
        }
        
        void init(HGNode* layerParent)
        {
            base::init(layerParent);
            
            // 種類別の初期化
            {
                textureName = "p_robo1.png";
                textureSrcOffset.x = 0;
                textureSrcOffset.y = 0;
                textureSrcSize.width = 16;
                textureSrcSize.height = 16;
                setSizeByPixel(128, 128);
                speed = v(0.6);
                life = lifeMax = 100;
                Weapon* wp = new Weapon();
                wp->init(WEAPON_TYPE_NORMAL, BULLET_TYPE_NORMAL , 0, 0);
                weaponList.push_back(wp);
            }
            
            pSprite = new HGSprite();
            pSprite->setType(SPRITE_TYPE_BILLBOARD);
            pSprite->init(textureName);
            pSprite->setScale(getWidth(), getHeight());
            getNode()->addChild(pSprite);
            
            setAspectDegree(0);
            
            // テーブル初期化
            static bool isTableInitialized = false;
            if (!isTableInitialized)
            {
                int index = 0;
                for (int i = 0; i < 360; i++)
                {
                    index = 0;
                    if (i >= 338 || i <= 23) {
                        index = 2;
                    } else if (i >= 23 && i <= 68) {
                        index = 3;
                    } else if (i >= 68 && i <= 113) {
                        index = 4;
                    } else if (i >= 113 && i <= 158) {
                        index = 5;
                    } else if (i >= 158 && i <= 203) {
                        index = 6;
                    } else if (i >= 203 && i <= 248) {
                        index = 7;
                    } else if (i >= 248 && i <= 293) {
                        index = 0;
                    } else if (i >= 293 && i <= 338) {
                        index = 1;
                    }
                    SPRITE_INDEX_TABLE[i] = index;
                }
            }
            
        }
        void setAspectDegree(float degree)
        {
            aspectDegree = degree;
            int spIdx = getSpriteIndex(aspectDegree + 0.5);
            int x = textureSrcSize.width * spIdx + textureSrcOffset.x;
            pSprite->setTextureRect(x - 1, textureSrcOffset.y, textureSrcSize.width, textureSrcSize.height);
        }
        
        int getLife()
        {
            return life;
        }
        
        void setLife(int life)
        {
            this->life = life;
        }
        
        void setMaxLife(int life)
        {
            this->lifeMax = life;
        }
        
        float getAspectDegree()
        {
            return aspectDegree;
        }
        
        void fire()
        {
            for (WeaponList::iterator it = weaponList.begin(); it != weaponList.end(); ++it)
            {
                (*it)->fire(this, this->aspectDegree);
            }
        }
    public:
        float speed;
        float aspectDegree;
    private:
        int life;
        int lifeMax;
        HGPoint textureSrcOffset;
        HGSize textureSrcSize;
        std::string textureName;
        WeaponList weaponList;
        HGSprite* pSprite;
        
        int getSpriteIndex(int i)
        {
            while (i < 0)
            {
                i += 360;
            }
            i = i % 360;
            return SPRITE_INDEX_TABLE[i];
        }
        
    };
}
#endif /* defined(__Shooter__HFighter__) */
