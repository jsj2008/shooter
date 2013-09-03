#ifndef __HGAME_ENGINE_H__
#define __HGAME_ENGINE_H__

#import "HGLES.h"
#import "HGLGraphics2D.h"
#import "HGLObject3D.h"
#import "HGLObjLoader.h"

#import "HTypes.h"

#import <boost/shared_ptr.hpp>
#import <list>
#import <vector>
#import <map>
#include <sys/timeb.h>

#define GAMEFPS 27
#define HDebug(A, ...) NSLog(@"[Debug] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define HInfo(A, ...) NSLog(@"[Info] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define HError(A, ...) NSLog(@"[###ERROR###] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define IS_PROCESS_DEBUG 0
#define IS_DEBUG_MEMORY 0

namespace hg
{
    
    //const std::string SYSTEM_HEAP_NAME = "SYSTEM HEAP";
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
    
    // イージングの計算
    // t : 現在時間(フレーム数等)
    // b : 開始の値
    // c : 開始の値
    // d : 全体の時間
    float ease_linear(float t, float b, float c, float d);
    float ease_in(float t, float b, float c, float d);
    float ease_out(float t, float b, float c, float d);
    float ease_in_out(float t, float b, float c, float d);
    
    int f(int frame);
    float v(float vec);
    void initRandom();
    int rand(int from, int to);
    float toDeg(float radian);
    float toRad(float degree);
    void updateNowTime();
    double getNowTime();
    
    ////////////////////
    // 関数オブジェクト
    class Random
    {
    public:
        // 関数オブジェクト
        unsigned int operator()(unsigned int max)
        {
            return rand(0, max - 1);
        }
    };
    
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
    // AutoRelease
    namespace AutoRelease
    {
        class AutoReleaseObject
        {
        public:
            virtual void release() = 0;
        };
        
        typedef std::vector<AutoReleaseObject*> AutoReleaseList;
        extern AutoReleaseList autoReleaseList;
        inline void addObject(AutoReleaseObject* o)
        {
            autoReleaseList.push_back(o);
        }
        inline void releaseAll()
        {
            for (AutoReleaseList::iterator it = autoReleaseList.begin(); it != autoReleaseList.end(); ++it)
            {
                (*it)->release();
            }
            autoReleaseList.clear();
        }
    }
    
