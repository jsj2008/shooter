#include "HGame.h"
#include <list>
#include <stack>

#include "HGameCommon.h"
#include "HGLES.h"
#include "HGLGraphics2D.h"

#include "HGameEngine.h"
#include "HActor.h"
#include "HBullet.h"
#include "HWeapon.h"
#include "HFighter.h"
#include "ControlPlayerProcess.h"
#include "ControlEnemyProcess.h"
#include "HActorList.h"
#include "HitAnimeProcess.h"
#include "ExplodeAnimeProcess.h"
#include "CellManager.h"

#include <boost/shared_ptr.hpp>
#include <list>
#include <algorithm>

#include "HGLObject3D.h"
#include "HGLObjLoader.h"
#include "UserData.h"

namespace hg {
    
    class Actor;
    class Fighter;
    class Weapon;
    class Bullet;
    class BulletMoveProcess;
    
    ////////////////////
    // typedef
    
    
    ////////////////////
    // Rader
    class Rader : public HGObject
    {
        typedef std::list<HGNode*> NodeList;
        const float RADER_CELL_NUM = 10;
        const float RADER_SCALE = 5;
        const float RADER_CELL_SCALE = RADER_SCALE/10.0;
    public:
        Rader()
        {
            
        }
        ~Rader()
        {
            for (NodeList::iterator it = nodeList.begin(); it != nodeList.end(); ++it)
            {
                (*it)->release();
            }
            nodeList.clear();
            if (pRootNode)
            {
                pRootNode->release();
            }
        }
        void init(HGNode* pParentNode)
        {
            pRootNode = new HGNode();
            pRootNode->retain();
            pParentNode->addChild(pRootNode);
            pRootNode->setPosition(13.5, 7.5);
            
            HGSprite* pSprite = new HGSprite();
            pSprite->init("radergrid.png");
            pSprite->setPosition(RADER_SCALE/2.0 - RADER_CELL_SCALE/2.0, RADER_SCALE/2.0 - RADER_CELL_SCALE/2.0);
            pSprite->setScale(RADER_SCALE, RADER_SCALE);
            pRootNode->addChild(pSprite);
            
            // フィールド境界
            {
                AlphaColorNode* p = new AlphaColorNode();
                p->init((Color){0, 0.5, 0, 0.3}, RADER_SCALE, RADER_SCALE);
                p->setBlendFunc(GL_SRC_ALPHA, GL_ONE);
                p->setPosition(RADER_SCALE/2.0 - RADER_CELL_SCALE/2.0, RADER_SCALE/2.0 - RADER_CELL_SCALE/2.0);
                pRootNode->addChild(p);
                
                {
                    // 色変更
                    HGProcessOwner* po = new HGProcessOwner();
                    ChangeSpriteColorProcess* cscp = new ChangeSpriteColorProcess();
                    Color c = {0.1, 0.6, 0.1, 0.5};
                    cscp->init(po, p, c, f(50));
                    cscp->setEaseFunc(&ease_linear);
                    HGProcessManager::sharedProcessManager()->addProcess(cscp);
                }
            
            }
            {
                HGSprite* pSprite = new HGSprite();
                pSprite->init("rect.png");
                pSprite->setblendcolor({0.9,1,0.9,1});
                pSprite->setScale(RADER_SCALE*2, RADER_SCALE*2);
                pSprite->setPosition(RADER_SCALE/2.0 - RADER_CELL_SCALE/2.0, RADER_SCALE/2.0 - RADER_CELL_SCALE/2.0);
                pRootNode->addChild(pSprite);
                
            }
            
            {
                // サイズ変更
                pRootNode->setScaleX(0);
                HGProcessOwner* po = new HGProcessOwner();
                ChangeScaleProcess* csp = new ChangeScaleProcess();
                csp->init(po, pRootNode, 1, 1, f(30));
                csp->setEaseFunc(&ease_out);
                HGProcessManager::sharedProcessManager()->addProcess(csp);
            }
            
        }
        void updateRader(CellManager<Fighter>& enemyCellManager, CellManager<Fighter>& friendCellManager)
        {
            if (nodeList.size() > 0)
            {
                for (NodeList::iterator it = nodeList.begin(); it != nodeList.end(); ++it)
                {
                    (*it)->removeFromParent();
                    (*it)->release();
                }
                nodeList.clear();
            }
            
            for (int i = 0; i < RADER_CELL_NUM; i++)
            {
                for (int j = 0; j < RADER_CELL_NUM; j++)
                {
                    if (enemyCellManager.getNumberInCell(i, j) > 0)
                    {
                        ColorNode* p = new ColorNode();
                        p->init((Color){0.6, 0, 0, 1}, RADER_CELL_SCALE, RADER_CELL_SCALE);
                        p->setPosition((float)i * RADER_CELL_SCALE, (float)j * RADER_CELL_SCALE);
                        p->retain();
                        nodeList.push_back(p);
                        pRootNode->addChild(p);
                    }
                }
            }
            
            // 味方を表示
            {
                Color c = {0.0,1.0,0,1};
                Color pc = {1.0,1.0,0,1};
                float scale = RADER_SCALE/FIELD_SIZE;
                for (ActorList<Fighter>::iterator it = friendFighterList.begin(); it != friendFighterList.end(); ++it)
                {
                    Fighter* pF = *it;
                    AlphaMapSprite* p = new AlphaMapSprite();
                    if (pF->isPlayer())
                    {
                        p->init("pearl.png", pc);
                    }
                    else
                    {
                        p->init("pearl.png", c);
                    }
                    float w = pF->getWidth()*scale;
                    w = MAX(w, 0.4);
                    float h = pF->getHeight()*scale;
                    h = MAX(h, 0.4);
                    p->setScale(w, h);
                    p->setPosition(pF->getPositionX()*scale, pF->getPositionY()*scale);
                    p->retain();
                    nodeList.push_back(p);
                    pRootNode->addChild(p);
                }
            }
        }
    private:
        NodeList nodeList;
        HGNode* pRootNode = NULL;
    };

