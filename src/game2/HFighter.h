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
#include "HCollision.h"
#include "ExplodeAnimeProcess.h"
#include "ObjectAL.h"

#include <list>

namespace hg {
    
    static int SPRITE_INDEX_TABLE[359] = {};
    typedef std::list<Weapon*> WeaponList;
    class Fighter : public Actor
    {
        const int LIFE_BAR_WIDTH = PXL2REAL(260);
        const int LIFE_BAR_HEIGHT = PXL2REAL(70);
    public:
        typedef Actor base;
        
        Fighter():
        base(),
        textureSrcOffset(0,0),
        textureSrcSize(0,0),
        aspectDegree(270),
        speed(0),
        textureName(""),
        life(0),
        lifeMax(0),
        processOwner(NULL),
        pLifeColorNode(NULL),
        pShieldNode(NULL),
        pShieldColorNode(NULL),
        pShieldBackColorNode(NULL),
        side(SideTypeEnemy),
        isInitialized(false),
        _isShip(false),
        _isPlayer(false),
        pFighterHated(NULL),
        explodeProcessCount(0),
        pFighterInfo(NULL),
        shouldUpdateInfo(false)
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
            processOwner->release();
            if (pLifeColorNode)
            {
                pLifeColorNode->release();
            }
            if (pShieldNode)
            {
                pShieldNode->release();
            }
            if (pShieldColorNode)
            {
                pShieldColorNode->release();
            }
            if (pShieldBackColorNode)
            {
                pShieldBackColorNode->release();
            }
            if (pFighterHated)
            {
                pFighterHated->release();
            }
        }
        inline void setActive(bool isActive)
        {
            base::setActive(isActive);
        }
        inline bool isShip()
        {
            return _isShip;
        }
        inline FighterInfo* getFighterInfo()
        {
            return pFighterInfo;
        }
        inline void init(HGNode* layerParent, SideType side, FighterInfo* pInfo)
        {
            base::init(layerParent);
            this->side = side;
            this->type = pInfo->fighterType;
            processOwner = new HGProcessOwner();
            processOwner->retain();
            this->pFighterInfo = pInfo;
            
            // init
            textureName = pInfo->textureName;
            textureSrcOffset = {pInfo->textureSrcOffsetX, pInfo->textureSrcOffsetY};
            textureSrcSize = {pInfo->textureSrcWidth, pInfo->textureSrcHeight};
            setSizeByPixel(pInfo->showPixelWidth, pInfo->showPixelHeight);
            setCollisionId(pInfo->collisionId);
            this->_isShip = pInfo->isShip;
            
            life = pInfo->life;
            lifeMax = pInfo->lifeMax;
            shield = pInfo->shield;
            shieldMax = pInfo->shieldMax;
            speed = pInfo->speed;
            
            for (WeaponInfoList::iterator it = pInfo->weaponList.begin(); it != pInfo->weaponList.end(); ++it)
            {
                Weapon* wp = new Weapon();
                wp->init((*it).weaponType,
                         (*it).bulletType,
                         (*it).x,
                         (*it).y,
                         (*it).speed,
                         ceil(pInfo->power*(*it).bulletPower),
                         (*it).fireInterval);
                weaponList.push_back(wp);
                wp->retain();
            }
            
            pSprite = new HGSprite();
            pSprite->setType(SPRITE_TYPE_BILLBOARD);
            pSprite->init(textureName);
            pSprite->setScale(0, getHeight());
            pSprite->setTextureRect(textureSrcOffset.x, textureSrcOffset.y, textureSrcSize.width, textureSrcSize.height);
            pSprite->retain();
            getNode()->addChild(pSprite);
            
            {
                // サイズ変更
                HGProcessOwner* po = new HGProcessOwner();
                ChangeScaleProcess* csp = new ChangeScaleProcess();
                csp->init(po, pSprite, getWidth(), getHeight(), f(30));
                csp->setEaseFunc(&ease_out);
                HGProcessManager::sharedProcessManager()->addProcess(csp);
            }
            
            // life
            if (side == SideTypeFriend)
            {
                // back
                ColorNode* pColorNode = new ColorNode();
                pColorNode->init((Color){1,0,0,1}, LIFE_BAR_WIDTH, LIFE_BAR_HEIGHT);
                pColorNode->setType(SPRITE_TYPE_BILLBOARD);
                pColorNode->setPosition(0, -1 * getHeight()/2);
                getNode()->addChild(pColorNode);
                
                // bar
                pLifeColorNode = new ColorNode();
                pLifeColorNode->init((Color){0,1,0,1}, LIFE_BAR_WIDTH, LIFE_BAR_HEIGHT);
                pLifeColorNode->setType(SPRITE_TYPE_BILLBOARD);
                pLifeColorNode->setPosition(0, -1 * getHeight()/2);
                pLifeColorNode->retain();
                getNode()->addChild(pLifeColorNode);
            }
            
            {
                if (shield > 0)
                {
                    // シールド
                    pShieldNode = new AlphaMapSprite();
                    if (side == SideTypeFriend)
                    {
                        pShieldNode->init("tunelring.png", (Color){0.5, 0.5, 1, 1.0});
                        pShieldNode->setScale(getWidth()+PXL2REAL(250), getHeight()+PXL2REAL(250));
                        pShieldNode->retain();
                        getNode()->addChild(pShieldNode);
                        {
                            // 色変更
                            HGProcessOwner* po = new HGProcessOwner();
                            ChangeSpriteColorProcess* cscp = new ChangeSpriteColorProcess();
                            Color c = {0.1, 0.1, 0.5, 0.7};
                            cscp->init(po, pShieldNode, c, f(50));
                            HGProcessManager::sharedProcessManager()->addProcess(cscp);
                        }
                    }
                    else
                    {
                        pShieldNode->init("tunelring.png", (Color){1.0, 0.25, 0.25, 1.0});
                        pShieldNode->setScale(getWidth()+PXL2REAL(250), getHeight()+PXL2REAL(250));
                        pShieldNode->retain();
                        getNode()->addChild(pShieldNode);
                        {
                            // 色変更
                            HGProcessOwner* po = new HGProcessOwner();
                            ChangeSpriteColorProcess* cscp = new ChangeSpriteColorProcess();
                            Color c = {0.5, 0.2, 0.2, 0.7};
                            cscp->init(po, pShieldNode, c, f(50));
                            HGProcessManager::sharedProcessManager()->addProcess(cscp);
                        }
                    }
                    
                    // シールドゲージ
                    if (side == SideTypeFriend)
                    {
                        // back
                        pShieldBackColorNode = new ColorNode();
                        pShieldBackColorNode->init((Color){1.0,0,0,1}, LIFE_BAR_WIDTH, LIFE_BAR_HEIGHT);
                        pShieldBackColorNode->setType(SPRITE_TYPE_BILLBOARD);
                        pShieldBackColorNode->setPosition(0, -1 * getHeight()/2 + LIFE_BAR_HEIGHT*4);
                        pShieldBackColorNode->retain();
                        getNode()->addChild(pShieldBackColorNode);
                        
                        // bar
                        pShieldColorNode = new ColorNode();
                        pShieldColorNode->init((Color){0.3,0.3,1,1}, LIFE_BAR_WIDTH, LIFE_BAR_HEIGHT);
                        pShieldColorNode->setType(SPRITE_TYPE_BILLBOARD);
                        pShieldColorNode->setPosition(0, -1 * getHeight()/2 + LIFE_BAR_HEIGHT*4);
                        pShieldColorNode->retain();
                        getNode()->addChild(pShieldColorNode);
                    }
                    
                }
                
            }
            
            setAspectDegree(0);
            
#if IS_DEBUG_COLLISION
            CollisionManager::sharedCollisionManager()->addDebugMark(getCollisionId(), getNode(), getWidth(), getHeight());
#endif
            
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
            updateLifeBar();
            updateShieldBar();
            isInitialized = true;
        }
        inline void setAspectDegree(float degree)
        {
            aspectDegree = degree;
            if (!_isShip)
            {
                int spIdx = getSpriteIndex(aspectDegree + 0.5);
                int x = textureSrcSize.width * spIdx + textureSrcOffset.x;
                pSprite->setTextureRect(x - 1, textureSrcOffset.y, textureSrcSize.width, textureSrcSize.height);
            }
        }
        inline SideType getSide()
        {
            return side;
        }
        
