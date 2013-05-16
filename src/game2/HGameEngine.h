#ifndef __HGAME_ENGINE_H__
#define __HGAME_ENGINE_H__

#import "HGLES.h"
#import "HGLGraphics2D.h"

#import "HTypes.h"

#import <boost/shared_ptr.hpp>
#import <list>
#import <map>
#include <sys/timeb.h>

#define GAMEFPS 30
#define HDebug(A, ...) NSLog(@"[Debug] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define HInfo(A, ...) NSLog(@"[Info] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define HError(A, ...) NSLog(@"[###ERROR###] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define IS_PROCESS_DEBUG 0
#define IS_DEBUG_MEMORY 0

namespace hg
{
    
    const std::string SYSTEM_HEAP_NAME = "SYSTEM HEAP";
    const std::string DEFAULT_HEAP_NAME = "DEFAULT HEAP";
    
    class HGNode;
    class HGSprite;
    class HGBillboardSprite;
    class HGState;
    class HGDirector;
    class HGStateManager;
    class HGProcessManager;
    class HGProcess;
    class HGProcessOwner;
    class HGObject;
    class HGHeap;
    class HGHeapFactory;
    
    ////////////////////
    // 便利関数
    int f(float frame);
    float v(float vec);
    int rand(int from, int to);
    float toDeg(float radian);
    float toRad(float degree);
    void updateNowTime();
    double getNowTime();

    ////////////////////
    // メモリ管理
    
    // ヒープ
    class HGHeap
    {
    public:
        const char SIGNATURE = 0xDEADC0DE;
        const char ENDMARKER = 0xDEADC0DE;
        std::string getName();
        void* alloc(size_t size);
        void deleteAllocation(void *pMem);
        void freeAll();
        void retain(void *pMem);
        void release(void *pMem);
        
    private:
        HGHeap(std::string name):
        objectCount(0),
        name(name),
        allocatedSize(0),
        pFirst(NULL),
        pLast(NULL)
        {
        }
        std::string name;
        size_t allocatedSize;
        AllocHeader* pFirst;
        AllocHeader* pLast;
        int objectCount;
        void addAllocation(size_t size);
        void removeAllocation(size_t size);
        
        friend class HGHeapFactory;
    };
    class HGHeapFactory
    {
    public:
        static HGHeap* CreateHeap(std::string name);
    private:
        static std::map<std::string,HGHeap*> heapList;
    };
    
    ////////////////////
    // 基底
    class HGObject
    {
    public:
        HGObject():
        refCount(1)
        {};
        virtual ~HGObject(){};
        static void* operator new(size_t size);
        static void* operator new(size_t size, std::string heapName);
        //static void operator delete(void *p, size_t size);
        inline void retain()
        {
            refCount++;
            s_pHeap->retain(this);
        }
        inline void release()
        {
            assert(refCount > 0);
            refCount--;
            if (refCount== 0)
            {
                this->~HGObject();
            }
            s_pHeap->release(this);
            assert(refCount >= 0);
        }
    
    private:
        static HGHeap* s_pHeap;
        int refCount;
    };
    
    ////////////////////
    // ステート管理
    class HGState : public HGObject
    {
        typedef HGObject base;
    public:
        HGState();
        virtual void onUpdate(){}
        virtual std::string getName();
        virtual void onSuspend(){}
        virtual void onResume(){}
        void update();
        void suspend();
        void resume();
        virtual ~HGState(){}
    private:
        int frameCount;
        bool isInitialUpdate;
    };

    class HGStateManager : public HGObject
    {
    public:
        typedef std::stack<HGState*> stateStack;
        stateStack stack;
        static HGStateManager* sharedStateManger();
        void clear();
        void update();
        void pop();
        void push(HGState* state);
        ~HGStateManager(){}
    private:
        HGStateManager(){};
    };
    
    ////////////////////
    // プロセス管理
    
    // プロセスオーナークラス
    class HGProcessOwner : public HGObject
    {
        typedef HGObject base;
    public:
        HGProcessOwner():
        base(),
        pProcess(NULL)
        {}
        ~HGProcessOwner()
        {
        }
        inline void setProcess(HGProcess* pProcess)
        {
            this->pProcess = pProcess;
        }
        inline HGProcess* getProcess()
        {
            return this->pProcess;
        }
    private:
        HGProcess* pProcess;
        
    };
    
