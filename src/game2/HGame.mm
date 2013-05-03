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

#include <boost/shared_ptr.hpp>
#include <list>

namespace hg {
    
    class Actor;
    class Fighter;
    class Weapon;
    class Bullet;
    class BulletMoveProcess;
    
    typedef enum
    {
        ENEMY_SIDE,
        FRIEND_SIDE,
    } WHICH_SIDE;
    
    ////////////////////
    // 変数宣言
    Vector _cameraPosition(0,0,0);
    Vector _cameraRotate(0,0,0);
    
    
    Fighter* pPlayer = NULL;
    HGNode* pLayerBackground = NULL;
    HGNode* pLayerPlayer = NULL;
    HGNode* pLayerBullet = NULL;
    HGProcessOwner* pPlayerControlOwner = NULL;
    
    KeyInfo keyInfo = {};
    HGSize fieldSize(0,0);
    HGPoint pointOfFieldCenter(0,0);
    
    
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
        
        // process
        HGProcessManager::sharedProcessManager()->clear();
        
        // state
        HGStateManager::sharedStateManger()->clear();
        HGState* s = new BattleState();
        HGStateManager::sharedStateManger()->push(s);
        
        // field size
        fieldSize = {FIELD_SIZE, FIELD_SIZE};
        pointOfFieldCenter = {fieldSize.width/2, fieldSize.height/2};
        
        // layer
        pLayerBackground = new HGNode();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerBackground);
        pLayerPlayer = new HGNode();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerPlayer);
        pLayerBullet = new HGNode();
        HGDirector::sharedDirector()->getRootNode()->addChild(pLayerBullet);
        
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
            pSprite->setScale(fieldSize.width*2, fieldSize.height*2, 1);
            pSprite->setPosition(pointOfFieldCenter.x, pointOfFieldCenter.y);
            pLayerBackground->addChild(pSprite);
        }
        
        // player
        {
            pPlayer = new Fighter();
            pPlayer->init(pLayerPlayer);
            pPlayer->setPosition(fieldSize.width/2, fieldSize.height/2);
            pPlayerControlOwner = new HGProcessOwner;
        }
        
        if (pPlayer)
        {
            ControlPlayerProcess* p = new ControlPlayerProcess();
            p->init(pPlayerControlOwner, pPlayer);
            HGProcessManager::sharedProcessManager()->addPrcoess(p);
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