    ////////////////////
    // 変数宣言
    LayerNode* pLayerBattleRoot = NULL;
    LayerNode* pLayerUIRoot = NULL;
    Fighter* pPlayer = NULL;
    HGNode* pLayerBackground = NULL;
    HGNode* pLayerFriend = NULL;
    HGNode* pLayerEnemy = NULL;
    HGNode* pLayerBullet = NULL;
    HGNode* pLayerEffect = NULL;
    HG3DModel* pPlanetModel;
    Rader* pRader = NULL;
    SpawnData spawnData;
    float spawningEnemyCount = 0;
    bool isInitialized = false;
    
    // 終了フラグ
    bool isEnd = false;
    bool shouldDeployFriends = false;
    bool isPause = false;
    bool _isControllable = false;
    
    unsigned int updateCount = 0;
    int numOfEffect = 0;
    
    FighterInfo* playerInfo;
    FriendData friendData;

    ActorList<Bullet> friendBulletList;
    ActorList<Bullet> enemyBulletList;
    ActorList<Fighter> friendFighterList;
    ActorList<Fighter> enemyFighterList;
    CellManager<Bullet> enemyBulletCellManager({FIELD_SIZE, FIELD_SIZE});
    CellManager<Bullet> friendBulletCellManager({FIELD_SIZE, FIELD_SIZE});
    CellManager<Fighter> enemyCellManager({FIELD_SIZE, FIELD_SIZE});
    CellManager<Fighter> friendCellManager({FIELD_SIZE, FIELD_SIZE});
    BattleResult battleResult;
    
    KeyInfo keyInfo = {};
    HGSize sizeOfField(0,0);
    HGPoint pointOfFieldCenter(0,0);
    bool bgmChanged = false;
    
    float cameraZposition = -25;
    