        inline int getLife()
        {
            return life;
        }
        inline float getLifeRatio()
        {
            return (float)life/(float)pFighterInfo->lifeMax;
        }
        inline void setPlayer()
        {
            _isPlayer = true;
        }
        inline bool isPlayer()
        {
            return _isPlayer;
        }
        inline void setLife(int life)
        {
            this->life = life;
            updateLifeBar();
            shouldUpdateInfo = true;
        }
        inline void noticeAttackedBy(Actor* pFighter)
        {
            assert(pFighter);
            if (pFighterHated)
            {
                pFighterHated->release();
                pFighterHated = NULL;
            }
            if (rand(0, 10) <= 3)
            {
                pFighterHated = static_cast<Fighter*>(pFighter);
                if (pFighterHated)
                {
                    pFighterHated->retain();
                }
            }
        }
        
        inline Fighter* getFighterHated()
        {
            if (pFighterHated)
            {
                if (pFighterHated->getLife() <= 0 || !pFighterHated->isActive())
                {
                    pFighterHated->release();
                    pFighterHated = NULL;
                }
            }
            return pFighterHated;
        }
        
        inline void addLife(int life)
        {
            if (this->life <= 0)
            {
                return;
            }
            if (life == 0)
            {
                return;
            }
            if (life < 0 && hasShield())
            {
                shield += life;
                if (shield <= 0)
                {
                    shield = 0;
                    if (pShieldNode)
                    {
                        pShieldNode->removeFromParent();
                        pShieldNode->release();
                        pShieldNode = NULL;
                    }
                    
                    if (pShieldColorNode)
                    {
                        pShieldColorNode->removeFromParent();
                        pShieldColorNode->release();
                        pShieldColorNode = NULL;
                    }
                    
                    if (pShieldBackColorNode)
                    {
                        pShieldBackColorNode->removeFromParent();
                        pShieldBackColorNode->release();
                        pShieldBackColorNode = NULL;
                    }
                }
                else
                {
                    updateShieldBar();
                }
            }
            else
            {
                this->life += life;
                if (this->life <= 0)
                {
                    this->life = 0;
                }
                else if (this->life > this->lifeMax)
                {
                    this->life = this->lifeMax;
                }
                updateLifeBar();
            }
            shouldUpdateInfo = true;
        }
        
