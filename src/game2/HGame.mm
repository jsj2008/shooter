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
    typedef boost::shared_ptr<Actor> ActorPtr;
    typedef boost::shared_ptr<Fighter> FighterPtr;
    typedef boost::shared_ptr<Weapon> WeaponPtr;
    typedef boost::shared_ptr<Bullet> BulletPtr;
    
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
    FighterPtr playerPtr = NULL;
    Vector _cameraPosition(0,0,0);
    Vector _cameraRotate(0,0,0);
    HGSize fieldSize(0,0);
    HGPoint pointOfFieldCenter(0,0);
    NodePtr layerBackground = NULL;
    NodePtr layerPlayer = NULL;
    NodePtr layerBullet = NULL;
    ProcessOwnerPtr movePlayerProcOwner;
    KeyInfo keyInfo;

    ////////////////////
    // Actor
    class Actor : public HGObject
    {
    public:
        Actor():
        nodePtr(NULL),
        pixelSize(0,0),
        realSize(0,0),
        isInitialized(false)
        {
        };
        
        virtual void init(NodePtr parentPtr)
        {
            nodePtr = NodePtr(new HGNode());
            parentPtr->addChild(nodePtr);
            isInitialized = true;
        }
        
        void setPosition(float x, float y)
        {
            nodePtr->setPosition(x, y);
        }
        void setPositionX(float x)
        {
            nodePtr->setPositionX(x);
        }
        void setPositionY(float y)
        {
            nodePtr->setPositionY(y);
        }
        float getPositionX()
        {
            return nodePtr->getPositionX();
        }
        float getPositionY()
        {
            return nodePtr->getPositionY();
        }
        float getWidth()
        {
            return realSize.width;
        }
        float getHeight()
        {
            return realSize.height;
        }
        NodePtr getNodePtr()
        {
            return nodePtr;
        }
        void setSizeByPixel(float width, float height)
        {
            pixelSize.width = width;
            pixelSize.height = height;
            realSize.width = pixelSize.width*PIXEL_SCALE;
            realSize.height = pixelSize.height*PIXEL_SCALE;
        }
        
    protected:
        NodePtr nodePtr;
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
            moveProcessOwner = ProcessOwnerPtr(new HGProcessOwner());
        }
        void init(BulletType type, int power, ActorPtr ownerPtr, float x, float y)
        {
            base::init(layerBullet);
            this->power = power;
            this->ownerPtr = ownerPtr;
            this->type = type;
            switch (type) {
                case BULLET_TYPE_NORMAL:
                {
                    setSizeByPixel(200, 200);
                    SpritePtr spritePtr = SpritePtr(new HGSprite());
                    spritePtr->setType(SPRITE_TYPE_BILLBOARD);
                    spritePtr->init("divine.png");
                    spritePtr->setScale(getWidth(), getHeight());
                    spritePtr->shouldRenderAsAlphaMap(true);
                    spritePtr->setColor({1,1,1,1});
                    spritePtr->setBlendFunc(GL_ALPHA, GL_ALPHA);
                    spritePtr->setPosition(x, y);
                    getNodePtr()->addChild(spritePtr);
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
        ActorPtr ownerPtr;
        ProcessOwnerPtr moveProcessOwner;
    };
    
    ////////////////////
    // Weapon
    typedef enum WeaponType
    {
        WEAPON_TYPE_NORMAL,
    } WeaponType;
    class Weapon
    {
    public:
        Weapon():
        relativePosition(0,0),
        lastFireTime(0),
        fireInterval(0),
        type(WEAPON_TYPE_NORMAL),
        bulletType(BULLET_TYPE_NORMAL)
        {}
        
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
        
        void fire(ActorPtr ownerPtr, float directionDegree)
        {
            if (getNowTime() - lastFireTime < fireInterval)
            {
                return;
            }
            lastFireTime = getNowTime();
            BulletPtr bp = BulletPtr(new Bullet());
            float x = ownerPtr->getPositionX() + relativePosition.x;
            float y = ownerPtr->getPositionY() + relativePosition.y;
            bp->init(bulletType, power, ownerPtr, x, y);
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
    typedef std::list<WeaponPtr> WeaponList;
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
        
        void init(NodePtr layerParent)
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
                WeaponPtr wp = WeaponPtr(new Weapon());
                wp->init(WEAPON_TYPE_NORMAL, BULLET_TYPE_NORMAL , 0, 0);
                weaponList.push_back(wp);
            }
            
            spritePtr = SpritePtr(new HGSprite());
            spritePtr->setType(SPRITE_TYPE_BILLBOARD);
            spritePtr->init(textureName);
            spritePtr->setScale(getWidth(), getHeight());
            getNodePtr()->addChild(spritePtr);
            
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
            spritePtr->setTextureRect(x - 1, textureSrcOffset.y, textureSrcSize.width, textureSrcSize.height);
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
        
        void fire(FighterPtr thisPtr)
        {
            for (WeaponList::iterator it = weaponList.begin(); it != weaponList.end(); ++it)
            {
                (*it)->fire(thisPtr, this->aspectDegree);
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
        SpritePtr spritePtr;
        
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
        BulletMoveProcess(ProcessOwnerPtr processOwnerPtr, BulletPtr inBulletPtr, float speed, float directionDegree) :
        base(processOwnerPtr),
        vx(0),
        vy(0),
        speed(speed),
        directionDegree(directionDegree),
        bulletPtr(inBulletPtr)
        {
        };
    protected:
        void onInit()
        {
            float r = toRad(keyInfo.degree);
            vx = cos(r) * speed;
            vy = sin(r) * speed * -1;
        }
        void onUpdate()
        {
            NodePtr n = bulletPtr->getNodePtr();
            n->addPosition(vx, vy);
            // フィールド外チェック
            float x = bulletPtr->getPositionX();
            float y = bulletPtr->getPositionY();
            float w = bulletPtr->getWidth();
            float h = bulletPtr->getHeight();
            if (x + w/2 > fieldSize.width)
            {
                bulletPtr->setPositionX(fieldSize.width - w/2);
            }
            if (y + h/2 > fieldSize.height)
            {
                bulletPtr->setPositionY(fieldSize.height - h/2);
            }
            if (x - w/2 < 0)
            {
                bulletPtr->setPositionX(w/2);
            }
            if (y - h/2 < 0)
            {
                bulletPtr->setPositionY(h/2);
            }
        }
        std::string getName()
        {
            return "BulletMoveProcess";
        }
    private:
        BulletPtr bulletPtr;
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
        PlayerControlProcess(ProcessOwnerPtr processOwnerPtr, NodePtr inNode, FighterPtr inFighterPtr) :
        base(processOwnerPtr),
        node(inNode),
        vx(0),
        vy(0),
        fighterPtr(inFighterPtr)
        {
        };
    protected:
        void onInit()
        {
        }
        void onUpdate()
        {
            if (keyInfo.power != 0)
            {
                fighterPtr->setAspectDegree(keyInfo.degree);
            }
            if (fighterPtr->getLife() > 0)
            {
                float speed = fighterPtr->speed*keyInfo.power;
                float r = toRad(keyInfo.degree);
                vx = cos(r) * speed;
                vy = sin(r) * speed * -1;
            }
            node->addPosition(vx, vy);
            
            if (fighterPtr->getLife() > 0)
            {
                // フィールド外チェック
                float x = fighterPtr->getPositionX();
                float y = fighterPtr->getPositionY();
                float w = fighterPtr->getWidth();
                float h = fighterPtr->getHeight();
                if (x + w/2 > fieldSize.width)
                {
                    fighterPtr->setPositionX(fieldSize.width - w/2);
                }
                if (y + h/2 > fieldSize.height)
                {
                    fighterPtr->setPositionY(fieldSize.height - h/2);
                }
                if (x - w/2 < 0)
                {
                    fighterPtr->setPositionX(w/2);
                }
                if (y - h/2 < 0)
                {
                    fighterPtr->setPositionY(h/2);
                }
            }
            if (keyInfo.isFire)
            {
                fighterPtr->fire(fighterPtr);
            }
            
        }
        std::string getName()
        {
            return "PlayerControlProcess";
        }
    private:
        NodePtr node;
        FighterPtr fighterPtr;
        float vx;
        float vy;
    };

    ////////////////////
    // 初期化
    void initialize()
    {
        srand((unsigned int)time(NULL));
        
        HGDirector::sharedDirector()->getRootNode()->removeAllChildren();
        
        // process
        HGProcessManager::sharedProcessManager()->clear();
        
        // state
        HGStateManager::sharedStateManger()->clear();
        StatePtr s = StatePtr(new BattleState());
        HGStateManager::sharedStateManger()->push(s);
        
        // field size
        fieldSize = {FIELD_SIZE, FIELD_SIZE};
        pointOfFieldCenter = {fieldSize.width/2, fieldSize.height/2};
        
        // layer
        layerBackground = NodePtr(new HGNode());
        HGDirector::sharedDirector()->getRootNode()->addChild(layerBackground);
        layerPlayer = NodePtr(new HGNode());
        HGDirector::sharedDirector()->getRootNode()->addChild(layerPlayer);
        layerBullet = NodePtr(new HGNode());
        HGDirector::sharedDirector()->getRootNode()->addChild(layerBullet);
        
        // background
        for (int i = 0; i < 5; ++i)
        {
            SpritePtr spritePtr = SpritePtr(new HGSprite());
            spritePtr->init("space.png");
            spritePtr->setScale(BACKGROUND_SCALE, BACKGROUND_SCALE, BACKGROUND_SCALE);
            switch (i) {
                case 0:
                    spritePtr->setPosition(-1 * BACKGROUND_SCALE / 2 + pointOfFieldCenter.x, pointOfFieldCenter.y, ZPOS);
                    spritePtr->setRotate(0, 90*M_PI/180, 0);
                    break;
                case 1:
                    spritePtr->setPosition(BACKGROUND_SCALE/2+pointOfFieldCenter.x, pointOfFieldCenter.y, ZPOS);
                    spritePtr->setRotate(0, -90*M_PI/180, 180*M_PI/180);
                    break;
                case 2:
                    spritePtr->setPosition(pointOfFieldCenter.x, BACKGROUND_SCALE/2+pointOfFieldCenter.y, ZPOS);
                    spritePtr->setRotate(-90*M_PI/180, 0, 0);
                    break;
                case 3:
                    spritePtr->setPosition(pointOfFieldCenter.x, -BACKGROUND_SCALE/2+pointOfFieldCenter.y, ZPOS);
                    spritePtr->setRotate(90*M_PI/180, 0, 0);
                    break;
                case 4:
                    spritePtr->setPosition(pointOfFieldCenter.x, pointOfFieldCenter.y, -1*BACKGROUND_SCALE/2 + ZPOS);
                    spritePtr->setRotate(0, 0, 0);
                    break;
                    /*
                case 5:
                    t->position.set(0, 0, 1*BACKGROUND_SCALE/2 + ZPOS);
                    t->rotate.set(180*M_PI/180, 0, 0);
                    break;*/
                default:
                    break;
            }
            layerBackground->addChild(spritePtr);
        }
        
        // nebula
        /* 見た目が微妙なので
        {
            SpritePtr spritePtr = SpritePtr(new HGSprite());
            spritePtr->init("proc_sheet_nebula.png");
            int SIZE = rand(1000, 1800);
            spritePtr->setScale(SIZE, SIZE, SIZE);
            float x = rand(0, STAGE_SCALE) + pointOfFieldCenter.x;
            float y = rand(0, STAGE_SCALE) + pointOfFieldCenter.y;
            float z = -1*BACKGROUND_SCALE/2 + ZPOS;
            spritePtr->setPosition(x, y, z);
            spritePtr->setRotate(0, 0, toRad(rand(0, 360)));
            spritePtr->setTextureRect(rand(0,4)*256, rand(0,4)*256, 256, 256);
            spritePtr->setBlendFunc(GL_ONE, GL_ONE);
            layerBackground->addChild(spritePtr);
        }*/
        
        // フィールド境界
        {
            SpritePtr spritePtr = SpritePtr(new HGSprite());
            spritePtr->init("rect.png");
            //spritePtr->setblendcolor({2.0,2.0,2.0,1.0});
            spritePtr->setScale(fieldSize.width*2, fieldSize.height*2, 1);
            spritePtr->setPosition(pointOfFieldCenter.x, pointOfFieldCenter.y);
            layerBackground->addChild(spritePtr);
        }
        
        // player
        {
            playerPtr = FighterPtr(new Fighter());
            playerPtr->init(layerPlayer);
            playerPtr->setPosition(fieldSize.width/2, fieldSize.height/2);
            movePlayerProcOwner = ProcessOwnerPtr(new HGProcessOwner);
        }
        
        if (playerPtr)
        {
            ProcessPtr p = ProcessPtr(new PlayerControlProcess(movePlayerProcOwner, playerPtr->getNodePtr(), playerPtr));
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
        if (playerPtr)
        {
            _cameraPosition.x = playerPtr->getPositionX() * -1;
            _cameraPosition.y = playerPtr->getPositionY() * -1 + 7;
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