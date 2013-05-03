#import "HGame.h"
#import <list>
#import <stack>

#import "HGLES.h"
#import "HGLGraphics2D.h"

#import "HGameEngine.h"

#import <boost/shared_ptr.hpp>
#import <list>

////////////////////
// game define
#define IS_DEBUG_COLLISION 0
#define ENEMY_NUM 10
#define BULLET_NUM 100
#define ENEMY_BULLET_NUM 100
#define FIELD_SIZE 100
#define ZPOS 0
#define BACKGROUND_SCALE 2000
#define STAGE_SCALE 100
#define PIXEL_SCALE 0.01

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
    
    typedef struct KeyInfo
    {
        bool isFire;
        int degree;
        float power;
    } KeyInfo;
    
    ////////////////////
    // 変数宣言
    Vector _cameraPosition(0,0,0);
    Vector _cameraRotate(0,0,0);
    HGSize fieldSize(0,0);
    HGPoint pointOfFieldCenter(0,0);
    
    Fighter* pPlayer = NULL;
    HGNode* pLayerBackground = NULL;
    HGNode* pLayerPlayer = NULL;
    HGNode* pLayerBullet = NULL;
    HGProcessOwner* pPlayerControlOwner = NULL;
    
    KeyInfo keyInfo = {};
    
    ////////////////////
    // Actor
    class Actor : public HGObject
    {
    public:
        Actor():
        pNode(NULL),
        pixelSize(0,0),
        realSize(0,0),
        isInitialized(false)
        {
        };
        
        virtual void init(HGNode* pNodeParent)
        {
            this->pNode = new HGNode();
            pNodeParent->addChild(this->pNode);
            isInitialized = true;
        }
        
        void setPosition(float x, float y)
        {
            pNode->setPosition(x, y);
        }
        void setPositionX(float x)
        {
            pNode->setPositionX(x);
        }
        void setPositionY(float y)
        {
            pNode->setPositionY(y);
        }
        float getPositionX()
        {
            return pNode->getPositionX();
        }
        float getPositionY()
        {
            return pNode->getPositionY();
        }
        float getWidth()
        {
            return realSize.width;
        }
        float getHeight()
        {
            return realSize.height;
        }
        HGNode* getNode()
        {
            return pNode;
        }
        void setSizeByPixel(float width, float height)
        {
            pixelSize.width = width;
            pixelSize.height = height;
            realSize.width = pixelSize.width*PIXEL_SCALE;
            realSize.height = pixelSize.height*PIXEL_SCALE;
        }
        
    protected:
        HGNode* pNode;
    private:
        HGSize pixelSize;
        HGSize realSize;
        bool isInitialized;
    };
    
    
    ////////////////////
    // Bullet
    typedef enum BulletType
    {
        BULLET_TYPE_NORMAL,
    } BulletType;
    class Bullet : public Actor
    {
        typedef Actor base;
    public:
        Bullet():
        base()
        {
            pMoveOwner = new HGProcessOwner();
        }
        ~Bullet()
        {
            pOwner->release();
            pMoveOwner->release();
        }
        inline void init(BulletType type, int power, Actor* pOwner, float x, float y, float directionDegree)
        {
            assert(pOwner);
            base::init(pLayerBullet);
            this->power = power;
            this->pOwner = pOwner;
            pOwner->retain();
            this->type = type;
            switch (type) {
                case BULLET_TYPE_NORMAL:
                {
                    setSizeByPixel(200, 200);
                    HGSprite* pSprite = new HGSprite();
                    pSprite->setType(SPRITE_TYPE_BILLBOARD);
                    pSprite->init("divine.png");
                    pSprite->setScale(getWidth(), getHeight());
                    pSprite->shouldRenderAsAlphaMap(true);
                    pSprite->setColor({1,1,1,1});
                    pSprite->setBlendFunc(GL_ALPHA, GL_ALPHA);
                    pSprite->setPosition(x, y);
                    getNode()->addChild(pSprite);
                    pSprite->release();
                    
                    //BulletMoveProcess* bmp = new BulletMoveProcess();
                    //bmp->init(pMoveOwner, this, speed, directionDegree)
                    
                    //HGProcessManager::sharedProcessManager()->addPrcoess(ProcessPtr(new BulletMoveProcess(moveProcessOwner, speed,)))
                    break;
                }
                default:
                    break;
            }
        }
    private:
        int power;
        float speed;
        BulletType type;
        Actor* pOwner;
        HGProcessOwner* pMoveOwner;
    };
    
    ////////////////////
    // Weapon
    typedef enum WeaponType
    {
        WEAPON_TYPE_NORMAL,
    } WeaponType;
    class Weapon : public HGObject
    {
    public:
        Weapon():
        relativePosition(0,0),
        lastFireTime(0),
        fireInterval(0),
        type(WEAPON_TYPE_NORMAL),
        bulletType(BULLET_TYPE_NORMAL)
        {}
        
        ~Weapon()
        {
            
        }
        
        void init(WeaponType type, BulletType bulletType, float pixelX, float pixelY)
        {
            switch (type) {
                case WEAPON_TYPE_NORMAL:
                    fireInterval = 0.2;
                    power = 100;
                    break;
                default:
                    break;
            }
            this->type = type;
            this->bulletType = bulletType;
            relativePosition.x = pixelX*PIXEL_SCALE;
            relativePosition.y = pixelY*PIXEL_SCALE;
        }
        
        inline void fire(Actor* pOwner, float directionDegree)
        {
            if (getNowTime() - lastFireTime < fireInterval)
            {
                return;
            }
            lastFireTime = getNowTime();
            Bullet* bp = new Bullet();
            float x = pOwner->getPositionX() + relativePosition.x;
            float y = pOwner->getPositionY() + relativePosition.y;
            bp->init(bulletType, power, pOwner, x, y, directionDegree);
            bp->release();
        }
        
        int power;
        HGPoint relativePosition;
        double lastFireTime;
        double fireInterval;
        WeaponType type;
        BulletType bulletType;
    };
    
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
    // bullet移動プロセス
    class BulletMoveProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        BulletMoveProcess() :
        base(),
        vx(0),
        vy(0),
        speed(0),
        directionDegree(0),
        pBullet(NULL)
        {
        };
        ~BulletMoveProcess()
        {
            pBullet->release();
        }
    protected:
        void init(HGProcessOwner* pProcOwner, Bullet* inBullet, float speed, float directionDegree)
        {
            base::init(pProcOwner);
            pBullet = inBullet;
            pBullet->retain();
            this->speed = speed;
            this->directionDegree = directionDegree;
            float r = toRad(keyInfo.degree);
            vx = cos(r) * speed;
            vy = sin(r) * speed * -1;
        }
        void onUpdate()
        {
            HGNode* n = pBullet->getNode();
            n->addPosition(vx, vy);
            // フィールド外チェック
            float x = pBullet->getPositionX();
            float y = pBullet->getPositionY();
            float w = pBullet->getWidth();
            float h = pBullet->getHeight();
            if (x + w/2 > fieldSize.width)
            {
                pBullet->setPositionX(fieldSize.width - w/2);
            }
            if (y + h/2 > fieldSize.height)
            {
                pBullet->setPositionY(fieldSize.height - h/2);
            }
            if (x - w/2 < 0)
            {
                pBullet->setPositionX(w/2);
            }
            if (y - h/2 < 0)
            {
                pBullet->setPositionY(h/2);
            }
        }
        std::string getName()
        {
            return "BulletMoveProcess";
        }
    private:
        Bullet* pBullet;
        float vx;
        float vy;
        float directionDegree;
        float speed;
    };
    
    ////////////////////
    // 自キャラ移動プロセス
    class PlayerControlProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        PlayerControlProcess() :
        base(),
        vx(0),
        vy(0),
        pFighter(NULL)
        {
        };
        ~PlayerControlProcess()
        {
            pFighter->release();
        }
        void init(HGProcessOwner* pProcOwner, Fighter* inFighter)
        {
            base::init(pProcOwner);
            pFighter = inFighter;
            pFighter->retain();
        }
    protected:
        void onUpdate()
        {
            if (keyInfo.power != 0)
            {
                pFighter->setAspectDegree(keyInfo.degree);
            }
            if (pFighter->getLife() > 0)
            {
                float speed = pFighter->speed*keyInfo.power;
                float r = toRad(keyInfo.degree);
                vx = cos(r) * speed;
                vy = sin(r) * speed * -1;
            }
            pFighter->getNode()->addPosition(vx, vy);
            
            if (pFighter->getLife() > 0)
            {
                // フィールド外チェック
                float x = pFighter->getPositionX();
                float y = pFighter->getPositionY();
                float w = pFighter->getWidth();
                float h = pFighter->getHeight();
                if (x + w/2 > fieldSize.width)
                {
                    pFighter->setPositionX(fieldSize.width - w/2);
                }
                if (y + h/2 > fieldSize.height)
                {
                    pFighter->setPositionY(fieldSize.height - h/2);
                }
                if (x - w/2 < 0)
                {
                    pFighter->setPositionX(w/2);
                }
                if (y - h/2 < 0)
                {
                    pFighter->setPositionY(h/2);
                }
            }
            if (keyInfo.isFire)
            {
                pFighter->fire();
            }
            
        }
        std::string getName()
        {
            return "PlayerControlProcess";
        }
    private:
        Fighter* pFighter;
        float vx;
        float vy;
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
        
        // nebula
        /* 見た目が微妙なので
        {
            HGSprite* pSprite = HGSprite*(new HGSprite());
            pSprite->init("proc_sheet_nebula.png");
            int SIZE = rand(1000, 1800);
            pSprite->setScale(SIZE, SIZE, SIZE);
            float x = rand(0, STAGE_SCALE) + pointOfFieldCenter.x;
            float y = rand(0, STAGE_SCALE) + pointOfFieldCenter.y;
            float z = -1*BACKGROUND_SCALE/2 + ZPOS;
            pSprite->setPosition(x, y, z);
            pSprite->setRotate(0, 0, toRad(rand(0, 360)));
            pSprite->setTextureRect(rand(0,4)*256, rand(0,4)*256, 256, 256);
            pSprite->setBlendFunc(GL_ONE, GL_ONE);
            pLayerBackground->addChild(pSprite);
        }*/
        
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
            PlayerControlProcess* p = new PlayerControlProcess();
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