        // 毎フレーム呼び出される
        inline void tick()
        {
            // shield check
            if (isActive())
            {
                if (hasShield())
                {
                    double now = getNowTime();
                    if (now - lastTimeShieldHeal >= 1)
                    {
                        healShield();
                        lastTimeShieldHeal = now;
                    }
                }
                
            }
            if (shouldUpdateInfo)
            {
                shouldUpdateInfo = false;
                pFighterInfo->life = life;
                pFighterInfo->shield = shield;
            }
            
            // data copy
            pFighterInfo->life = life;
            pFighterInfo->shield = shield;
            
        }
        
        inline void showTracks(float rad)
        {
            // 軌跡
            if (side == SideTypeFriend && rand(0, 100) <= 20)
            {
                for (int i = 0; i < 2; i++)
                {
                    float r = toRad(rand(0, 359));
                    float tx = cos(r) * getWidth() + getPositionX();
                    float ty = sin(r) * getHeight() + getPositionY();
                    {
                        AlphaMapSprite* pSpr = new AlphaMapSprite();
                        float r = rand(50, 100) * 0.01;
                        float g = rand(50, 100) * 0.01;
                        float b = rand(50, 100) * 0.01;
                        pSpr->init("star_cross.png", (Color){r, g, b, 1.0});
                        //pSpr->init("star_cross.png", (Color){0.9, 0.9, 1.0, 1.0});
                        pSpr->setPosition(tx, ty);
                        float size = rand(PXL2REAL(0), PXL2REAL(30));
                        pSpr->setScale(size, size);
                        pSpr->setRotateZ(toRad(rand(0, 359)));
                        pLayerEffect->addChild(pSpr);
                        /*{
                            // 回転
                            HGProcessOwner* po = new HGProcessOwner();
                            RotateNodeProcess* rnp = new RotateNodeProcess();
                            Vector r = Vector(0,0,-9300);
                            rnp->init(po, pSpr, r, f(40));
                            rnp->setEaseFunc(&ease_out);
                            HGProcessManager::sharedProcessManager()->addProcess(rnp);
                        }*/
                        {
                            // 色
                            HGProcessOwner* po = new HGProcessOwner();
                            ChangeSpriteColorProcess* rnp = new ChangeSpriteColorProcess();
                            Color c = {g, r, b, 1.0};
                            rnp->init(po, pSpr, c, f(10));
                            rnp->setEaseFunc(&ease_out);
                            HGProcessManager::sharedProcessManager()->addProcess(rnp);
                        }
                        {
                            float size = rand(PXL2REAL(120), PXL2REAL(250));
                            HGProcessOwner* po = new HGProcessOwner();
                            // 拡大
                            ChangeScaleProcess* ssp = new ChangeScaleProcess();
                            ssp->init(po, pSpr, size, size, f(10));
                            ssp->setEaseFunc(&ease_out);
                            
                            // 縮小
                            ChangeScaleProcess* ssp2 = new ChangeScaleProcess();
                            ssp2->init(po, pSpr, 0, 0, f(25));
                            ssp2->setEaseFunc(&ease_in);
                            ssp->setNext(ssp2);
                            
                            // 削除
                            NodeRemoveProcess* nrp = new NodeRemoveProcess();
                            nrp->init(po, pSpr);
                            ssp2->setNext(nrp);
                            
                            // プロセス開始
                            HGProcessManager::sharedProcessManager()->addProcess(ssp);
                        }
                    }
                }
            
            }
        }
        