    // プロセスクラス
    class HGProcess : public HGObject
    {
        typedef HGObject base;
    public:
        HGProcess():
        base(),
        pOwner(NULL),
        pNextProcess(NULL),
        frameCount(0),
        _isEnd(false),
        isIntercepted(false),
        isInitialUpdate(true),
        isInitialized(false)
        {
        };
        inline virtual void init(HGProcessOwner* pOwner)
        {
            this->pOwner = pOwner;
            pOwner->retain();
            isInitialized = true;
        }
        void setNext(HGProcess* nextPtr);
    protected:
        virtual void onEnd(){}
        virtual void onUpdate(){}
        virtual void onIntercept(){}
        virtual std::string getName();
        inline void setEnd()
        {
            this->_isEnd = true;
        }
        inline bool isEnd()
        {
            return _isEnd;
        }
        virtual ~HGProcess()
        {
            if (this->pNextProcess)
            {
                pNextProcess->release();
            }
            pOwner->release();
            //base::~HGObject();
        }
        inline int& getFrameCount()
        {
            return frameCount;
        }
    private:
        int frameCount;
        bool isInitialUpdate;
        bool _isEnd;
        bool isIntercepted;
        bool isInitialized;
        HGProcessOwner* pOwner;
        HGProcess* pNextProcess;
        inline HGProcessOwner* getOwner()
        {
            return pOwner;
        }
        inline void setIntercepted()
        {
            this->isIntercepted = true;
        }
        inline void update()
        {
            assert(isInitialized);
            assert(!this->_isEnd);
            this->onUpdate();
            frameCount++;
            isInitialUpdate = false;
        }
        inline void end()
        {
            this->onEnd();
        }
        inline void intercept()
        {
            this->onIntercept();
        }
        friend class HGProcessManager;
    };
    
    // プロセス管理クラス
    typedef std::list<HGProcess*> ProcessList;
    static HGProcessManager* hgProcessManagerPtr = NULL;
    class HGProcessManager : HGObject
    {
    public:
        static inline HGProcessManager* sharedProcessManager()
        {
            if (!hgProcessManagerPtr)
            {
                hgProcessManagerPtr = new (SYSTEM_HEAP_NAME)HGProcessManager();
                hgProcessManagerPtr->init();
            }
            return hgProcessManagerPtr;
        }
        HGProcessManager(){}
        void clear();
        void addProcess(HGProcess* pProcess);
        void update();
    private:
        ProcessList processList;
        ProcessList addProcessList;
        ProcessList delProcessList;
        void init();
    };
    
    
    ////////////////////
    // ノード
    typedef std::list<HGNode*> Children;
    class HGNode : public HGObject
    {
    public:
        HGNode():
        size(0,0),
        scale(1,1,1),
        position(0,0,0),
        rotate(0,0,0),
        parent(NULL)
        {
        }
        virtual ~HGNode(){
            this->removeAllChildren();
            if (parent)
            {
                //parent->release(); 相互参照になってしまふ
                parent = NULL;
            }
            //HGObject::~HGObject();
        }
        
        inline void removeAllChildren()
        {
            for (Children::iterator itr = children.begin(); itr != children.end(); itr++)
            {
                (*itr)->release();
            }
            children.clear();
        }
        
        inline void removeChild(HGNode* node)
        {
            children.remove(node);
            node->release();
        }
        
        inline void removeFromParent()
        {
            assert(parent);
            parent->removeChild(this);
        }
        
        inline void addChild(HGNode* node)
        {
            assert(node != this);
            assert(node->parent == NULL);
            node->retain();
            children.push_back(node);
            node->setParent(this);
        }
        
        inline void setParent(HGNode* node)
        {
            if (parent != NULL)
            {
                parent->release();
            }
            //node->retain(); 相互参照になってしまふ
            parent = node;
        }
        
        inline void setScale(float scaleX, float scaleY)
        {
            this->scale.x = scaleX;
            this->scale.y = scaleY;
        }
        
        inline void setScale(float scaleX, float scaleY, float scaleZ)
        {
            this->scale.x = scaleX;
            this->scale.y = scaleY;
            this->scale.z = scaleZ;
        }
        inline float getScaleX()
        {
            return this->scale.x;
        }
        inline float getScaleY()
        {
            return this->scale.y;
        }
        inline void setRotate(float x, float y, float z)
        {
            this->rotate.set(x, y, z);
        }
        
        inline void draw(Vector& parentPosition, Vector& parentScale, Vector& parentRotate)
        {
            worldPosition.x = position.x + parentPosition.x;
            worldPosition.y = position.y + parentPosition.y;
            worldPosition.z = position.z + parentPosition.z;
            
            worldScale.x = scale.x * parentScale.x;
            worldScale.y = scale.y * parentScale.y;
            worldScale.z = scale.z * parentScale.z;
            
            WorldRotate.x = rotate.x + parentRotate.x;
            WorldRotate.y = rotate.y + parentRotate.y;
            WorldRotate.z = rotate.z + parentRotate.z;
            
            this->render();
            for (Children::iterator itr = children.begin(); itr != children.end(); itr++)
            {
                (*itr)->draw(worldPosition, worldScale, WorldRotate);
            }
            
        }
        
