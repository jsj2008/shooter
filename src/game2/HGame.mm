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
    // あたり判定
    const int CELL_SPLIT_NUM = 20;
    HGSize sizeOfCell = {FIELD_SIZE/CELL_SPLIT_NUM, FIELD_SIZE/CELL_SPLIT_NUM};
    template <class T>
    class CellManager : HGObject
    {
    public:
        typedef std::list<T*> ActorList;
        typedef std::vector<ActorList> CellList;
        typedef std::list<int> CellNumberList;
        CellManager()
        {
            list.resize(CELL_SPLIT_NUM*CELL_SPLIT_NUM);
        }
        void clear()
        {
            //for_each(list.begin(), list.end(), Clear());
            for (typename CellList::iterator it = list.begin(); it != list.end(); it++)
            {
                (*it).clear();
            }
        }
        void addToCellList(T* actor)
        {
            HGPoint tmpPos = {actor->getPositionX(), actor->getPositionY()};
            float halfWidth = actor->getWidth()/2;
            float halfHeight = actor->getHeight()/2;
            tmpPos.x -= halfWidth;
            tmpPos.y -= halfHeight;
            int beforeNum = -1;
            while (1)
            {
                int num = getCellNumber(tmpPos);
                if (num > 0 && num > beforeNum)
                {
                    list[num].push_back(actor);
                }
                beforeNum = num;
                tmpPos.x += sizeOfCell.width;
                if (tmpPos.x > actor->getPositionX() + halfWidth)
                {
                    if (tmpPos.y + sizeOfCell.height > actor->getPositionY() + halfHeight)
                    {
                        break;
                    }
                    else
                    {
                        tmpPos.x = actor->getPositionX() - halfWidth;
                    }
                }
            }
        }
        const ActorList& getActorList(int cellNumber)
        {
            return list[cellNumber];
        }
        static void GetCellList(Actor* actor, CellNumberList &list)
        {
            HGPoint tmpPos = {actor->getPositionX(), actor->getPositionY()};
            float halfWidth = actor->getWidth()/2;
            float halfHeight = actor->getHeight()/2;
            tmpPos.x -= halfWidth;
            tmpPos.y -= halfHeight;
            int beforeNum = -1;
            while (1)
            {
                int num = getCellNumber(tmpPos);
                if (num > 0 && num > beforeNum)
                {
                    list.push_back(num);
                }
                beforeNum = num;
                tmpPos.x += sizeOfCell.width;
                if (tmpPos.x > actor->getPositionX() + halfWidth)
                {
                    if (tmpPos.y + sizeOfCell.height > actor->getPositionY() + halfHeight)
                    {
                        break;
                    }
                    else
                    {
                        tmpPos.y += sizeOfCell.height;
                        tmpPos.x = actor->getPositionX() - halfWidth;
                    }
                }
            }
        }
    private:
        struct Clear {
            void operator()(ActorList cell) { cell.clear(); }
        };
        CellList list;
        static int getCellNumber(HGPoint& s)
        {
            if (s.x < 0 || s.y < 0)
            {
                return -1;
            }
            if (s.x > sizeOfField.width || s.y > sizeOfField.height)
            {
                return -1;
            }
            int wx = (int)(s.x / sizeOfCell.width);
            int wy = (int)(s.y / sizeOfCell.height);
            return wx + wy * CELL_SPLIT_NUM;
        }
    };
    
    ////////////////////
    // 変数宣言
    Vector _cameraPosition(0,0,0);
    Vector _cameraRotate(0,0,0);
    
    Fighter* pPlayer = NULL;
    HGNode* pLayerBackground = NULL;
    HGNode* pLayerFriend = NULL;
    HGNode* pLayerEnemy = NULL;
    HGNode* pLayerBullet = NULL;
    HGNode* pLayerEffect = NULL;
    
    ActorList<Bullet> friendBulletList;
    ActorList<Bullet> enemyBulletList;
    ActorList<Fighter> friendFighterList;
    ActorList<Fighter> enemyFighterList;
    CellManager<Bullet> enemyBulletCellManager;
    CellManager<Bullet> friendBulletCellManager;
    
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
    }
   
    // fighterがroundと衝突したときの処理
    void onFighterCollidedWithBullet(Fighter* pFighter, Bullet* pBullet)
    {
        showHitAnimation(pBullet);
        pBullet->setActive(false);
        pFighter->addLife(pBullet->getPower() * -1);
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
            CollisionId cida = (*it)->getCollisionId();
            Vector posa = (*it)->getPosition();
            HGSize sizea = (*it)->getSize();
            
            CellManager<Bullet>::CellNumberList tList;
            CellManager<Bullet>::GetCellList(*it, tList);
            
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
                    if (pColMgr->isIntersect(cida, posa, sizea, cidb, posb, sizeb))
                    {
                        onFighterCollidedWithBullet(*it, a);
                    }
                }
            }
        }
    }
    
    
    // 出現
    void spawnFighter(SideType sideType, FighterType fighterType, float positionX, float positionY)
    {
        class SpawnEnemy : public HGObject
        {
        public:
            SpawnEnemy(SideType sideType, FighterType fighterType, float positionX, float positionY):
            sideType(sideType),
            fighterType(fighterType),
            positionX(positionX),
            positionY(positionY)
            {}
            bool spawn()
            {
                if (SideTypeFriend == sideType)
                {
                    Fighter* pEnemy = new Fighter();
                    pEnemy->init(pLayerFriend, sideType, fighterType);
                    pEnemy->setPosition(positionX, positionY);
                    friendFighterList.addActor(pEnemy);
                    
                    ControlEnemyProcess* cp = new ControlEnemyProcess();
                    cp->init(pEnemy->getProcessOwner(), pEnemy);
                    HGProcessManager::sharedProcessManager()->addProcess(cp);
                    
                }
                else
                {
                    Fighter* pEnemy = new Fighter();
                    pEnemy->init(pLayerEnemy, sideType, fighterType);
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
            FighterType fighterType;
            float positionX;
            float positionY;
        };
        
        // 光
        {
            HGSprite* pSpr = CreateAlphaMapSprite("corona.png", (Color){0.8, 0.8, 1.0, 1.0});
            pSpr->setPosition(positionX, positionY);
            pSpr->setScale(0, 0);
            pSpr->setRotateZ(rand(0, 359) * M_PI/180);
            pLayerEffect->addChild(pSpr);
            
            // 拡大
            HGProcessOwner* po = new HGProcessOwner();
            SpriteScaleProcess* ssp = new SpriteScaleProcess();
            ssp->init(po, pSpr, PXL2REAL(700), PXL2REAL(700), 10);
            
            // 縮小
            SpriteScaleProcess* ssp2 = new SpriteScaleProcess();
            ssp2->init(po, pSpr, 0, 0, 5);
            ssp->setNext(ssp2);
            
            // 出現
            SpawnEnemy* se = new SpawnEnemy(sideType, fighterType, positionX, positionY);
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
        
        // 光
        {
            HGSprite* pSpr = CreateAlphaMapSprite("wavering.png", (Color){1.0, 0.5, 0.5, 1.0});
            pSpr->setPosition(positionX, positionY);
            pSpr->setScale(0, 0);
            pSpr->setRotateZ(rand(0, 359) * M_PI/180);
            pLayerEffect->addChild(pSpr);
            
            // 拡大
            HGProcessOwner* po = new HGProcessOwner();
            SpriteScaleProcess* ssp = new SpriteScaleProcess();
            ssp->init(po, pSpr, PXL2REAL(1000), PXL2REAL(1000), 16);
            
            // プロセス開始
            HGProcessManager::sharedProcessManager()->addProcess(ssp);
            
            // Wait
            HGProcessOwner* po2 = new HGProcessOwner();
            WaitProcess* wp = new WaitProcess();
            wp->init(po2, 10);
            
            // 透明化
            SpriteChangeOpacityProcess* scop = new SpriteChangeOpacityProcess();
            scop->init(po2, pSpr, 0, 8);
            wp->setNext(scop);
            
            // 削除
            NodeRemoveProcess* nrp = new NodeRemoveProcess();
            nrp->init(po2, pSpr);
            scop->setNext(nrp);
            
            // プロセス開始
            HGProcessManager::sharedProcessManager()->addProcess(wp);
            
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
            if (enemyFighterList.size() <= 3)
            {
                if (spawnCount < 100
                    &&
                    (enemyFighterList.size() == 0
                    || rand(1, 1000) < 10))
                {
                    spawnCount++;
                    if (rand(1, 10) <= 1)
                    {
                        spawnFighter(SideTypeEnemy, FighterTypeShip1, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
                    }
                    else
                    {
                        spawnFighter(SideTypeEnemy, FighterTypeRobo2, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
                    }
                }
            }
        }
        
        std::string getName()
        {
            return "BattleState";
        }
    private:
        int spawnCount = 0;
    };

    ////////////////////
    // 初期化
    void initialize()
    {
        srand((unsigned int)time(NULL));
        
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
        
        // layer
        if (pLayerBackground)
        {
            pLayerBackground->release();
        }
        pLayerBackground = new HGNode();
        pLayerBackground->retain();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerBackground);
        //
        if (pLayerEnemy)
        {
            pLayerEnemy->release();
        }
        pLayerEnemy = new HGNode();
        pLayerEnemy->retain();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerEnemy);
        //
        if (pLayerFriend)
        {
            pLayerFriend->release();
        }
        pLayerFriend = new HGNode();
        pLayerFriend->retain();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerFriend);
        //
        if (pLayerBullet)
        {
            pLayerBullet->release();
        }
        pLayerBullet = new HGNode();
        pLayerBullet->retain();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerBullet);
        //
        if (pLayerEffect)
        {
            pLayerEffect->release();
        }
        pLayerEffect = new HGNode();
        pLayerEffect->retain();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerEffect);
        
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
        
        // フィールド境界
        {
            HGSprite* pSprite = new HGSprite();
            pSprite->init("rect.png");
            //pSprite->setblendcolor({2.0,2.0,2.0,1.0});
            pSprite->setScale(sizeOfField.width*2, sizeOfField.height*2, 1);
            pSprite->setPosition(pointOfFieldCenter.x, pointOfFieldCenter.y);
            pLayerBackground->addChild(pSprite);
        }
        
        // player
        {
            if (pPlayer)
            {
                pPlayer->release();
            }
            pPlayer = new Fighter();
            pPlayer->init(pLayerFriend, SideTypeFriend, FighterTypeRobo1);
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
                    Fighter* pEnemy = new Fighter();
                    pEnemy->init(pLayerEnemy, SideTypeEnemy, FighterTypeShip1);
                    pEnemy->setPosition(0, 0);
                    enemyFighterList.addActor(pEnemy);
                    
                    ControlEnemyProcess* cp = new ControlEnemyProcess();
                    cp->init(pEnemy->getProcessOwner(), pEnemy);
        HGProcessManager::sharedProcessManager()->addProcess(cp);*/
        
        //spawnFighter(SideTypeEnemy, FighterTypeShip1, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
        //spawnFighter(SideTypeEnemy, FighterTypeShip1, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
        //spawnFighter(SideTypeEnemy, FighterTypeShip1, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
        
             //spawnFighter(SideTypeFriend, FighterTypeShip1, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
        /*
                    Fighter* pEnemy = new Fighter();
                    pEnemy->init(pLayerFriend, SideTypeFriend, FighterTypeShip1);
                    pEnemy->setPosition(0, 0);
                    friendFighterList.addActor(pEnemy);
                    ControlEnemyProcess* cp = new ControlEnemyProcess();
                    cp->init(pEnemy->getProcessOwner(), pEnemy);
                    HGProcessManager::sharedProcessManager()->addProcess(cp);
        */
        spawnFighter(SideTypeFriend, FighterTypeRobo1, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
        spawnFighter(SideTypeFriend, FighterTypeRobo1, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
        spawnFighter(SideTypeFriend, FighterTypeRobo1, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
        spawnFighter(SideTypeFriend, FighterTypeRobo1, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
        spawnFighter(SideTypeFriend, FighterTypeRobo1, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
        spawnFighter(SideTypeFriend, FighterTypeShip1, rand(0, sizeOfField.width), rand(0, sizeOfField.height));
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
            _cameraPosition.x = pPlayer->getPositionX() * -1;
            _cameraPosition.y = pPlayer->getPositionY() * -1 + 7;
            _cameraPosition.z = -18;
            _cameraRotate.x = -15 * M_PI/180;
            hgles::currentContext->cameraPosition = _cameraPosition;
            hgles::currentContext->cameraRotate = _cameraRotate;
            hgles::HGLES::updateCameraMatrix();
        }
        
        // ノードを描画
        HGDirector::sharedDirector()->drawRootNode();
    }
    

}