        inline void setMaxLife(int life)
        {
            this->lifeMax = life;
        }
        
        inline float getAspectDegree()
        {
            return aspectDegree;
        }
        
        inline void explode()
        {
            [[OALSimpleAudio sharedInstance] playEffect:SE_BOM];
            CallFunctionRepeadedlyProcess<Fighter>* cfrp = new CallFunctionRepeadedlyProcess<Fighter>();
            HGProcessOwner* hpo = new HGProcessOwner();
            cfrp->init(hpo, &Fighter::explodeProcess, this);
            HGProcessManager::sharedProcessManager()->addProcess(cfrp);
        }
        
        // 撤収する
        // エフェクトだしてから消え去る
        inline void disappear()
        {
            if (isDisappearing)
            {
                return;
            }
            isDisappearing = true;
            // 光
            {
                AlphaMapSprite* pSpr = new AlphaMapSprite();
                pSpr->init("corona.png", (Color){0.8, 0.8, 1.0, 1.0});
                pSpr->setPosition(this->getPositionX(), this->getPositionY());
                pSpr->setScale(0, 0);
                pSpr->setRotateZ(rand(0, 359) * M_PI/180);
                pLayerEffect->addChild(pSpr);
                
                // 回転
                {
                    HGProcessOwner* po = new HGProcessOwner();
                    RotateNodeProcess* rnp = new RotateNodeProcess();
                    Vector r = Vector(0,0,1300);
                    rnp->init(po, pSpr, r, f(40));
                    rnp->setEaseFunc(&ease_out);
                    HGProcessManager::sharedProcessManager()->addProcess(rnp);
                }
                
                // 拡大
                {
                    HGProcessOwner* po = new HGProcessOwner();
                    ChangeScaleProcess* ssp = new ChangeScaleProcess();
                    ssp->init(po, pSpr, PXL2REAL(1500), PXL2REAL(1500), f(10));
                    ssp->setEaseFunc(&ease_out);
                    
                    // 縮小
                    ChangeScaleProcess* ssp2 = new ChangeScaleProcess();
                    ssp2->init(po, pSpr, 0, 0, 5);
                    ssp2->setEaseFunc(&ease_in);
                    ssp->setNext(ssp2);
                    
                    // 撤収実行
                    CallFunctionRepeadedlyProcess<Fighter>* cfrp = new CallFunctionRepeadedlyProcess<Fighter>();
                    cfrp->init(po, &Fighter::disappearDo, this);
                    ssp2->setNext(cfrp);
                    
                    // 削除
                    NodeRemoveProcess* nrp = new NodeRemoveProcess();
                    nrp->init(po, pSpr);
                    cfrp->setNext(nrp);
                    
                    // プロセス開始
                    HGProcessManager::sharedProcessManager()->addProcess(ssp);
                }
            }
            
            // 光
            {
                AlphaMapSprite* pSpr = new AlphaMapSprite();
                pSpr->init("wavering.png", (Color){1.0, 0.5, 0.5, 1.0});
                pSpr->setPosition(this->getPositionX(), this->getPositionY());
                pSpr->setScale(0, 0);
                pSpr->setRotateZ(rand(0, 359) * M_PI/180);
                pLayerEffect->addChild(pSpr);
                
                {
                    {
                        // 回転
                        HGProcessOwner* po = new HGProcessOwner();
                        RotateNodeProcess* rnp = new RotateNodeProcess();
                        Vector r = Vector(0,0,-1300);
                        rnp->init(po, pSpr, r, f(40));
                        rnp->setEaseFunc(&ease_in);
                        HGProcessManager::sharedProcessManager()->addProcess(rnp);
                    }
                    
                    {
                        // 拡大
                        HGProcessOwner* po = new HGProcessOwner();
                        ChangeScaleProcess* ssp = new ChangeScaleProcess();
                        ssp->init(po, pSpr, PXL2REAL(1000), PXL2REAL(1000), 16);
                        ssp->setEaseFunc(&ease_in_out);
                        
                        // プロセス開始
                        HGProcessManager::sharedProcessManager()->addProcess(ssp);
                    }
                    
                    {
                        // 透明化
                        HGProcessOwner* po2 = new HGProcessOwner();
                        SpriteChangeOpacityProcess* scop = new SpriteChangeOpacityProcess();
                        scop->setEaseFunc(&ease_in_out);
                        scop->init(po2, pSpr, 0, 8);
                        scop->setWaitFrame(f(10));
                        
                        // 削除
                        NodeRemoveProcess* nrp = new NodeRemoveProcess();
                        nrp->init(po2, pSpr);
                        scop->setNext(nrp);
                        
                        // プロセス開始
                        HGProcessManager::sharedProcessManager()->addProcess(scop);
                    }
                }
            }
            
        }
        