    // アニメ
    void showHitAnimation(Actor* a)
    {
        if (numOfEffect > EFFECT_NUM) {
            return;
        }
        HitAnimeProcess* pHitAnimeProcess = new HitAnimeProcess();
        HGProcessOwner* pHo = new HGProcessOwner();
        pHitAnimeProcess->init(pHo, a->getPosition(), pLayerEffect);
        HGProcessManager::sharedProcessManager()->addProcess(pHitAnimeProcess);
    }
    void showShieldHitAnimation(Actor* a)
    {
        {
            AlphaMapSprite* pSpr = new AlphaMapSprite();
            pSpr->init("particlesheet01.png", (Color){0.5, 0.5, 1.0, 1.0});
            pSpr->setPosition(a->getPositionX(), a->getPositionY());
            pSpr->setTextureRect(0, 256, 256, 256);
            pSpr->setScale(0, 0);
            pSpr->setRotateZ(rand(0, 359) * M_PI/180);
            pLayerEffect->addChild(pSpr);
            
            {
                HGProcessOwner* po = new HGProcessOwner();
                
                // 拡大
                ChangeScaleProcess* ssp = new ChangeScaleProcess();
                ssp->init(po, pSpr, PXL2REAL(300), PXL2REAL(300), f(15));
                ssp->setEaseFunc(&ease_in);
                
                // 縮小
                ChangeScaleProcess* ssp2 = new ChangeScaleProcess();
                ssp2->init(po, pSpr, 0, 0, f(10));
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
        
        {
            AlphaMapSprite* pSpr = new AlphaMapSprite();
            pSpr->init("star.png", (Color){1.0, 1.0, 1.0, 0.5});
            pSpr->setPosition(a->getPositionX(), a->getPositionY());
            pSpr->setTextureRect(0, 256, 256, 256);
            pSpr->setScale(0, 0);
            pSpr->setRotateZ(rand(0, 359) * M_PI/180);
            pLayerEffect->addChild(pSpr);
            
            {
                HGProcessOwner* po = new HGProcessOwner();
                
                // 拡大
                ChangeScaleProcess* ssp = new ChangeScaleProcess();
                ssp->init(po, pSpr, PXL2REAL(500), PXL2REAL(500), f(15));
                ssp->setEaseFunc(&ease_out);
                
                // 縮小
                ChangeScaleProcess* ssp2 = new ChangeScaleProcess();
                ssp2->init(po, pSpr, 0, 0, f(15));
                ssp2->setEaseFunc(&ease_out);
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
    
    // add actor to cell
    void addActorsToCells()
    {
        friendBulletCellManager.clear();
        struct AddFriendBullets
        {
            void operator()(Bullet* actor) {friendBulletCellManager.addToCellList(actor);}
        };
        for_each(friendBulletList.begin(), friendBulletList.end(), AddFriendBullets());
        
        enemyBulletCellManager.clear();
        struct AddEnemyBullets
        {
            void operator()(Bullet* actor) {enemyBulletCellManager.addToCellList(actor);}
        };
        for_each(enemyBulletList.begin(), enemyBulletList.end(), AddEnemyBullets());
        
        enemyCellManager.clear();
        struct AddEnemy
        {
            void operator()(Fighter* actor) {enemyCellManager.addToCellList(actor);}
        };
        for_each(enemyFighterList.begin(), enemyFighterList.end(), AddEnemy());
        
        friendCellManager.clear();
        struct AddFriend
        {
            void operator()(Fighter* actor) {friendCellManager.addToCellList(actor);}
        };
        for_each(friendFighterList.begin(), friendFighterList.end(), AddFriend());
    }
   
    // fighterがroundと衝突したときの処理
    void onFighterCollidedWithBullet(Fighter* pFighter, Bullet* pBullet)
    {
        pBullet->setActive(false);
        if (pFighter->hasShield())
        {
            showShieldHitAnimation(pBullet);
        }
        else
        {
            showHitAnimation(pBullet);
        }
        int dmg = pBullet->getPower();
        int beforeLife = pFighter->getLife();
        if (pFighter->getSide() == SideTypeEnemy)
        {
            [[OALSimpleAudio sharedInstance] playEffect:SE_HIT];
            // 経験値加算
            Fighter* a = pBullet->getOwner();
            UserData* u = UserData::sharedUserData();
            if (a)
            {
                FighterInfo* attackerInfo = a->getFighterInfo();
                if (attackerInfo)
                {
                    attackerInfo->tmpExp += u->getDamageExp(pFighter->getFighterInfo(), dmg);
                }
            }
            if (a->isPlayer()) {
                battleResult.myHit++;
            } else {
                // cpu lvに応じてダメージ増加
                int cpu_lv = pFighter->getFighterInfo()->cpu_lv;
                dmg += (dmg * cpu_lv * 0.01 * 2);
            }
            battleResult.allHit++;
        } else {
            // 回避チェック
            if (!pFighter->isPlayer()) {
                int cpu_lv = pFighter->getFighterInfo()->cpu_lv;
                if (rand(0, 120) <= cpu_lv) {
                    return;
                }
            }
            if (!pFighter->hasShield()) {
                battleResult.enemyHit++;
            }
        }
        pFighter->addLife(dmg*-1);
        pFighter->noticeAttackedBy(pBullet->getOwner());
        
        if (beforeLife > 0) {
            // 死亡カウント
            UserData* u = UserData::sharedUserData();
            if (pFighter->getLife() <= 0)
            {
                if (pFighter->getSide() == SideTypeEnemy)
                {
                    //[[OALSimpleAudio sharedInstance] playEffect:SE_ENEMY_ELIMINATED];
                    
                    battleResult.killedEnemy++;
                    battleResult.earnedMoney += u->getKillReward(pFighter->getFighterInfo());
                    battleResult.killedValue += u->getCost(pFighter->getFighterInfo());
                    // 当てた方の経験値加算
                    Fighter* a = pBullet->getOwner();
                    if (a)
                    {
                        FighterInfo* attackerInfo = a->getFighterInfo();
                        if (attackerInfo)
                        {
                            attackerInfo->tmpExp += u->getExp(pFighter->getFighterInfo());
                            attackerInfo->killCnt++;
                            attackerInfo->totalKill++;
                        }
                    }
                }
                else
                {
                    [[OALSimpleAudio sharedInstance] playEffect:SE_UNITLOST];
                    battleResult.killedFriend++;
                    pFighter->getFighterInfo()->dieCnt++;
                    pFighter->getFighterInfo()->totalDie++;
                    battleResult.deadValue += u->getCost(pFighter->getFighterInfo());
                }
            }
        }
        
    }
    
    // あたり判定
    void checkCollision(ActorList<Fighter>& fighterList, CellManager<Bullet>& bulletCellManager)
    {
        CollisionManager* pColMgr = CollisionManager::sharedCollisionManager();
        for (ActorList<Fighter>::iterator it = fighterList.begin(); it != fighterList.end(); it++)
        {
            if (!(*it)->isActive() || !(*it)->getLife() > 0)
            {
                continue;
            }
            bool isShield = (*it)->hasShield();
            HGRect shieldRect(0,0,0,0);
            if (isShield)
            {
                shieldRect = (*it)->getShieldRect();
            }
            int cida = (*it)->getCollisionId();
            Vector posa = (*it)->getPosition();
            HGSize sizea = (*it)->getSize();
            
            CellManager<Bullet>::CellNumberList tList;
            HGRect r = {(*it)->getPositionX() - (*it)->getWidth()/2,
                (*it)->getPositionY() - (*it)->getHeight()/2,
                (*it)->getWidth(), (*it)->getHeight()};
            bulletCellManager.GetCellList(r, tList);
            
            for (CellManager<Bullet>::CellNumberList::iterator it1 = tList.begin(); it1 != tList.end(); it1++)
            {
                int cellNumber = (*it1);
                CellManager<Bullet>::ActorList actorList = bulletCellManager.getActorList(cellNumber);
                
                for (CellManager<Bullet>::ActorList::iterator it2 = actorList.begin(); it2 != actorList.end(); it2++)
                {
                    Bullet* a = *it2;
                    assert(a->getCollisionId() < CollisionIdEnd);
                    assert(a->getCollisionId() >= 0);
                    if (!a->isActive())
                    {
                        continue;
                    }
                    int cidb = a->getCollisionId();
                    Vector posb = a->getPosition();
                    HGSize sizeb = a->getSize();
                    if (isShield)
                    {
                        if (pColMgr->isIntersect(cidb, posb, sizeb, shieldRect))
                        {
                            onFighterCollidedWithBullet(*it, a);
                        }
                    }
                    else
                    {
                        if (pColMgr->isIntersect(cida, posa, sizea, cidb, posb, sizeb))
                        {
                            onFighterCollidedWithBullet(*it, a);
                        }
                    }
                }
            }
        }
    }
    
    // 出現
    void spawnFighter(SideType sideType, FighterInfo* pFighterInfo, float positionX, float positionY, int wait)
    {
        class SpawnEnemy : public HGObject
        {
        public:
            SpawnEnemy(SideType sideType, FighterInfo* pFighterInfo, float positionX, float positionY):
            sideType(sideType),
            pFighterInfo(pFighterInfo),
            positionX(positionX),
            positionY(positionY)
            {}
            bool spawn()
            {
                if (SideTypeFriend == sideType)
                {
                    if (!pFighterInfo->isOnBattleGround)
                    {
                        return true;
                    }
                    Fighter* pEnemy = new Fighter();
                    pEnemy->init(pLayerFriend, sideType, pFighterInfo);
                    pEnemy->setPosition(positionX, positionY);
                    friendFighterList.addActor(pEnemy);
                    
                    ControlEnemyProcess* cp = new ControlEnemyProcess();
                    cp->init(pEnemy->getProcessOwner(), pEnemy);
                    HGProcessManager::sharedProcessManager()->addProcess(cp);
                    
                }
                else
                {
                    spawningEnemyCount--;
                    Fighter* pEnemy = new Fighter();
                    pEnemy->init(pLayerEnemy, sideType, pFighterInfo);
                    pEnemy->setPosition(positionX, positionY);
                    enemyFighterList.addActor(pEnemy);
                    
                    ControlEnemyProcess* cp = new ControlEnemyProcess();
                    cp->init(pEnemy->getProcessOwner(), pEnemy);
                    HGProcessManager::sharedProcessManager()->addProcess(cp);
                    
                    if (bgmChanged == false && pFighterInfo->fighterType >= BOSS_FIGHTER_TYPE_MIN) {
                        [[OALSimpleAudio sharedInstance] playBg:BGM_BOSS loop:true];
                        bgmChanged = true;
                    }
                }
                
                return true;
            }
        private:
            SideType sideType;
            FighterInfo* pFighterInfo;
            float positionX;
            float positionY;
        };
        
        positionX = MIN(positionX, FIELD_SIZE);
        positionY = MIN(positionY, FIELD_SIZE);
        positionX = MAX(positionX, 0);
        positionY = MAX(positionY, 0);
        
        if (SideTypeEnemy == sideType)
        {
            spawningEnemyCount++;
        }
        
        // 光
        {
            AlphaMapSprite* pSpr = new AlphaMapSprite();
            pSpr->init("corona.png", (Color){0.8, 0.8, 1.0, 1.0});
            pSpr->setPosition(positionX, positionY);
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
                rnp->setWaitFrame(wait);
                HGProcessManager::sharedProcessManager()->addProcess(rnp);
            }
            
            // 拡大
            {
                HGProcessOwner* po = new HGProcessOwner();
                ChangeScaleProcess* ssp = new ChangeScaleProcess();
                ssp->init(po, pSpr, PXL2REAL(1500), PXL2REAL(1500), f(10));
                ssp->setWaitFrame(wait);
                ssp->setEaseFunc(&ease_out);
                
                // 縮小
                ChangeScaleProcess* ssp2 = new ChangeScaleProcess();
                ssp2->init(po, pSpr, 0, 0, 5);
                ssp2->setEaseFunc(&ease_in);
                ssp->setNext(ssp2);
                
                // 出現
                SpawnEnemy* se = new SpawnEnemy(sideType, pFighterInfo, positionX, positionY);
                CallFunctionRepeadedlyProcess<SpawnEnemy>* cfrp = new CallFunctionRepeadedlyProcess<SpawnEnemy>();
                cfrp->init(po, &SpawnEnemy::spawn, se);
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
            pSpr->setPosition(positionX, positionY);
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
                    rnp->setWaitFrame(wait);
                    HGProcessManager::sharedProcessManager()->addProcess(rnp);
                }
                
                {
                    // 拡大
                    HGProcessOwner* po = new HGProcessOwner();
                    ChangeScaleProcess* ssp = new ChangeScaleProcess();
                    ssp->init(po, pSpr, PXL2REAL(1000), PXL2REAL(1000), 16);
                    ssp->setEaseFunc(&ease_in_out);
                    ssp->setWaitFrame(wait);
                    
                    // プロセス開始
                    HGProcessManager::sharedProcessManager()->addProcess(ssp);
                }
                
                {
                    // 透明化
                    HGProcessOwner* po2 = new HGProcessOwner();
                    SpriteChangeOpacityProcess* scop = new SpriteChangeOpacityProcess();
                    scop->setEaseFunc(&ease_in_out);
                    scop->init(po2, pSpr, 0, 8);
                    scop->setWaitFrame(wait + f(10));
                    
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
    
    ////////////////////
    // friend fighter
    void deployAllFriends()
    {
        assert(pPlayer);
        if (pPlayer->getLife() <= 0)
        {
            return;
        }
        float wait = 0;
        using namespace hg;
        UserData* userData = UserData::sharedUserData();
        FighterList fList = userData->getFighterList();
        for (FighterList::iterator it = fList.begin(); it != fList.end(); ++it)
        {
            FighterInfo* pFighterInfo = (*it);
            if (pFighterInfo->life <= 0 || pFighterInfo->isPlayer)
            {
                continue;
            }
            FriendData::iterator findItr = std::find(friendData.begin(), friendData.end(), pFighterInfo);
            if (pFighterInfo->isOnBattleGround)
            {
                if (findItr == friendData.end())
                {
                    friendData.push_back(pFighterInfo);
                    // deploy
                    float tx = pPlayer->getPositionX();
                    float ty = pPlayer->getPositionY();
                    float d = rand(0, 359);
                    float x = tx + cos(toRad(d)) * 7;
                    float y = ty + sin(toRad(d)) * 7;
                    x = MAX(x, 0), x = MIN(x, FIELD_SIZE);
                    y = MAX(y, 0), y = MIN(y, FIELD_SIZE);
                    spawnFighter(SideTypeFriend, pFighterInfo, x, y, wait);
                    //wait += f(10);
                }
                else
                {
                    // do nothing
                }
            }
            else
            {
                if (findItr == friendData.end())
                {
                    // do nothing
                }
                else
                {
                    friendData.erase(findItr);
                    // collect
                    for (ActorList<Fighter>::iterator it = friendFighterList.begin(); it != friendFighterList.end(); ++it)
                    {
                        if (*it == pPlayer) continue;
                        FighterInfo* pFighterInfoTmp = (*it)->getFighterInfo();
                        if (pFighterInfo == pFighterInfoTmp)
                        {
                            (*it)->disappear();
                        }
                    }
                }
            }
        }
    }
    
    void collectAllFriends()
    {
        assert(pPlayer);
        for (ActorList<Fighter>::iterator it = friendFighterList.begin(); it != friendFighterList.end(); ++it)
        {
            if (*it == pPlayer) continue;
            (*it)->disappear();
        }
    }
    
    ////////////////////
    // ステート
    class LoseState : public HGState
    {
        ~LoseState()
        {
            
        }
        void onUpdate()
        {
            if (this->getFrameCount() == 0)
            {
                isInit = true;
                class Fn : public HGObject
                {
                public:
                    Fn() {}
                    bool exec()
                    {
                        isEnd = true;
                        return true;
                    }
                };
                
                // 終了
                {
                    // 出現
                    Fn* fn = new Fn();
                    HGProcessOwner* po = new HGProcessOwner();
                    CallFunctionRepeadedlyProcess<Fn>* cfrp = new CallFunctionRepeadedlyProcess<Fn>();
                    cfrp->init(po, &Fn::exec, fn);
                    cfrp->setWaitFrame(f(60));
                    
                    // プロセス開始
                    HGProcessManager::sharedProcessManager()->addProcess(cfrp);
                }
                
                // lose
                {
                    HGText* pNodeText = new HGText();
                    pNodeText->initWithString("You Lose...");
                    pNodeText->setScaleByTextSize(8);
                    pNodeText->setPosition(0, 0);
                    pNodeText->setAnchor(0.5, 0.5);
                    pNodeText->setblendcolor({(float)0x6a/255.f, (float)0x93/255.f, (float)0xd4/255.f});
                    pLayerUIRoot->addChild(pNodeText);
                }
                //collectAllFriends();
                
                // 仲間を退却させる
                {
                    UserData* userData = UserData::sharedUserData();
                    FighterList fList = userData->getFighterList();
                    for (FighterList::iterator it = fList.begin(); it != fList.end(); ++it)
                    {
                        FighterInfo* pFighterInfo = (*it);
                        if (pFighterInfo->life <= 0 || pFighterInfo->isPlayer)
                        {
                            continue;
                        }
                        pFighterInfo->isOnBattleGround = false;
                    }
                    deployAllFriends();
                }
                
            }
            HGProcessManager::sharedProcessManager()->update();
            addActorsToCells();
            checkCollision(enemyFighterList, friendBulletCellManager);
            checkCollision(friendFighterList, enemyBulletCellManager);
            
            // update Rader
            if (this->getFrameCount() % f(10) == 0)
            {
                pRader->updateRader(enemyCellManager, friendCellManager);
            }
            else
            {
                assert(isInit == true);
            }
            
        }
        std::string getName()
        {
            return "LoseState";
        }
        bool isInit = false;
    };
    
    ////////////////////
    // ステート
    class RetreatState : public HGState
    {
        ~RetreatState()
        {
            
        }
        void onUpdate()
        {
            if (this->getFrameCount() == 0)
            {
                battleResult.isRetreat = true;
                
                class Fn : public HGObject
                {
                public:
                    Fn() {}
                    bool exec()
                    {
                        isEnd = true;
                        return true;
                    }
                };
                
                // 終了
                {
                    Fn* fn = new Fn();
                    HGProcessOwner* po = new HGProcessOwner();
                    CallFunctionRepeadedlyProcess<Fn>* cfrp = new CallFunctionRepeadedlyProcess<Fn>();
                    cfrp->init(po, &Fn::exec, fn);
                    cfrp->setWaitFrame(f(60));
                    
                    // プロセス開始
                    HGProcessManager::sharedProcessManager()->addProcess(cfrp);
                }
                
                // retreat
                {
                    HGText* pNodeText = new HGText();
                    pNodeText->initWithString("Retreat");
                    pNodeText->setScaleByTextSize(8);
                    pNodeText->setPosition(0, 0);
                    pNodeText->setAnchor(0.5, 0.5);
                    pNodeText->setblendcolor({(float)0xcd/255.f, (float)0x35/255.f, (float)0xd3/255.f});
                    //pNodeText->setblendcolor({0.5,0,0});
                    pLayerUIRoot->addChild(pNodeText);
                }
                
                
                // 仲間を退却させる
                {
                    UserData* userData = UserData::sharedUserData();
                    FighterList fList = userData->getFighterList();
                    for (FighterList::iterator it = fList.begin(); it != fList.end(); ++it)
                    {
                        FighterInfo* pFighterInfo = (*it);
                        if (pFighterInfo->life <= 0 || pFighterInfo->isPlayer)
                        {
                            continue;
                        }
                        pFighterInfo->isOnBattleGround = false;
                    }
                    deployAllFriends();
                }
                
                // 自分も撤退する
                if (pPlayer && pPlayer->isActive() && pPlayer->getLife() > 0)
                {
                    pPlayer->disappear();
                }
                
            }
            HGProcessManager::sharedProcessManager()->update();
            addActorsToCells();
            checkCollision(enemyFighterList, friendBulletCellManager);
            checkCollision(friendFighterList, enemyBulletCellManager);
            
            // update Rader
            if (this->getFrameCount() % f(10) == 0)
            {
                pRader->updateRader(enemyCellManager, friendCellManager);
            }
            
        }
        std::string getName()
        {
            return "RetreatState";
        }
    };
    
    class WinState : public HGState
    {
        ~WinState()
        {
            
        }
        void onUpdate()
        {
            if (this->getFrameCount() == 0)
            {
                class Fn : public HGObject
                {
                public:
                    Fn() {}
                    bool exec()
                    {
                        isEnd = true;
                        return true;
                    }
                };
                
                // 終了
                {
                    // 出現
                    Fn* fn = new Fn();
                    HGProcessOwner* po = new HGProcessOwner();
                    CallFunctionRepeadedlyProcess<Fn>* cfrp = new CallFunctionRepeadedlyProcess<Fn>();
                    cfrp->init(po, &Fn::exec, fn);
                    cfrp->setWaitFrame(f(60));
                    
                    // プロセス開始
                    HGProcessManager::sharedProcessManager()->addProcess(cfrp);
                }
                
                // win
                {
                    HGText* pNodeText = new HGText();
                    pNodeText->initWithString("You Win");
                    pNodeText->setScaleByTextSize(8);
                    pNodeText->setPosition(0, 0);
                    pNodeText->setAnchor(0.5, 0.5);
                    pNodeText->setblendcolor({1, 0, 0});
                    pLayerUIRoot->addChild(pNodeText);
                }
                
            }
            HGProcessManager::sharedProcessManager()->update();
            addActorsToCells();
            checkCollision(enemyFighterList, friendBulletCellManager);
            checkCollision(friendFighterList, enemyBulletCellManager);
            
            // update Rader
            if (this->getFrameCount() % f(10) == 0)
            {
                pRader->updateRader(enemyCellManager, friendCellManager);
            }
            
        }
        std::string getName()
        {
            return "WinState";
        }
    };
    
    class BattleState : public HGState
    {
        ~BattleState()
        {
            
        }
        void onUpdate()
        {
            HGProcessManager::sharedProcessManager()->update();
            
            addActorsToCells();
            checkCollision(enemyFighterList, friendBulletCellManager);
            checkCollision(friendFighterList, enemyBulletCellManager);
            
            // remove inactive actors
            friendBulletList.removeInactiveActors();
            enemyBulletList.removeInactiveActors();
            friendFighterList.removeInactiveActors();
            enemyFighterList.removeInactiveActors();
            
            // 援軍判定
            if (enemyFighterList.size() <= 0)
            {
                // 援軍出現
                if (spawnData.size() > 0)
                {
                    if (spawningEnemyCount <= 0)
                    {
                        [[OALSimpleAudio sharedInstance] playEffect:SE_ENEMY_APPROACH];

                        SpawnGroup sg = spawnData.front();
                        spawnData.pop_front();
                        int wait = 0;
                        for (SpawnGroup::iterator it = sg.begin(); it != sg.end(); it++)
                        {
                            FighterInfo* finfo = *it;
                            spawnFighter(SideTypeEnemy,
                                         finfo,
                                         rand(0, sizeOfField.width),
                                         rand(0, sizeOfField.height),
                                         wait * f(30));
                            wait++;
                        }
                    }
                }
            }
            
            if (spawningEnemyCount == 0 && enemyFighterList.size() <= 0)
            {
                battleResult.isWin = true;
                HGStateManager::sharedStateManger()->pop();
                HGStateManager::sharedStateManger()->push(new WinState());
                _isControllable = false;
            }
            
            // 勝敗判定
            if (pPlayer->getLife() <= 0)
            {
                // lose
                battleResult.isWin = false;
                HGStateManager::sharedStateManger()->pop();
                HGStateManager::sharedStateManger()->push(new LoseState());
                _isControllable = false;
            }
            
            
            // update Rader
            if (this->getFrameCount() % f(10) == 0)
            {
                pRader->updateRader(enemyCellManager, friendCellManager);
            }
            
            //
            if (shouldDeployFriends)
            {
                deployAllFriends();
            }
            /*
            if (keyInfo.shouldDeployFriend)
            {
                deployAllFriends();
            }
            else if (keyInfo.shouldCollectFriend)
            {
                collectAllFriends();
            }*/
        }
        std::string getName()
        {
            return "BattleState";
        }
    };
    
    ////////////////////
    // 終了準備
    void cleanup()
    {
        NSLog(@"CLEAN UP START");
        // メモリ掃除
        //HGHeapFactory::CreateHeap(DEFAULT_HEAP_NAME)->freeAll();
        NSLog(@"CLEAN UP END");
        
    }

    ////////////////////
    // 初期化
    //hgles::HGLObject3D* planetObj = NULL;
    void initialize(SpawnData sd, FighterInfo* pl)
    {
        NSLog(@"INITIALIZE START");
        bgmChanged = false;
        numOfEffect = 0;
        updateCount = 0;
        isEnd = false;
        isPause = false;
        _isControllable = true;
        isInitialized = false;
        shouldDeployFriends = false;
        battleResult = BattleResult();
        
        // 増援データ
        spawningEnemyCount = 0;
        spawnData = sd;
        
        // プレイヤーデータ
        playerInfo = pl;
        friendData.clear();
        
        // メモリ掃除
        HGHeapFactory::CreateHeap(DEFAULT_HEAP_NAME)->freeAll();
        
        HGDirector::sharedDirector()->getRootNode()->removeAllChildren();
        
        // init data
        UserData::sharedUserData()->initBeforeBattle();
        
        // list
        friendFighterList.removeAllActor();
        enemyFighterList.removeAllActor();
        friendBulletList.removeAllActor();
        enemyBulletList.removeAllActor();
        
        enemyCellManager.clear();
        friendCellManager.clear();
        enemyBulletCellManager.clear();
        friendBulletCellManager.clear();
        
        // process
        HGProcessManager::sharedProcessManager()->clear();
        
        // state
        HGStateManager::sharedStateManger()->clear();
        HGState* s = new BattleState();
        HGStateManager::sharedStateManger()->push(s);
        
        // field size
        sizeOfField = {FIELD_SIZE, FIELD_SIZE};
        pointOfFieldCenter = {sizeOfField.width/2, sizeOfField.height/2};
        
        ////////////////////
        // Root Layer
        
        if (pLayerBattleRoot)
        {
            pLayerBattleRoot->release();
        }
        pLayerBattleRoot = new LayerNode();
        pLayerBattleRoot->retain();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerBattleRoot);
        
        if (pLayerUIRoot)
        {
            pLayerUIRoot->release();
        }
        pLayerUIRoot = new LayerNode();
        pLayerUIRoot->retain();
        pLayerUIRoot->setCameraPosition(0, 0, -15);
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerUIRoot);
        
        ////////////////////
        // Rader
        if (pRader)
        {
            pRader->release();
        }
        pRader = new Rader();
        pRader->init(pLayerUIRoot);
        pRader->retain();
        
        ////////////////////
        // layer
        if (pLayerBackground)
        {
            pLayerBackground->release();
        }
        pLayerBackground = new HGNode();
        pLayerBackground->retain();
        pLayerBattleRoot->addChild(pLayerBackground);
        
        //
        if (pLayerEnemy)
        {
            pLayerEnemy->release();
        }
        pLayerEnemy = new HGNode();
        pLayerEnemy->retain();
        pLayerBattleRoot->addChild(pLayerEnemy);
        
        //
        if (pLayerFriend)
        {
            pLayerFriend->release();
        }
        pLayerFriend = new HGNode();
        pLayerFriend->retain();
        pLayerBattleRoot->addChild(pLayerFriend);
        
        //
        if (pLayerBullet)
        {
            pLayerBullet->release();
        }
        pLayerBullet = new HGNode();
        pLayerBullet->retain();
        pLayerBattleRoot->addChild(pLayerBullet);
        
        //
        if (pLayerEffect)
        {
            pLayerEffect->release();
        }
        pLayerEffect = new HGNode();
        pLayerEffect->retain();
        pLayerBattleRoot->addChild(pLayerEffect);
        
        // background
        for (int i = 0; i < 5; ++i)
        {
            HGSprite* pSprite = new HGSprite();
            pSprite->init("space.png");
            pSprite->setScale(BACKGROUND_SCALE, BACKGROUND_SCALE, BACKGROUND_SCALE);
            switch (i) {
                case 0:
                    pSprite->setPosition(-1 * BACKGROUND_SCALE / 2 + pointOfFieldCenter.x, pointOfFieldCenter.y, ZPOS);
                    pSprite->setRotate(0, 90*M_PI/180, 0);
                    break;
                case 1:
                    pSprite->setPosition(BACKGROUND_SCALE/2+pointOfFieldCenter.x, pointOfFieldCenter.y, ZPOS);
                    pSprite->setRotate(0, -90*M_PI/180, 180*M_PI/180);
                    break;
                case 2:
                    pSprite->setPosition(pointOfFieldCenter.x, BACKGROUND_SCALE/2+pointOfFieldCenter.y, ZPOS);
                    pSprite->setRotate(-90*M_PI/180, 0, 0);
                    break;
                case 3:
                    pSprite->setPosition(pointOfFieldCenter.x, -BACKGROUND_SCALE/2+pointOfFieldCenter.y, ZPOS);
                    pSprite->setRotate(90*M_PI/180, 0, 0);
                    break;
                case 4:
                    pSprite->setPosition(pointOfFieldCenter.x, pointOfFieldCenter.y, -1*BACKGROUND_SCALE/2 + ZPOS);
                    pSprite->setRotate(0, 0, 0);
                    break;
                    /*
                case 5:
                    t->position.set(0, 0, 1*BACKGROUND_SCALE/2 + ZPOS);
                    t->rotate.set(180*M_PI/180, 0, 0);
                    break;*/
                default:
                    break;
            }
            pLayerBackground->addChild(pSprite);
        }
        
        // sun
        /*
        {
            AlphaMapSprite* pSprite = new AlphaMapSprite();
            pSprite->init("sun.png", (Color){0.25, 0.20, 0.6, 0.6});
            //pSprite->setBlendFunc(GL_SRC_ALPHA, GL_ONE);
            pSprite->setScale(200, 200, 1);
            pSprite->setPosition(-30, 80);
            pLayerBackground->addChild(pSprite);
        }*/
        
        // planet
        {
            float clearRatio = hg::UserData::sharedUserData()->getCurrentClearRatio();
            hg::StageInfo info = hg::UserData::sharedUserData()->getStageInfo();
            HG3DModel* mdl = new HG3DModel();
            mdl->init(info.model_name);
            float scale = info.small_size + clearRatio * info.big_size;
            if (clearRatio >= 0.90) {
                scale = 800;
                mdl->setPosition(FIELD_SIZE/2, FIELD_SIZE/2, -400);
            }
            else {
                mdl->setPosition(FIELD_SIZE + 100, FIELD_SIZE/2 + 150, -400);
            }
            mdl->setScale(scale, scale, scale);
            mdl->setRotateX(-2.86);
            mdl->setRotateY(rand(0, 100) * 0.1);
            mdl->setRotateZ(-2.86);
            //mdl->setRotateZ(rand(0, 100) * 0.1);
            pPlanetModel = mdl;
            pLayerBackground->addChild(mdl);
            //mdl->release();
        }
        
        // フィールド境界
        {
            HGSprite* pSprite = new HGSprite();
            pSprite->init("rect.png");
            pSprite->setblendcolor({0.8,0.1,0.1,0.2});
            pSprite->setScale(sizeOfField.width*2, sizeOfField.height*2, 1);
            pSprite->setPosition(pointOfFieldCenter.x, pointOfFieldCenter.y);
            pLayerBackground->addChild(pSprite);
            
            {
                // 色変更
                HGProcessOwner* po = new HGProcessOwner();
                ChangeSpriteBlendColorProcess* cscp = new ChangeSpriteBlendColorProcess();
                Color c = {0.1, 0.1, 0.8, 0.2};
                cscp->init(po, pSprite, c, f(40));
                cscp->setEaseFunc(&ease_linear);
                HGProcessManager::sharedProcessManager()->addProcess(cscp);
            }
        }
        {
            /*
            // planet
            hg::StageInfo stageInfo = hg::UserData::sharedUserData()->getStageInfo();
            planetObj = hgles::HGLObjLoader::load([NSString stringWithCString:stageInfo.model_name.c_str() encoding:NSUTF8StringEncoding]);
            planetObj->position.z = -600;
            
            // size
            float currentClearRatio = hg::UserData::sharedUserData()->getCurrentClearRatio();
            float size = stageInfo.small_size  + stageInfo.big_size * currentClearRatio;
            planetObj->scale.set(size, size, size);
            */
        }
        
        // player
        {
            if (pPlayer)
            {
                pPlayer->release();
            }
            
            pPlayer = new Fighter();
            pPlayer->init(pLayerFriend, SideTypeFriend, playerInfo);
            pPlayer->setPosition(sizeOfField.width/2, sizeOfField.height/2);
            friendFighterList.addActor(pPlayer);
            pPlayer->retain();
        }
        
        if (pPlayer)
        {
            HGProcessOwner* pPlayerControlOwner = new HGProcessOwner;
            ControlPlayerProcess* p = new ControlPlayerProcess();
            p->init(pPlayerControlOwner, pPlayer);
            HGProcessManager::sharedProcessManager()->addProcess(p);
        }
        
        /*
        {
            HGText* pNodeText = new HGText();
            pNodeText->initWithString("敵殲滅", {1,1,0,1});
            pNodeText->setScaleByTextSize(4);
            pNodeText->setPosition(-10, +10);
            pLayerUIRoot->addChild(pNodeText);
        }
        {
            HGText* pNodeText = new HGText();
            pNodeText->initWithString("うっっへへへへっへへえh");
            pNodeText->setScaleByTextSize(4);
            pNodeText->setPosition(-10, 8);
            pLayerUIRoot->addChild(pNodeText);
        }*/
        isInitialized = true;
        NSLog(@"INITIALIZE END");
    }
    
    void deployFriends()
    {
        shouldDeployFriends = true;
    }
    
    void setCameraZPostion(float val)
    {
        cameraZposition = val;
    }
    
    void retreat()
    {
        HGStateManager::sharedStateManger()->pop();
        HGStateManager::sharedStateManger()->push(new RetreatState());
        _isControllable = false;
    }
    
    ////////////////////
    // 更新
    void update(KeyInfo keyState)
    {
        if (isGameEnd() || !isInitialized)
        {
            return;
        }
        if (isPause)
        {
            return;
        }
        updateCount++;
        keyInfo = keyState;
        keyInfo.isFire = (keyState.isFire>0)?true:false;
        HGStateManager::sharedStateManger()->update();
    }
    float getHPRatio()
    {
        if (pPlayer) {
            return pPlayer->getLifeRatio();
        }
        return 0;
    }
    
    float getShieldRatio()
    {
        if (pPlayer) {
            return pPlayer->getShieldRatio();
        }
        return 0;
    }
    
    ////////////////////
    // レンダリング
    hgles::HGLObject3D* testObject = NULL;
    void render()
    {
        if (!isInitialized)
        {
            return;
        }
        // 光源なし
        glUniform1f(hgles::currentContext->uUseLight, 0.0);
        // 2d
        glDisable(GL_DEPTH_TEST);
        
        // set camera
        if (pPlayer)
        {
            pLayerBattleRoot->setCameraPosition(pPlayer->getPositionX() * -1,
                                                pPlayer->getPositionY() * -1 + 7,
                                                cameraZposition);
            pLayerBattleRoot->setCameraRotate(
                atan2(-7, -1*cameraZposition), 0, 0
            );
        }
        
        // rotate planet
        if (pPlanetModel) {
            pPlanetModel->setRotateY(pPlanetModel->getRotateY() + 0.0003);
        }
        
        // ノードを描画
        HGDirector::sharedDirector()->drawRootNode();
        
        {
            //planetObj->draw();
        }
        /*
         // 光源なし
         glUniform1f(hgles::currentContext->uUseLight, 1.0);
         // 2d
         glEnable(GL_DEPTH_TEST);
         if (testObject == NULL)
         {
         testObject = hgles::HGLObjLoader::load(@"block.obj");
         testObject->position = pPlayer->getNode()->getPosition();
            testObject->scale.set(100,100,100);
            testObject->useLight = 1;
        }
        testObject->draw();*/
    }
    
    BattleResult getResult()
    {
        return battleResult;
    }
    
    bool isGameEnd()
    {
        return isEnd;
    }
    
    void setPause(bool shouldPause)
    {
        isPause = shouldPause;
    }
    
    bool isControllable()
    {
        return _isControllable;
    }
    
}