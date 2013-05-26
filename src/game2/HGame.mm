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
    Rader* pRader = NULL;
    SpawnData spawnData;
    
    FighterInfo playerInfo;
    FriendData friendData;

    ActorList<Bullet> friendBulletList;
    ActorList<Bullet> enemyBulletList;
    ActorList<Fighter> friendFighterList;
    ActorList<Fighter> enemyFighterList;
    CellManager<Bullet> enemyBulletCellManager({FIELD_SIZE, FIELD_SIZE});
    CellManager<Bullet> friendBulletCellManager({FIELD_SIZE, FIELD_SIZE});
    CellManager<Fighter> enemyCellManager({FIELD_SIZE, FIELD_SIZE});
    CellManager<Fighter> friendCellManager({FIELD_SIZE, FIELD_SIZE});

    KeyInfo keyInfo = {};
    HGSize sizeOfField(0,0);
    HGPoint pointOfFieldCenter(0,0);
    
    // アニメ
    void showHitAnimation(Actor* a)
    {
        HitAnimeProcess* pHitAnimeProcess = new HitAnimeProcess();
        HGProcessOwner* pHo = new HGProcessOwner();
        pHitAnimeProcess->init(pHo, a->getPosition(), pLayerEffect);
        HGProcessManager::sharedProcessManager()->addProcess(pHitAnimeProcess);
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
        showHitAnimation(pBullet);
        pBullet->setActive(false);
        pFighter->addLife(pBullet->getPower() * -1);
        pFighter->noticeAttackedBy(pBullet->getOwner());
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
            CollisionId cida = (*it)->getCollisionId();
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
                    assert(a->getCollisionId() < 5);
                    assert(a->getCollisionId() >= 0);
                    if (!a->isActive())
                    {
                        continue;
                    }
                    CollisionId cidb = a->getCollisionId();
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
    void spawnFighter(SideType sideType, FighterInfo fighterInfo, float positionX, float positionY, int wait)
    {
        class SpawnEnemy : public HGObject
        {
        public:
            SpawnEnemy(SideType sideType, FighterInfo fighterInfo, float positionX, float positionY):
            sideType(sideType),
            fighterInfo(fighterInfo),
            positionX(positionX),
            positionY(positionY)
            {}
            bool spawn()
            {
                if (SideTypeFriend == sideType)
                {
                    Fighter* pEnemy = new Fighter();
                    pEnemy->init(pLayerFriend, sideType, fighterInfo);
                    pEnemy->setPosition(positionX, positionY);
                    friendFighterList.addActor(pEnemy);
                    
                    ControlEnemyProcess* cp = new ControlEnemyProcess();
                    cp->init(pEnemy->getProcessOwner(), pEnemy);
                    HGProcessManager::sharedProcessManager()->addProcess(cp);
                    
                }
                else
                {
                    Fighter* pEnemy = new Fighter();
                    pEnemy->init(pLayerEnemy, sideType, fighterInfo);
                    pEnemy->setPosition(positionX, positionY);
                    enemyFighterList.addActor(pEnemy);
                    
                    ControlEnemyProcess* cp = new ControlEnemyProcess();
                    cp->init(pEnemy->getProcessOwner(), pEnemy);
                    HGProcessManager::sharedProcessManager()->addProcess(cp);
                }
                
                return true;
            }
        private:
            SideType sideType;
            FighterInfo fighterInfo;
            float positionX;
            float positionY;
        };
        
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
                ssp->init(po, pSpr, PXL2REAL(700), PXL2REAL(700), f(10));
                ssp->setWaitFrame(wait);
                ssp->setEaseFunc(&ease_out);
                
                // 縮小
                ChangeScaleProcess* ssp2 = new ChangeScaleProcess();
                ssp2->init(po, pSpr, 0, 0, 5);
                ssp2->setEaseFunc(&ease_in);
                ssp->setNext(ssp2);
                
                // 出現
                SpawnEnemy* se = new SpawnEnemy(sideType, fighterInfo, positionX, positionY);
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
    // ステート
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
                    if (spawnWait == 0)
                    {
                        SpawnGroup sg = spawnData.front();
                        spawnData.pop_front();
                        for (SpawnGroup::iterator it = sg.begin(); it != sg.end(); it++)
                        {
                            FighterInfo finfo = *it;
                            spawnFighter(SideTypeEnemy,
                                         finfo,
                                         rand(0, sizeOfField.width),
                                         rand(0, sizeOfField.height),
                                         spawnWait * f(30));
                            spawnWait++;
                        }
                    }
                }
            }
            else
            {
                spawnWait = 0;
            }
            
            // update Rader
            if (this->getFrameCount() % f(10) == 0)
            {
                pRader->updateRader(enemyCellManager, friendCellManager);
            }
        }
        std::string getName()
        {
            return "BattleState";
        }
    private:
        int spawnCount = 0;
        int spawnWait = 0;
    };

    ////////////////////
    // 初期化
    void initialize(SpawnData sd, FighterInfo pl, FriendData fd)
    {
        initRandom();
        
        // 増援データ
        spawnData = sd;
        
        // プレイヤーデータ
        playerInfo = pl;
        friendData = fd;
        
        // メモリ掃除
        HGHeapFactory::CreateHeap(DEFAULT_HEAP_NAME)->freeAll();
        
        HGDirector::sharedDirector()->getRootNode()->removeAllChildren();
        
        // list
        friendFighterList.removeAllActor();
        enemyFighterList.removeAllActor();
        friendBulletList.removeAllActor();
        enemyBulletList.removeAllActor();
        
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
        {
            AlphaMapSprite* pSprite = new AlphaMapSprite();
            pSprite->init("sun.png", (Color){0.25, 0.20, 0.6, 0.6});
            //pSprite->setBlendFunc(GL_SRC_ALPHA, GL_ONE);
            pSprite->setScale(200, 200, 1);
            pSprite->setPosition(-30, 80);
            pLayerBackground->addChild(pSprite);
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
        }
    }

    ////////////////////
    // 更新
    void update(hg::t_keyState* keyState)
    {
        keyInfo.isFire = (keyState->fire>0)?true:false;
        HGStateManager::sharedStateManger()->update();
    }
    
    ////////////////////
    // 方向キー動作
    void onMoveLeftPad(int degree, float power)
    {
        keyInfo.degree = degree;
        keyInfo.power = power;
    }
    
    ////////////////////
    // レンダリング
    void render()
    {
        // 光源なし
        glUniform1f(hgles::currentContext->uUseLight, 0.0);
        // 2d
        glDisable(GL_DEPTH_TEST);
        
        // set camera
        if (pPlayer)
        {
            pLayerBattleRoot->setCameraPosition(pPlayer->getPositionX() * -1,
                                                pPlayer->getPositionY() * -1 + 7,
                                                -18);
            pLayerBattleRoot->setCameraRotate(-15 * M_PI/180, 0, 0);
        }
        
        // ノードを描画
        HGDirector::sharedDirector()->drawRootNode();
    }
    

}