        inline void addPosition(float x, float y)
        {
            position.x = position.x + x;
            position.y = position.y + y;
        }
        inline void setPosition(float x, float y)
        {
            position.x = x;
            position.y = y;
        }
        inline void setPositionX(float x)
        {
            position.x = x;
        }
        inline void setPositionY(float y)
        {
            position.y = y;
        }
        inline void setPosition(float x, float y, float z)
        {
            position.x = x;
            position.y = y;
            position.z = z;
        }
        
        inline float getPositionX()
        {
            return position.x;
        }
        
        inline float getPositionY()
        {
            return position.y;
        }
        
        inline float getPositionZ()
        {
            return position.z;
        }
        
        inline void setRotateZ(float radian)
        {
            this->rotate.z = radian;
        }
        
        inline Vector& getPosition()
        {
            return position;
        }
    protected:
        virtual void render(){};
        
        Vector position;
        Vector scale;
        Vector rotate;
        
        Vector worldPosition;
        Vector worldScale;
        Vector WorldRotate;
        
        HGSize size;
    private:
        HGNode* parent;
        Children children;
    };
    
    ////////////////////
    // スプライト
    typedef enum SpriteType
    {
        SPRITE_TYPE_NORMAL,
        SPRITE_TYPE_BILLBOARD,
    } SpriteType;
    
    class HGSprite: public HGNode
    {
    public:
        HGSprite():
        HGNode(),
        textureSize(0,0),
        isTextureInitialized(false),
        textureName(""),
        textureRect(0,0,0,0),
        isTextureRectChanged(false),
        isPropertyChanged(false),
        blend1(GL_SRC_ALPHA),
        blend2(GL_ONE_MINUS_SRC_ALPHA),
        type(SPRITE_TYPE_NORMAL),
        color({1,1,1,1}),
        blendColor({1,1,1,1}),
        isAlphaMap(0)
        {
        };
        inline void init(std::string textureName)
        {
            this->textureName = textureName;
            isTextureInitialized = false;
        }
        inline void setTextureRect(float x, float y, float w, float h)
        {
            textureRect.point.x = x;
            textureRect.point.y = y;
            textureRect.size.width = w;
            textureRect.size.height = h;
            isTextureRectChanged = true;
        }
        inline void setBlendFunc(int a, int b)
        {
            blend1 = a;
            blend2 = b;
            isPropertyChanged = true;
        }
        inline void setblendcolor(hgles::Color c)
        {
            blendColor = c;
            isPropertyChanged = true;
        }
        inline void setColor(hgles::Color c)
        {
            color = c;
            isPropertyChanged = true;
        }
        inline void setOpacity(float a)
        {
            color.a = a;
            isPropertyChanged = true;
        }
        inline float& getOpacity()
        {
            return color.a;
        }
        inline void setType(SpriteType t)
        {
            type = t;
        }
        inline void shouldRenderAsAlphaMap(bool p)
        {
            isAlphaMap = p?1:0;
            isPropertyChanged = true;
        }
        
    protected:
        inline void render()
        {
            if (!isTextureInitialized)
            {
                texture = *hgles::HGLTexture::createTextureWithAsset(textureName);
                isTextureInitialized = true;
            }
            if (isTextureRectChanged)
            {
                texture.setTextureArea(textureRect.point.x, textureRect.point.y, textureRect.size.width, textureRect.size.height);
                isTextureRectChanged = false;
            }
            if (isPropertyChanged)
            {
                isPropertyChanged = false;
                texture.setBlendFunc(blend1, blend2);
                texture.color = color;
                texture.blendColor = blendColor;
                texture.isAlphaMap = isAlphaMap;
            }
            switch (type)
            {
                case SPRITE_TYPE_BILLBOARD:
                    hgles::HGLGraphics2D::draw(&worldPosition, &worldScale, &WorldRotate,  &texture);
                    break;
                case SPRITE_TYPE_NORMAL:
                    hgles::HGLGraphics2D::drawLike3d(&worldPosition, &worldScale, &WorldRotate,  &texture);
                    break;
            }
        }
        
        
    private:
        SpriteType type;
        bool isPropertyChanged;
        bool isTextureRectChanged;
        bool isTextureInitialized;
        int blend1;
        int blend2;
        int isAlphaMap;
        HGRect textureRect;
        hgles::HGLTexture texture;
        std::string textureName;
        HGSize textureSize;
        hgles::Color color;
        hgles::Color blendColor;
    };
    