    ////////////////////
    // 基底
    class HGObject : hg::AutoRelease::AutoReleaseObject
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
            //assert(refCount > 0);
            refCount--;
            if (refCount== 0)
            {
                this->~HGObject();
            }
            s_pHeap->release(this);
            //assert(refCount >= 0);
        }
        inline int getRefCount()
        {
            return refCount;
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
        HGState():
            frameCount(0),
            isInitialUpdate(true)
        {
            frameCount = 0;
            isInitialUpdate = true;
        };
        virtual void onUpdate(){}
        virtual std::string getName();
        virtual void onSuspend(){}
        virtual void onResume(){}
        void update();
        void suspend();
        void resume();
        virtual ~HGState(){}
        inline int getFrameCount()
        {
            return frameCount;
        }
    private:
        int frameCount;
        bool isInitialUpdate;
    };

    class HGStateManager
    {
    public:
        typedef std::stack<HGState*> stateStack;
        stateStack stack;
        stateStack endStack;
        static HGStateManager* sharedStateManger();
        void clear();
        void update();
        void pop();
        void push(HGState* state);
        ~HGStateManager(){assert(false);}
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
        _isIntercepted(false),
        _isInitialUpdate(true),
        _isInitialized(false),
        waitFrame(0)
        {
        };
        inline virtual void init(HGProcessOwner* pOwner)
        {
            this->pOwner = pOwner;
            pOwner->retain();
            _isInitialized = true;
        }
        void setNext(HGProcess* nextPtr);
        inline void setWaitFrame(int frame)
        {
            this->waitFrame = frame;
        }
    protected:
        virtual void onEnd(){}
        virtual void onUpdate(){}
        virtual void onIntercept(){}
        virtual std::string getName();
        inline bool isWait()
        {
            if (this->waitFrame > 0)
            {
                this->waitFrame--;
                return true;
            }
            return false;
        }
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
        bool _isInitialUpdate;
        bool _isEnd;
        bool _isIntercepted;
        bool _isInitialized;
        HGProcessOwner* pOwner;
        HGProcess* pNextProcess;
        int waitFrame;
        inline void removeNextProcess()
        {
            pNextProcess->release();
            pNextProcess = NULL;
        }
        inline HGProcess* getNextProcess()
        {
            return pNextProcess;
        }
        inline HGProcessOwner* getOwner()
        {
            return pOwner;
        }
        inline bool isIntercepted()
        {
            return _isIntercepted;
        }
        inline void setIntercepted()
        {
            this->_isIntercepted = true;
        }
        inline void update()
        {
            assert(_isInitialized);
            assert(!this->_isEnd);
            assert(this->getRefCount() > 0);
            this->onUpdate();
            frameCount++;
            _isInitialUpdate = false;
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
    class HGProcessManager
    {
    public:
        static inline HGProcessManager* sharedProcessManager()
        {
            static HGProcessManager* hgProcessManagerPtr = NULL;
            if (!hgProcessManagerPtr)
            {
                hgProcessManagerPtr = new HGProcessManager();
                hgProcessManagerPtr->init();
            }
            return hgProcessManagerPtr;
        }
        HGProcessManager(){}
        void clear();
        void addProcess(HGProcess* pProcess);
        void addAndExecProcess(HGProcess* pProcess);
        void update();
        
    private:
        void exec(HGProcess* proc);
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
                (*itr)->setParent(NULL);
                (*itr)->release();
            }
            children.clear();
        }
        
        inline void removeChild(HGNode* node)
        {
            node->setParent(NULL);
            children.remove(node);
            node->removedFromParent(this);
            node->release();
        }
        
        inline void removeFromParent()
        {
            if (parent)
            {
                parent->removeChild(this);
            }
        }
        
        inline void addChild(HGNode* node)
        {
            assert(node != this);
            if (node->parent != NULL)
            {
                node->removeFromParent();
            }
            node->retain();
            children.push_back(node);
            node->setParent(this);
            node->addedToParent(this);
        }
        
        virtual inline void addedToParent(HGNode* parent)
        {
            
        }
        
        virtual inline void removedFromParent(HGNode* parent)
        {
            
        }
        
        inline void setParent(HGNode* node)
        {
            parent = node;
        }
        inline bool hasParent()
        {
            return (parent != NULL);
        }
        inline void setScale(float scaleX, float scaleY)
        {
            this->scale.x = scaleX;
            this->scale.y = scaleY;
        }
        
        inline void setScaleX(float scaleX)
        {
            this->scale.x = scaleX;
        }
        
        inline void setScaleY(float scaleY)
        {
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
        inline float getRotateX()
        {
            return this->rotate.x;
        }
        inline float getRotateY()
        {
            return this->rotate.y;
        }
        inline float getRotateZ()
        {
            return this->rotate.z;
        }
        
        inline void draw(Vector& parentPosition, Vector& parentScale, Vector& parentRotate)
        {
            assert(this->getRefCount() > 0);
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
        
        inline void setRotateY(float radian)
        {
            this->rotate.y = radian;
        }
        
        inline void setRotateX(float radian)
        {
            this->rotate.x = radian;
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
    
    class LayerNode : public HGNode
    {
    public:
        LayerNode():
        _cameraPosition(0,0,0),
        _cameraRotate(0,0,0)
        {
            
        }
        void init()
        {
            
        }
        void setCameraPosition(float x, float y, float z)
        {
            _cameraPosition.x = x;
            _cameraPosition.y = y;
            _cameraPosition.z = z;
        }
        void setCameraRotate(float x, float y, float z)
        {
            _cameraRotate.x = x;
            _cameraRotate.y = y;
            _cameraRotate.z = z;
        }
    protected:
        inline void render()
        {
            hgles::cameraPosition = _cameraPosition;
            hgles::cameraRotate = _cameraRotate;
            hgles::HGLES::updateCameraMatrix();
        }
    private:
        Vector _cameraPosition;
        Vector _cameraRotate;
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
        inline virtual void init(std::string textureName)
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
        inline Color getColor()
        {
            return this->color;
        }
    protected:
        inline void render()
        {
#if IS_GAME_GL
            assert(this->getRefCount() > 0);
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
            if (isAlphaMap) {
                if (hgles::ProgramType2DAlpha != hgles::getCurrentProgramType())
                {
                    hgles::setCurrentContext(hgles::ProgramType2DAlpha);
                }
            } else {
                if (hgles::ProgramType2D != hgles::getCurrentProgramType())
                {
                    hgles::setCurrentContext(hgles::ProgramType2D);
                }
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
#endif
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
    
    class AlphaMapSprite : public HGSprite
    {
        typedef HGSprite base;
    public:
        AlphaMapSprite():
        base()
        {}
        
        inline void init(std::string textureName, Color c)
        {
            setType(SPRITE_TYPE_BILLBOARD);
            base::init(textureName);
            this->setColor(c);
            this->shouldRenderAsAlphaMap(true);
            this->setBlendFunc(GL_SRC_ALPHA, GL_ONE);
        }
        
    };
    
    class ColorNode : public HGSprite
    {
        typedef HGSprite base;
    public:
        ColorNode():
        base()
        {}
        
        inline void init(Color color, float scaleWidth, float scaleHeight)
        {
            base::init("square.png");
            this->setblendcolor(color);
            this->setScale(scaleWidth, scaleHeight);
        }
    };
    
    
    class AlphaColorNode : public HGSprite
    {
        typedef HGSprite base;
    public:
        AlphaColorNode():
        base()
        {}
        
        inline void init(Color color, float scaleWidth, float scaleHeight)
        {
            base::init("square.png");
            this->setColor(color);
            this->shouldRenderAsAlphaMap(true);
            this->setBlendFunc(GL_SRC_ALPHA, GL_ONE);
            this->setScale(scaleWidth, scaleHeight);
        }
        
    };
    
    ////////////////////
    // 3Dモデル
    
    class HG3DModel: public HGNode
    {
    public:
        HG3DModel():
        HGNode()
        {
        };
        inline virtual void init(std::string modelName)
        {
            this->modelName = modelName;
            // planet
            obj = hgles::HGLObjLoader::load([NSString stringWithCString:modelName.c_str() encoding:NSUTF8StringEncoding]);
            obj->useLight = 1.0;
        }
        ~HG3DModel()
        {
            delete obj;
        }
        inline void setScale(float x, float y, float z)
        {
            obj->scale.set(x, y, z);
        }
        inline void setRotate(float x, float y, float z)
        {
            obj->rotate.set(x, y, z);
        }
        inline void setRotateX(float x)
        {
            obj->rotate.x = x;
        }
        inline void setRotateY(float y)
        {
            obj->rotate.y = y;
        }
        inline void setRotateZ(float z)
        {
            obj->rotate.z = z;
        }
        inline float getRotateX()
        {
            return obj->rotate.x;
        }
        inline float getRotateY()
        {
            return obj->rotate.y;
        }
        inline float getRotateZ()
        {
            return obj->rotate.z;
        }
        inline void setPosition(float x, float y, float z)
        {
            obj->position.set(x, y, z);
        }
    protected:
        inline void render()
        {
            glEnable(GL_DEPTH_TEST);
            glUniform1f(hgles::currentContext->uUseLight, 1.0);
            obj->draw();
            glDisable(GL_DEPTH_TEST);
        }
    private:
        hgles::HGLObject3D* obj = NULL;
        std::string modelName;
    };
    
    
    ////////////////////
    // グローバルノード
    class HGDirector
    {
    public:
        HGDirector():
        pRootNode(NULL)
        {
            
        }
        ~HGDirector()
        {
            assert(false);
        }
        static inline HGDirector* sharedDirector()
        {
            static HGDirector* directorPtr = NULL;
            if (!directorPtr)
            {
                directorPtr = new HGDirector();
                directorPtr->init();
            }
            return directorPtr;
        }
        inline void drawRootNode()
        {
            pRootNode->draw(rootPosition, rootScale, rootRotate);
            // autoRelease
            AutoRelease::releaseAll();
        }
        inline HGNode* getRootNode()
        {
            return pRootNode;
        }
        inline void init()
        {
            pRootNode = new HGNode();
            pRootNode->retain();
            rootPosition = Vector(0,0,0);
            rootScale = Vector(1,1,1);
            rootRotate = Vector(0,0,0);
        }
    private:
        HGNode* pRootNode;
        Vector rootPosition;
        Vector rootScale;
        Vector rootRotate;
    };
    
    // process
    class ChangeScaleProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        ChangeScaleProcess() :
        base(),
        pSpr(NULL)
        {
        };
        ~ChangeScaleProcess()
        {
            pSpr->release();
        }
        void setEaseFunc(float (*pEaseFunc)(float t, float b, float c, float d))
        {
            this->pEaseFunc = pEaseFunc;
        }
        void init(HGProcessOwner* pProcOwner, HGNode* pSpr, float toScaleX, float toScaleY, float frame)
        {
            assert(pSpr != NULL);
            base::init(pProcOwner);
            this->pSpr = pSpr;
            this->pSpr->retain();
            this->frame = frame;
            this->toScaleX = toScaleX;
            this->toScaleY = toScaleY;
            pEaseFunc = &ease_linear;
        }
    protected:
        void onUpdate()
        {
            if (getFrameCount() == 0)
            {
                this->fromScaleX = pSpr->getScaleX();
                this->fromScaleY = pSpr->getScaleY();
            }
            if (frame <= getFrameCount())
            {
                pSpr->setScale(toScaleX, toScaleY);
                setEnd();
            }
            else
            {
                float x = pEaseFunc(getFrameCount(), fromScaleX, toScaleX, frame);
                float y = pEaseFunc(getFrameCount(), fromScaleY, toScaleY, frame);
                pSpr->setScale(x, y);
            }
        }
        std::string getName()
        {
            return "ChangeScaleProcess";
        }
    private:
        HGNode* pSpr;
        float frame = 0;
        float toScaleX = 1;
        float toScaleY = 1;
        float fromScaleX = 0;
        float fromScaleY = 0;
        float (*pEaseFunc)(float t, float b, float c, float d);
    };
    
    // process
    class RotateNodeProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        RotateNodeProcess() :
        base(),
        pSpr(NULL)
        {
        };
        ~RotateNodeProcess()
        {
            pSpr->release();
        }
        void setEaseFunc(float (*pEaseFunc)(float t, float b, float c, float d))
        {
            this->pEaseFunc = pEaseFunc;
        }
        void init(HGProcessOwner* pProcOwner, HGNode* pSpr, Vector toRatate, float frame)
        {
            assert(pSpr != NULL);
            base::init(pProcOwner);
            pEaseFunc = &ease_linear;
            this->pSpr = pSpr;
            this->pSpr->retain();
            this->frame = frame;
            this->toRotate = toRotate;
            this->fromRotate.x = pSpr->getRotateX();
            this->fromRotate.y = pSpr->getRotateY();
            this->fromRotate.z = pSpr->getRotateZ();
        }
    protected:
        void onUpdate()
        {
            if (frame <= getFrameCount())
            {
                pSpr->setRotate(toRotate.x, toRotate.y, toRotate.z);
                setEnd();
            }
            else
            {
                float x = pEaseFunc(getFrameCount(), fromRotate.x, toRotate.x, frame);
                float y = pEaseFunc(getFrameCount(), fromRotate.y, toRotate.y, frame);
                float z = pEaseFunc(getFrameCount(), fromRotate.z, toRotate.z, frame);
                pSpr->setRotate(x, y, z);
            }
        }
        std::string getName()
        {
            return "RotateNodeProcess";
        }
    private:
        HGNode* pSpr;
        float frame = 0;
        Vector toRotate;
        Vector fromRotate;
        float (*pEaseFunc)(float t, float b, float c, float d);
    };
    
    // process
    class ChangeSpriteColorProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        ChangeSpriteColorProcess() :
        base(),
        pSpr(NULL)
        {
        };
        ~ChangeSpriteColorProcess()
        {
            pSpr->release();
        }
        void setEaseFunc(float (*pEaseFunc)(float t, float b, float c, float d))
        {
            this->pEaseFunc = pEaseFunc;
        }
        void init(HGProcessOwner* pProcOwner, HGSprite* pSpr, Color toColor, float frame)
        {
            assert(pSpr != NULL);
            base::init(pProcOwner);
            pEaseFunc = &ease_linear;
            this->pSpr = pSpr;
            this->pSpr->retain();
            this->frame = frame;
            this->toColor = toColor;
            this->fromColor = pSpr->getColor();
        }
    protected:
        void onUpdate()
        {
            if (!pSpr->hasParent())
            {
                setEnd();
                return;
            }
            Color fc;
            Color tc;
            if (flag == 0)
            {
                fc = fromColor;
                tc = toColor;
            }
            else
            {
                tc = fromColor;
                fc = toColor;
            }
            if (frame <= frameCount)
            {
                pSpr->setColor(tc);
                flag = flag == 1?0:1;
                frameCount = 0;
            }
            else
            {
                float r = pEaseFunc(frameCount, fc.r, tc.r, frame);
                float g = pEaseFunc(frameCount, fc.g, tc.g, frame);
                float b = pEaseFunc(frameCount, fc.b, tc.b, frame);
                float a = pEaseFunc(frameCount, fc.a, tc.a, frame);
                pSpr->setColor((Color){r, g, b, a});
            }
            frameCount++;
        }
        std::string getName()
        {
            return "RotateNodeProcess";
        }
    private:
        HGSprite* pSpr;
        float frame = 0;
        int frameCount = 0;
        Color toColor;
        Color fromColor;
        float (*pEaseFunc)(float t, float b, float c, float d);
        int flag = 0;
    };
    
    
    // process
    class ChangeSpriteBlendColorProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        ChangeSpriteBlendColorProcess() :
        base(),
        pSpr(NULL)
        {
        };
        ~ChangeSpriteBlendColorProcess()
        {
            pSpr->release();
        }
        void setEaseFunc(float (*pEaseFunc)(float t, float b, float c, float d))
        {
            this->pEaseFunc = pEaseFunc;
        }
        void init(HGProcessOwner* pProcOwner, HGSprite* pSpr, Color toColor, float frame)
        {
            assert(pSpr != NULL);
            base::init(pProcOwner);
            pEaseFunc = &ease_linear;
            this->pSpr = pSpr;
            this->pSpr->retain();
            this->frame = frame;
            this->toColor = toColor;
            this->fromColor = pSpr->getColor();
        }
    protected:
        void onUpdate()
        {
            if (!pSpr->hasParent())
            {
                setEnd();
                return;
            }
            Color fc;
            Color tc;
            if (flag == 0)
            {
                fc = fromColor;
                tc = toColor;
            }
            else
            {
                tc = fromColor;
                fc = toColor;
            }
            if (frame <= frameCount)
            {
                pSpr->setblendcolor(tc);
                flag = flag == 1?0:1;
                frameCount = 0;
            }
            else
            {
                float r = pEaseFunc(frameCount, fc.r, tc.r, frame);
                float g = pEaseFunc(frameCount, fc.g, tc.g, frame);
                float b = pEaseFunc(frameCount, fc.b, tc.b, frame);
                float a = pEaseFunc(frameCount, fc.a, tc.a, frame);
                pSpr->setblendcolor((Color){r, g, b, a});
            }
            frameCount++;
        }
        std::string getName()
        {
            return "RotateNodeProcess";
        }
    private:
        HGSprite* pSpr;
        float frame = 0;
        int frameCount = 0;
        Color toColor;
        Color fromColor;
        float (*pEaseFunc)(float t, float b, float c, float d);
        int flag = 0;
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
        void setEaseFunc(float (*pEaseFunc)(float t, float b, float c, float d))
        {
            this->pEaseFunc = pEaseFunc;
        }
        void init(HGProcessOwner* pProcOwner, HGSprite* pSpr, float toOpacity, float frame)
        {
            assert(pSpr != NULL);
            base::init(pProcOwner);
            pEaseFunc = &ease_linear;
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
            }
            if (frame <= getFrameCount())
            {
                pSpr->setOpacity(toOpacity);
                setEnd();
            }
            else
            {
                float o = pEaseFunc(getFrameCount(), fromOpacity, toOpacity, frame);
                pSpr->setOpacity(o);
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
        float (*pEaseFunc)(float t, float b, float c, float d);
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
    
    class HGText: public HGNode
    {
        typedef HGNode base;
    public:
        HGText():
        HGNode(),
        textureSize(0,0),
        isTextureInitialized(false),
        text(""),
        textureRect(0,0,0,0),
        isTextureRectChanged(false),
        isPropertyChanged(false),
        blend1(GL_SRC_ALPHA),
        blend2(GL_ONE_MINUS_SRC_ALPHA),
        type(SPRITE_TYPE_BILLBOARD),
        color({1,1,1,1}),
        blendColor({1,1,1,1}),
        isAlphaMap(0),
        anchorPoint(0,0)
        {
        };
        inline ~HGText()
        {
            texture->deleteTexture();
            delete texture;
        }
        inline virtual void initWithString(std::string text)
        {
            this->text = text;
            isTextureInitialized = false;
        }
        inline virtual void initWithString(std::string text, Color fontColor)
        {
            this->fontColor = fontColor;
            this->initWithString(text);
        }
        inline void setTextureRect(float x, float y, float w, float h)
        {
            textureRect.point.x = x;
            textureRect.point.y = y;
            textureRect.size.width = w;
            textureRect.size.height = h;
            isTextureRectChanged = true;
        }
        inline void setScaleByTextSize(float scale)
        {
            this->scale = scale;
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
        inline Color getColor()
        {
            return this->color;
        }
        inline void setAnchor(float x, float y)
        {
            anchorPoint.x = x;
            anchorPoint.y = y;
        }
    protected:
        inline void render()
        {
            assert(this->getRefCount() > 0);
            if (!isTextureInitialized)
            {
                texture = hgles::HGLTexture::createTextureWithString(this->text, fontColor);
                isTextureInitialized = true;
                float w = texture->width;
                float h = texture->height;
                float scaleX = w*scale/h;
                this->setScale(scaleX, scale);
                return;
            }
            worldPosition.x += (worldScale.x)/2 - (worldScale.x) * anchorPoint.x;
            worldPosition.y += (worldScale.y)/2 - (worldScale.y) * anchorPoint.y;
            if (isTextureRectChanged)
            {
                texture->setTextureArea(textureRect.point.x, textureRect.point.y, textureRect.size.width, textureRect.size.height);
                isTextureRectChanged = false;
            }
            if (isPropertyChanged)
            {
                isPropertyChanged = false;
                texture->setBlendFunc(blend1, blend2);
                texture->color = color;
                texture->blendColor = blendColor;
                texture->isAlphaMap = isAlphaMap;
            }
            switch (type)
            {
                case SPRITE_TYPE_BILLBOARD:
                    hgles::HGLGraphics2D::draw(&worldPosition, &worldScale, &WorldRotate,  texture);
                    break;
                case SPRITE_TYPE_NORMAL:
                    hgles::HGLGraphics2D::drawLike3d(&worldPosition, &worldScale, &WorldRotate,  texture);
                    break;
            }
        }
        
        
    private:
        SpriteType type;
        bool isPropertyChanged;
        bool isTextureRectChanged;
        bool isTextureInitialized;
        HGPoint anchorPoint;
        int blend1;
        int blend2;
        int isAlphaMap;
        HGRect textureRect;
        hgles::HGLTexture* texture;
        std::string text;
        HGSize textureSize;
        hgles::Color color;
        hgles::Color blendColor;
        float scale = 0;
        Color fontColor = {1,1,1,1};
    };
    
    
}
#endif