        // call function repeatedly processから呼び出される
        inline bool explodeProcess()
        {
            if (this->isActive() == false)
            {
                if (this->getNode()->hasParent())
                {
                    this->getNode()->removeFromParent();
                }
                return true;
            }
            explodeProcessCount++;
            if (_isShip)
            {
                if (explodeProcessCount > 90)
                {
                    pSprite->setOpacity(pSprite->getOpacity()*0.9);
                }
                if (explodeProcessCount > 100)
                {
                    this->setActive(false);
                    this->getNode()->removeFromParent();
                    return true;
                }
                if (rand(0, 10) > 3)
                {
                    if (numOfEffect <= EFFECT_NUM) {
                        ExplodeAnimeProcess* eap = new ExplodeAnimeProcess();
                        HGProcessOwner* hpo = new HGProcessOwner();
                        float x = rand(getPositionX() - getWidth()/2, getPositionX() + getWidth()/2);
                        float y = rand(getPositionY() - getHeight()/2, getPositionY() + getHeight()/2);
                        Vector position(x, y, getPositionZ());
                        eap->init(hpo, position, pLayerEffect);
                        HGProcessManager::sharedProcessManager()->addProcess(eap);
                    }
                }
            }
            else
            {
                if (explodeProcessCount > 20)
                {
                    pSprite->setOpacity(pSprite->getOpacity()*0.9);
                }
                if (explodeProcessCount > 30)
                {
                    this->setActive(false);
                    this->getNode()->removeFromParent();
                    return true;
                }
                if (rand(0, 10) > 7)
                {
                    if (numOfEffect <= EFFECT_NUM) {
                        ExplodeAnimeProcess* eap = new ExplodeAnimeProcess();
                        HGProcessOwner* hpo = new HGProcessOwner();
                        float x = rand(getPositionX() - getWidth()/2, getPositionX() + getWidth()/2);
                        float y = rand(getPositionY() - getHeight()/2, getPositionY() + getHeight()/2);
                        Vector position(x, y, getPositionZ());
                        eap->init(hpo, position, pLayerEffect);
                        HGProcessManager::sharedProcessManager()->addProcess(eap);
                    }
                }
                
            }
            return false;
        }
        
        inline void fire(Fighter* pTarget, int cpu_lv)
        {
            float x = this->getPositionX();
            float y = this->getPositionY();
            float tx = pTarget->getPositionX();
            float ty = pTarget->getPositionY();
            
            // 狙い誤差
            float diff_ratio = (CPU_LV_MAX - cpu_lv);
            if (rand(0,1) == 0) {
                diff_ratio *= -1;
            }
            int diff_amount = rand(0, 30);
            float diff = (diff_ratio * diff_amount * 0.01);
            
            for (WeaponList::iterator it = weaponList.begin(); it != weaponList.end(); ++it)
            {
                if (rand(0, 10) < 2)
                {
                    float wx = (*it)->getRelativeX();
                    float wy = (*it)->getRelativeY();
                    // tgの方向を向く
                    float r = atan2f(tx - (x + wx),
                                     ty - (y + wy));
                    float d = toDeg(r) - 90 + diff;
                    (*it)->setAspect(d);
                }
                (*it)->fire(this, side, _isPlayer);
            }
        }
        
