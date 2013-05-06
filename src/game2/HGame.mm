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
    const int CELL_SPLIT_NUM = 10;
    HGSize sizeOfCell = {FIELD_SIZE/CELL_SPLIT_NUM, FIELD_SIZE/CELL_SPLIT_NUM};
    class CellManager : HGObject
    {
    public:
        typedef std::list<Actor*> ActorList;
        typedef std::vector<ActorList> CellList;
        typedef std::list<int> CellNumberList;
        CellManager()
        {
            list.resize(CELL_SPLIT_NUM*CELL_SPLIT_NUM);
        }
        void clear()
        {
            //for_each(list.begin(), list.end(), Clear());
            for (CellList::iterator it = list.begin(); it != list.end(); it++)
            {
                (*it).clear();
            }
        }
        void addToCellList(Actor* actor)
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
    HGNode* pLayerPlayer = NULL;
    HGNode* pLayerBullet = NULL;
    HGNode* pLayerEffect = NULL;
    HGProcessOwner* pPlayerControlOwner = NULL;
    
    ActorList<Bullet> friendBulletList;
    ActorList<Bullet> enemyBulletList;
    ActorList<Fighter> friendFighterList;
    ActorList<Fighter> enemyFighterList;
    CellManager enemyBulletCellManager;
    CellManager friendBulletCellManager;
    
    KeyInfo keyInfo = {};
    HGSize sizeOfField(0,0);
    HGPoint pointOfFieldCenter(0,0);
    
    // アニメ
    void showHitAnimation(Actor* a)
    {
        HitAnimeProcess* pHitAnimeProcess = new HitAnimeProcess();
        HGProcessOwner* pHo = new HGProcessOwner();
        pHitAnimeProcess->init(pHo, a->getPosition(), pLayerEffect);
        HGProcessManager::sharedProcessManager()->addPrcoess(pHitAnimeProcess);
        pHitAnimeProcess->release();
        pHo->release();
    }
    
    // add actor to cell
    void addActorsToCells()
    {
        friendBulletCellManager.clear();
        struct AddFriendBullets
        {
            void operator()(Actor* actor) {friendBulletCellManager.addToCellList(actor);}
        };
        for_each(friendBulletList.begin(), friendBulletList.end(), AddFriendBullets());
        
        enemyBulletCellManager.clear();
        struct AddEnemyBullets
        {
            void operator()(Actor* actor) {enemyBulletCellManager.addToCellList(actor);}
        };
        for_each(enemyBulletList.begin(), enemyBulletList.end(), AddEnemyBullets());
    }
    
    // あたり判定
    void checkCollisionEnemy(ActorList<Fighter>& fighterList, CellManager& bulletCellManager)
    {
        CollisionManager* pColMgr = CollisionManager::sharedCollisionManager();
        for (ActorList<Fighter>::iterator it = enemyFighterList.begin(); it != enemyFighterList.end(); it++)
        {
            if (!(*it)->isActive() || !(*it)->getLife() > 0)
            {
                continue;
            }
            CollisionId cida = (*it)->getCollisionId();
            Vector posa = (*it)->getPosition();
            HGSize sizea = (*it)->getSize();
            
            CellManager::CellNumberList tList;
            CellManager::GetCellList(*it, tList);
            
            for (CellManager::CellNumberList::iterator it = tList.begin(); it != tList.end(); it++)
            {
                int cellNumber = (*it);
                CellManager::ActorList actorList = friendBulletCellManager.getActorList(cellNumber);
                
                for (CellManager::ActorList::iterator it = actorList.begin(); it != actorList.end(); it++)
                {
                    Actor* a = *it;
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
                        showHitAnimation(a);
                        a->setActive(false);
                    }
                }
            }
            
        }
    }
    
    void checkCollisionFriend()
    {
        CollisionManager* pColMgr = CollisionManager::sharedCollisionManager();
        for (ActorList<Fighter>::iterator it = friendFighterList.begin(); it != friendFighterList.end(); it++)
        {
            CollisionId cida = (*it)->getCollisionId();
            Vector posa = (*it)->getPosition();
            HGSize sizea = (*it)->getSize();
            for (ActorList<Bullet>::iterator itj = enemyBulletList.begin(); itj != enemyBulletList.end(); itj++)
            {
                CollisionId cidb = (*itj)->getCollisionId();
                Vector posb = (*itj)->getPosition();
                HGSize sizeb = (*itj)->getSize();
                if (pColMgr->isIntersect(cida, posa, sizea, cidb, posb, sizeb))
                {
                    //HDebug(@"HIT");
                    showHitAnimation(*it);
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
            checkCollisionEnemy();
            checkCollisionFriend();
            
            // remove inactive actors
            friendBulletList.removeInactiveActors();
            enemyBulletList.removeInactiveActors();
            friendFighterList.removeInactiveActors();
            enemyFighterList.removeInactiveActors();
        }
        std::string getName()
        {
            return "BattleState";
        }
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
        s->release();
        
        // field size
        sizeOfField = {FIELD_SIZE, FIELD_SIZE};
        pointOfFieldCenter = {sizeOfField.width/2, sizeOfField.height/2};
        
        // layer
        if (pLayerBackground)
        {
            pLayerBackground->release();
        }
        pLayerBackground = new HGNode();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerBackground);
        //
        if (pLayerPlayer)
        {
            pLayerPlayer->release();
        }
        pLayerPlayer = new HGNode();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerPlayer);
        //
        if (pLayerBullet)
        {
            pLayerBullet->release();
        }
        pLayerBullet = new HGNode();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerBullet);
        //
        if (pLayerEffect)
        {
            pLayerEffect->release();
        }
        pLayerEffect = new HGNode();
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
            pSprite->release();
        }
        
        // player
        {
            if (pPlayer)
            {
                pPlayer->release();
            }
            pPlayer = new Fighter();
            pPlayer->init(pLayerPlayer, SideTypeFriend, FighterTypeRobo1);
            pPlayer->setPosition(sizeOfField.width/2, sizeOfField.height/2);
            pPlayerControlOwner = new HGProcessOwner;
            friendFighterList.addActor(pPlayer);
        }
        
        if (pPlayer)
        {
            ControlPlayerProcess* p = new ControlPlayerProcess();
            p->init(pPlayerControlOwner, pPlayer);
            HGProcessManager::sharedProcessManager()->addPrcoess(p);
            p->release();
        }
        
        // enemy
        {
            Fighter* pEnemy = new Fighter();
            pEnemy->init(pLayerPlayer, SideTypeEnemy, FighterTypeRobo2);
            pEnemy->setPosition(sizeOfField.width/2, sizeOfField.height/2);
            enemyFighterList.addActor(pEnemy);
            
            /*
            ControlEnemyProcess* cp = new ControlEnemyProcess();
            cp->init(pEnemy->getProcessOwner(), pEnemy);
            HGProcessManager::sharedProcessManager()->addPrcoess(cp);
            cp->release();
            */
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