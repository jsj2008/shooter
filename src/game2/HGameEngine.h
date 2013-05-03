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
#define IS_PROCESS_DEBUG 1

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
        std::string getName()
        {
            return name;
        }
        void* alloc(size_t size)
        {
            size_t iRequestedBytes = size + sizeof(AllocHeader)
                + sizeof(int); // End Marker分
            char *pMem = (char*)malloc(iRequestedBytes);
            AllocHeader *pHeader = (AllocHeader*)pMem;
            pHeader->pHeap = this;
            pHeader->iSize = size;
            pHeader->iSignature = SIGNATURE;
            pHeader->pNext = NULL;
            pHeader->pPrev = NULL;
            pHeader->referenceCount = 1;
            if (!pFirst)
            {
                pFirst = pHeader;
                pLast = pHeader;
            }
            else
            {
                pLast->pNext = pHeader;
                pHeader->pPrev = pLast;
            }
            this->addAllocation(size);
            char* pStartMemBlock = pMem + sizeof(AllocHeader);
            int *pEndMarker = (int*)(pStartMemBlock + size);
            *pEndMarker = ENDMARKER;
            return pStartMemBlock;
        }
        void deleteAllocation(void *pMem)
        {
            AllocHeader *pHeader = (AllocHeader *)((char *)pMem - sizeof(AllocHeader));
            assert(pHeader->iSignature == SIGNATURE);
            pHeader->pHeap->removeAllocation(pHeader->iSize);
            if (pHeader->pPrev)
            {
                pHeader->pPrev->pNext = pHeader->pNext;
            }
            if (pHeader->pNext)
            {
                pHeader->pNext->pPrev = pHeader->pPrev;
            }
            if (pFirst == pHeader)
            {
                pFirst = pHeader->pNext;
            }
            if (pLast == pHeader)
            {
                pLast = pHeader->pPrev;
            }
            int *pEndmarker = (int *)((char*)pMem + pHeader->iSize);
            assert(*pEndmarker == ENDMARKER);
            free(pHeader);
        }
        void freeAll()
        {
            pFirst = NULL;
            pLast = NULL;
            allocatedSize = 0;
        }
        void retain(void *pMem)
        {
            AllocHeader *pHeader = (AllocHeader *)((char *)pMem - sizeof(AllocHeader));
            assert(pHeader->iSignature == SIGNATURE);
            assert(pHeader->referenceCount >= 0);
            pHeader->referenceCount++;
        }
        void release(void *pMem)
        {
            AllocHeader *pHeader = (AllocHeader *)((char *)pMem - sizeof(AllocHeader));
            assert(pHeader->iSignature == SIGNATURE);
            assert(pHeader->referenceCount > 0);
            pHeader->referenceCount--;
            if (pHeader->referenceCount == 0)
            {
                deleteAllocation(pMem);
            }
        }
    private:
        HGHeap(std::string name):
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
        void addAllocation(size_t size)
        {
            allocatedSize += size;
        }
        void removeAllocation(size_t size)
        {
            allocatedSize -= size;
        }
        friend class HGHeapFactory;
    };
    class HGHeapFactory
    {
    public:
        static HGHeap* CreateHeap(std::string name)
        {
            if (heapList.find(name) != heapList.end())
            {
                return heapList[name];
            }
            HGHeap* pHeap = new HGHeap(name);
            heapList[name] = pHeap;
            return pHeap;
        }
    private:
        static std::map<std::string,HGHeap*> heapList;
    };
    
    ////////////////////
    // 基底
    class HGObject
    {
    public:
        HGObject()
        {};
        virtual ~HGObject(void){};
        static void* operator new(size_t size);
        static void* operator new(size_t size, std::string heapName);
        static void operator delete(void *p, size_t size);
        void retain()
        {
            s_pHeap->retain(this);
        }
        void release()
        {
            s_pHeap->release(this);
        }
    private:
        static HGHeap* s_pHeap;
    };
    
    ////////////////////
    // ステート管理
    class HGState : public HGObject
    {
    public:
        HGState()
        {
            isInitialUpdate = true;
        }
        
        virtual void onUpdate(){}
        virtual std::string getName()
        {
            return "BaseState";
        }
        virtual void onSuspend(){}
        virtual void onResume(){}
        void update()
        {
            this->onUpdate();
            frameCount++;
            isInitialUpdate = false;
        }
        void suspend()
        {
            this->onSuspend();
        }
        void resume()
        {
            this->onResume();
        }
        virtual ~HGState(){}
    private:
        int frameCount;
        bool isInitialUpdate;
    };

    static HGStateManager* pStateManager = NULL;
    class HGStateManager : public HGObject
    {
    public:
        typedef std::stack<HGState*> stateStack;
        stateStack stack;
        static HGStateManager* sharedStateManger()
        {
            if (!pStateManager)
            {
                pStateManager = new (SYSTEM_HEAP_NAME)HGStateManager();
            }
            return pStateManager;
        }
        
        void clear()
        {
            while(stack.size())
            {
                stack.top()->release();
                stack.pop();
            }
        }
        
        void update()
        {
            updateNowTime();
            if (!stack.empty())
            {
                HGState* state = stack.top();
                state->update();
            }
        }
        void pop()
        {
            assert(!stack.empty());
            HGState* state = stack.top();
            HInfo(@"STATE POP : %s", state->getName().c_str());
            stack.pop();
            if (stack.size() > 0)
            {
                stack.top()->resume();
            }
            state->release();
        }
        void push(HGState* state)
        {
            state->retain();
            if (stack.size() > 0)
            {
                stack.top()->suspend();
            }
            stack.push(state);
            HInfo(@"STATE PUSH : %s", state->getName().c_str());
        }
        ~HGStateManager(){}
    private:
        HGStateManager(){};
    };
    
    ////////////////////
    // プロセス管理
    
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
        virtual ~HGProcess()
        {
            if (this->pNextProcess)
            {
                pNextProcess->release();
            }
        };
        void init(HGProcessOwner* pOwner)
        {
            this->pOwner = pOwner;
            isInitialized = true;
        }
        void setNext(HGProcess* nextPtr)
        {
            assert(nextPtr);
            nextPtr->retain();
            pNextProcess = nextPtr;
        }
    protected:
        int frameCount;
        bool isInitialUpdate;
        virtual void onEnd(){}
        virtual void onUpdate(){}
        virtual void onIntercept(){}
        virtual std::string getName()
        {
            return "BaseProcess";
        }
    private:
        bool _isEnd;
        bool isIntercepted;
        bool isInitialized;
        HGProcessOwner* pOwner;
        HGProcess* pNextProcess;
        inline HGProcessOwner* getOwner()
        {
            return pOwner;
        }
        inline bool isEnd()
        {
            return _isEnd;
        }
        inline void setEnd()
        {
            this->_isEnd = true;
        }
        inline void setIntercepted()
        {
            this->isIntercepted = true;
        }
        inline void update()
        {
            assert(isInitialized);
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
    
    // プロセスオーナークラス
    class HGProcessOwner : public HGObject
    {
    public:
        HGProcessOwner():
        pProcess(NULL)
        {}
        void setProcess(HGProcess* pProcess)
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
        void clear()
        {
#if IS_PROCESS_DEBUG
            HDebug(@"Process Clear");
#endif
            for (ProcessList::iterator it = processList.begin(); it != processList.end(); ++it)
            {
                (*it)->release();
            }
            processList.clear();
        }
        void addPrcoess(HGProcess* pProcess)
        {
#if IS_PROCESS_DEBUG
            HDebug(@"Add Process : %s", pProcess->getName().c_str());
#endif
            pProcess->retain();
            HGProcessOwner* pOwner = pProcess->getOwner();
            if (pOwner->getProcess())
            {
#if IS_PROCESS_DEBUG
                HDebug(@"Process Intercepted : %s", pOwner->getProcess()->getName().c_str());
#endif
                HGProcess* p = pOwner->getProcess();
                p->intercept();
                p->setIntercepted();
                p->setEnd();
            }
            pOwner->setProcess(pProcess);
            addProcessList.push_back(pProcess);
        }
        void update()
        {
            for (ProcessList::iterator it = addProcessList.begin(); it != addProcessList.end(); ++it)
            {
                processList.push_back(*it);
            }
            addProcessList.clear();
            for (ProcessList::iterator it = processList.begin(); it != processList.end(); ++it)
            {
                HGProcess* tmp = *it;
                if (tmp->isIntercepted)
                {
                    // 中断された場合、nextも中断
                    delProcessList.push_back(tmp);
                    continue;
                }
                tmp->update();
                if (tmp->isEnd())
                {
#if IS_PROCESS_DEBUG
                    HDebug(@"Process Ended: %s", tmp->getName().c_str());
#endif
                    tmp->end();
                    delProcessList.push_back(tmp);
                    if (tmp->pNextProcess)
                    {
#if IS_PROCESS_DEBUG
                        HDebug(@"Next Process Found : %s", tmp->pNextProcess->getName().c_str());
#endif
                        this->addPrcoess(tmp->pNextProcess);
                        tmp->pNextProcess = NULL;
                    }
                }
            }
            for (ProcessList::iterator it = delProcessList.begin(); it != delProcessList.end(); ++it)
            {
                processList.remove(*it);
            }
            delProcessList.clear();
        }
    private:
        ProcessList processList;
        ProcessList addProcessList;
        ProcessList delProcessList;
        void init()
        {
        }
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
        virtual ~HGNode(){}
        
        void removeAllChildren()
        {
            for (Children::iterator itr = children.begin(); itr != children.end(); itr++)
            {
                (*itr)->release();
            }
            children.clear();
        }
        
        void removeChild(HGNode* node)
        {
            children.remove(node);
            node->release();
        }
        
        void addChild(HGNode* node)
        {
            assert(node != this);
            assert(node->parent == NULL);
            node->retain();
            children.push_back(node);
            node->setParent(this);
        }
        
        void setParent(HGNode* node)
        {
            if (parent != NULL)
            {
                parent->release();
            }
            node->retain();
            parent = node;
        }
        
        void setScale(float scaleX, float scaleY)
        {
            this->scale.x = scaleX;
            this->scale.y = scaleY;
        }
        
        void setScale(float scaleX, float scaleY, float scaleZ)
        {
            this->scale.x = scaleX;
            this->scale.y = scaleY;
            this->scale.z = scaleZ;
        }
        
        void setRotate(float x, float y, float z)
        {
            this->rotate.set(x, y, z);
        }
        
        void draw(Vector& parentPosition, Vector& parentScale, Vector& parentRotate)
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
        
        void addPosition(float x, float y)
        {
            position.x += x;
            position.y += y;
        }
        void setPosition(float x, float y)
        {
            position.x = x;
            position.y = y;
        }
        void setPositionX(float x)
        {
            position.x = x;
        }
        void setPositionY(float y)
        {
            position.y = y;
        }
        void setPosition(float x, float y, float z)
        {
            position.x = x;
            position.y = y;
            position.z = z;
        }
        
        float getPositionX()
        {
            return position.x;
        }
        
        float getPositionY()
        {
            return position.y;
        }
        
        void setRotateZWithRadian(float radian)
        {
            this->rotate.z = radian;
        }
    protected:
        virtual void render(){};
        
        hgles::HGLVector3 position;
        hgles::HGLVector3 scale;
        hgles::HGLVector3 rotate;
        
        hgles::HGLVector3 worldPosition;
        hgles::HGLVector3 worldScale;
        hgles::HGLVector3 WorldRotate;
        
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
        void init(std::string textureName)
        {
            this->textureName = textureName;
            isTextureInitialized = false;
        }
        void setTextureRect(float x, float y, float w, float h)
        {
            textureRect.point.x = x;
            textureRect.point.y = y;
            textureRect.size.width = w;
            textureRect.size.height = h;
            isTextureRectChanged = true;
        }
        void setBlendFunc(int a, int b)
        {
            blend1 = a;
            blend2 = b;
            isPropertyChanged = true;
        }
        void setblendcolor(hgles::Color c)
        {
            blendColor = c;
            isPropertyChanged = true;
        }
        void setColor(hgles::Color c)
        {
            color = c;
            isPropertyChanged = true;
        }
        void setType(SpriteType t)
        {
            type = t;
        }
        void shouldRenderAsAlphaMap(bool p)
        {
            isAlphaMap = p?1:0;
            isPropertyChanged = true;
        }
        
    protected:
        void render()
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
        static inline HGDirector* sharedDirector()
        {
            if (!directorPtr)
            {
                directorPtr = new (SYSTEM_HEAP_NAME)HGDirector();
                directorPtr->init();
            }
            return directorPtr;
        }
        void drawRootNode()
        {
            pRootNode->draw(rootPosition, rootScale, rootRotate);
        }
        HGNode* getRootNode()
        {
            return pRootNode;
        }
    private:
        void init()
        {
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

}
#endif