    ////////////////////
    // グローバルノード
    static HGDirector* directorPtr = NULL;
    class HGDirector : HGObject
    {
    public:
        HGDirector():
        pRootNode(NULL)
        {
            
        }
        static inline HGDirector* sharedDirector()
        {
            if (!directorPtr)
            {
                directorPtr = new (SYSTEM_HEAP_NAME)HGDirector();
                directorPtr->init();
            }
            return directorPtr;
        }
        inline void drawRootNode()
        {
            pRootNode->draw(rootPosition, rootScale, rootRotate);
        }
        inline HGNode* getRootNode()
        {
            return pRootNode;
        }
    private:
        inline void init()
        {
            if (pRootNode)
            {
                pRootNode->release();
                pRootNode = NULL;
            }
            pRootNode = new (SYSTEM_HEAP_NAME)HGNode();
            rootPosition = Vector(0,0,0);
            rootScale = Vector(1,1,1);
            rootRotate = Vector(0,0,0);
        }
        HGNode* pRootNode;
        Vector rootPosition;
        Vector rootScale;
        Vector rootRotate;
    };
    
    HGSprite* CreateAlphaMapSprite(std::string texture, Color color);
    
    // process
    class SpriteScaleProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        SpriteScaleProcess() :
        base(),
        pSpr(NULL)
        {
        };
        ~SpriteScaleProcess()
        {
            pSpr->release();
        }
        void init(HGProcessOwner* pProcOwner, HGSprite* pSpr, float toScaleX, float toScaleY, float frame)
        {
            assert(pSpr != NULL);
            base::init(pProcOwner);
            this->pSpr = pSpr;
            this->pSpr->retain();
            this->frame = frame;
            this->toScaleX = toScaleX;
            this->toScaleY = toScaleY;
        }
    protected:
        void onUpdate()
        {
            if (getFrameCount() == 0)
            {
                this->fromScaleX = pSpr->getScaleX();
                this->fromScaleY = pSpr->getScaleY();
                this->diffScaleX = (toScaleX - fromScaleX)/frame;
                this->diffScaleY = (toScaleY - fromScaleY)/frame;
            }
            if (frame <= getFrameCount())
            {
                pSpr->setScale(toScaleX, toScaleY);
                setEnd();
            }
            else
            {
                pSpr->setScale(pSpr->getScaleX() + diffScaleX, pSpr->getScaleY() + diffScaleY);
            }
        }
        std::string getName()
        {
            return "SpriteScaleProcess";
        }
    private:
        HGSprite* pSpr;
        float frame = 0;
        float toScaleX = 1;
        float toScaleY = 1;
        float fromScaleX = 0;
        float fromScaleY = 0;
        float diffScaleX = 0;
        float diffScaleY = 0;
    };
    
    // process
    class SpriteChangeOpacityProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        SpriteChangeOpacityProcess() :
        base(),
        pSpr(NULL)
        {
        };
        ~SpriteChangeOpacityProcess()
        {
            pSpr->release();
        }
        void init(HGProcessOwner* pProcOwner, HGSprite* pSpr, float toOpacity, float frame)
        {
            assert(pSpr != NULL);
            base::init(pProcOwner);
            this->pSpr = pSpr;
            this->pSpr->retain();
            this->frame = frame;
            this->toOpacity = toOpacity;
        }
    protected:
        void onUpdate()
        {
            if (getFrameCount() == 0)
            {
                this->fromOpacity = pSpr->getOpacity();
                this->diffOpacity = (toOpacity - fromOpacity)/frame;
            }
            if (frame <= getFrameCount())
            {
                pSpr->setOpacity(toOpacity);
                setEnd();
            }
            else
            {
                pSpr->setOpacity(pSpr->getOpacity() + diffOpacity);
            }
        }
        std::string getName()
        {
            return "SpriteChangeOpacityProcess";
        }
    private:
        HGSprite* pSpr;
        float frame = 0;
        float toOpacity = 1;
        float fromOpacity = 1;
        float diffOpacity = 1;
    };
    
    class NodeRemoveProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        NodeRemoveProcess() :
        base(),
        pSpr(NULL)
        {
        };
        ~NodeRemoveProcess()
        {
            pSpr->release();
        }
        void init(HGProcessOwner* pProcOwner, HGSprite* pSpr)
        {
            assert(pSpr != NULL);
            base::init(pProcOwner);
            this->pSpr = pSpr;
            this->pSpr->retain();
        }
    protected:
        void onUpdate()
        {
            pSpr->removeFromParent();
            this->setEnd();
        }
        std::string getName()
        {
            return "NodeRemoveProcess";
        }
    private:
        HGSprite* pSpr;
    };
    
    class WaitProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        WaitProcess() :
        base(),
        frame(0)
        {
        };
        ~WaitProcess()
        {
        }
        void init(HGProcessOwner* pProcOwner, float frame)
        {
            base::init(pProcOwner);
            this->frame = frame;
        }
    protected:
        void onUpdate()
        {
            if (this->getFrameCount() >= frame)
            {
                this->setEnd();
            }
        }
        std::string getName()
        {
            return "WaitProcess";
        }
    private:
        float frame;
    };
    
}
#endif