        inline void fire()
        {
            bool isFired = false;
            for (WeaponList::iterator it = weaponList.begin(); it != weaponList.end(); ++it)
            {
                (*it)->setAspect(this->aspectDegree);
                bool chk = (*it)->fire(this, side, _isPlayer);
                if (chk) {
                    isFired = true;
                }
            }
            if (isFired) {
                [[OALSimpleAudio sharedInstance] playEffect:SE_GUN];
            }
        }
        
        inline HGProcessOwner* getProcessOwner()
        {
            return this->processOwner;
        }
        
        inline float getSpeed()
        {
            return speed;
        }
        
        inline bool hasShield()
        {
            return shield > 0;
        }
        
        inline float getShieldRatio()
        {
            return (float)shield/(float)pFighterInfo->shieldMax;
        }
        
        inline HGRect getShieldRect()
        {
            assert(hasShield());
            HGRect r = {this->getPositionX() - this->getWidth()/2 - SHILD_SIZE_GAP, this->getPositionY() - this->getHeight()/2 - SHILD_SIZE_GAP,
                       this->getWidth() + SHILD_SIZE_GAP, this->getHeight() + SHILD_SIZE_GAP};
            return r;
        }
        
    private:
        
        inline bool disappearDo()
        {
            if (SideTypeFriend == side)
            {
                if (pFighterInfo->isOnBattleGround)
                {
                    return true;
                }
                friendFighterList.removeActor(this);
            }
            else
            {
                enemyFighterList.removeActor(this);
            }
            this->setActive(false);
            if (this->getNode()->hasParent())
            {
                this->getNode()->removeFromParent();
            }
            return true;
        }
        
        inline void updateLifeBar()
        {
            if (side == SideTypeFriend)
            {
                float ratio = (float)life/(float)lifeMax;
                float w = (LIFE_BAR_WIDTH * ratio);
                pLifeColorNode->setScaleX(w);
                pLifeColorNode->setPositionX(LIFE_BAR_WIDTH/2.0*-1.0 + w/2.0);
            }
        }
        
        inline void updateShieldBar()
        {
            if (side == SideTypeFriend && hasShield())
            {
                float ratio = (float)shield/(float)shieldMax;
                float w = (LIFE_BAR_WIDTH * ratio);
                pShieldColorNode->setScaleX(w);
                pShieldColorNode->setPositionX(LIFE_BAR_WIDTH/2.0*-1.0 + w/2.0);
            }
        }
        
        // 1秒ごとに呼び出される
        inline void healShield()
        {
            assert(hasShield());
            shield += ceil(shieldMax*0.005);
            if (shield > shieldMax)
            {
                shield = shieldMax;
                updateShieldBar();
            }
            shouldUpdateInfo = true;
        }
        
        bool shouldUpdateInfo;
        float speed;
        float aspectDegree;
        int life;
        int lifeMax;
        HGPoint textureSrcOffset;
        HGSize textureSrcSize;
        std::string textureName;
        WeaponList weaponList;
        HGSprite* pSprite;
        AlphaMapSprite* pShieldNode;
        ColorNode* pLifeColorNode;
        ColorNode* pShieldColorNode;
        ColorNode* pShieldBackColorNode;
        SideType side;
        int type;
        HGProcessOwner* processOwner;
        bool isInitialized;
        bool _isShip;
        int explodeProcessCount;
        float shield;
        float shieldMax;
        double lastTimeShieldHeal = 0;
        bool _isPlayer;
        Fighter* pFighterHated;
        FighterInfo* pFighterInfo;
        bool isDisappearing = false;
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
    
    // global function
    float getPositionX(Fighter* fighter);
    float getPositionY(Fighter* fighter);
    void retainFighter(Fighter* fighter);
    void releaseFighter(Fighter* fighter);
    
}
#endif /* defined(__Shooter__HFighter__) */
