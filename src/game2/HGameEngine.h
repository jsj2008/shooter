#ifndef __HGAME_ENGINE_H__
#define __HGAME_ENGINE_H__

#import "HGLES.h"
#import "HGLGraphics2D.h"
#import <boost/shared_ptr.hpp>
#import <list>
#include <sys/timeb.h>

#define GAMEFPS 30
#define HDebug(A, ...) NSLog(@"[Debug] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define HInfo(A, ...) NSLog(@"[Info] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define HError(A, ...) NSLog(@"[###ERROR###] Func:%s\tLine:%d\t%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define IS_PROCESS_DEBUG 1

namespace hg
{
    
    class HGNode;
    class HGSprite;
    class HGBillboardSprite;
    class HGState;
    class HGDirector;
    class HGStateManager;
    class HGProcessManager;
    class HGProcess;
    class HGProcessOwner;
    
    ////////////////////
    //  typedef
    typedef hgles::HGLVector3 Vector;
    typedef boost::shared_ptr<HGNode> NodePtr;
    typedef boost::shared_ptr<HGSprite> SpritePtr;
    typedef boost::shared_ptr<HGState> StatePtr;
    typedef boost::shared_ptr<HGProcess> ProcessPtr;
    typedef boost::shared_ptr<HGProcessOwner> ProcessOwnerPtr;
    
    typedef struct t_rect
    {
        float x, y, w, h;
    } t_rect;
    
    typedef struct t_size2d
    {
        float w, h;
    } t_size2d;
    
    typedef struct t_pos2d
    {
        float x, y;
    } t_pos2d;
    
    typedef struct HGPoint
    {
        HGPoint(float ix, float iy):x(ix), y(iy){}
        float x, y;
    } HGPoint;
    
    typedef struct HGSize
    {
        HGSize(float w, float h):width(w), height(h){}
        float width, height;
        
    } HGSize;
    
    typedef struct HGRect
    {
        HGRect(float x, float y, float width, float height):point(0,0), size(0,0)
        {
            point = HGPoint(x, y);
            size = HGSize(width, height);
        }
        HGPoint point;
        HGSize size;
    } HGRect;
    
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
    // 基底
    class HGObject
    {
    public:
        HGObject(){};
        virtual ~HGObject(void){};
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

    static HGStateManager* stateManagerPtr = NULL;
    class HGStateManager : public HGObject
    {
    public:
        typedef std::stack<StatePtr> stateStack;
        stateStack stack;
        static HGStateManager* sharedStateManger()
        {
            if (!stateManagerPtr)
            {
                stateManagerPtr = new HGStateManager();
            }
            return stateManagerPtr;
        }
        
        void clear()
        {
            while(stack.size())
            {
                stack.pop();
            }
        }
        
        void update()
        {
            updateNowTime();
            if (!stack.empty())
            {
                StatePtr state = stack.top();
                state->update();
            }
        }
        void pop()
        {
            assert(!stack.empty());
            StatePtr state = stack.top();
            HInfo(@"STATE POP : %s", state->getName().c_str());
            stack.pop();
            if (stack.size() > 0)
            {
                stack.top()->resume();
            }
        }
        void push(StatePtr state)
        {
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
    class HGProcess
    {
    public:
        HGProcess(ProcessOwnerPtr processOwnerPtr):
        ownerPtr(NULL),
        nextProcessPtr(NULL),
        frameCount(0),
        isEnd(false),
        isIntercepted(false),
        isInitialUpdate(true)
        {
            ownerPtr = processOwnerPtr;
        };
        virtual ~HGProcess(){};
        void setNext(ProcessPtr nextPtr)
        {
            assert(nextPtr);
            nextProcessPtr = nextPtr;
        }
    protected:
        int frameCount;
        bool isEnd;
        bool isInitialUpdate;
        virtual void onInit(){}
        virtual void onEnd(){}
        virtual void onUpdate(){}
        virtual void onIntercept(){}
        virtual std::string getName()
        {
            return "BaseProcess";
        }
    private:
        bool isIntercepted;
        ProcessOwnerPtr ownerPtr;
        ProcessPtr nextProcessPtr;
        void update()
        {
            this->onUpdate();
            frameCount++;
            isInitialUpdate = false;
        }
        void end()
        {
            this->onEnd();
        }
        void intercept()
        {
            this->onIntercept();
        }
        friend class HGProcessManager;
    };
    
    // プロセスオーナークラス
    class HGProcessOwner
    {
    public:
        HGProcessOwner():
        currentProcessPtr(NULL)
        {}
    private:
        ProcessPtr currentProcessPtr;
        friend class HGProcessManager;
    };
    
    // プロセス管理クラス
    typedef std::list<ProcessPtr> ProcessList;
    static HGProcessManager* hgProcessManagerPtr = NULL;
    class HGProcessManager
    {
    public:
        static inline HGProcessManager* sharedProcessManager()
        {
            if (!hgProcessManagerPtr)
            {
                hgProcessManagerPtr = new HGProcessManager();
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
            processList.clear();
        }
        void addPrcoess(ProcessPtr processPtr)
        {
#if IS_PROCESS_DEBUG
            HDebug(@"Add Process : %s", processPtr->getName().c_str());
#endif
            ProcessOwnerPtr ownerPtr = processPtr->ownerPtr;
            if (ownerPtr->currentProcessPtr)
            {
#if IS_PROCESS_DEBUG
                HDebug(@"Process Intercepted : %s", ownerPtr->currentProcessPtr->getName().c_str());
#endif
                ownerPtr->currentProcessPtr->intercept();
                ownerPtr->currentProcessPtr->isIntercepted = true;
                ownerPtr->currentProcessPtr->isEnd = true;
            }
            ownerPtr->currentProcessPtr = processPtr;
            addProcessList.push_back(processPtr);
        }
        void update()
        {
            for (ProcessList::iterator it = addProcessList.begin(); it != addProcessList.end(); ++it)
            {
                (*it)->onInit();
                processList.push_back(*it);
            }
            addProcessList.clear();
            for (ProcessList::iterator it = processList.begin(); it != processList.end(); ++it)
            {
                ProcessPtr tmp = *it;
                if (tmp->isIntercepted)
                {
                    // 中断された場合、nextも中断
                    delProcessList.push_back(tmp);
                    continue;
                }
                tmp->update();
                if (tmp->isEnd)
                {
#if IS_PROCESS_DEBUG
                    HDebug(@"Process Ended: %s", tmp->getName().c_str());
#endif
                    tmp->end();
                    delProcessList.push_back(tmp);
                    if (tmp->nextProcessPtr)
                    {
#if IS_PROCESS_DEBUG
                        HDebug(@"Next Process Found : %s", tmp->nextProcessPtr->getName().c_str());
#endif
                        this->addPrcoess(tmp->nextProcessPtr);
                        tmp->nextProcessPtr = NULL;
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
    typedef std::list<NodePtr> Children;
    class HGNode : public HGObject
    {
    public:
        HGNode():
        size(0,0),
        scale(1,1,1),
        position(0,0,0),
        rotate(0,0,0)
        {
        }
        virtual ~HGNode(){}
        
        void removeAllChildren()
        {
            children.clear();
        }
        
        void removeChild(NodePtr node)
        {
            children.remove(node);
        }
        
        void addChild(NodePtr node)
        {
            children.push_back(node);
            //node->parent = NodePtr(this);
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
        //NodePtr parent;
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
    class HGDirector
    {
    public:
        static inline HGDirector* sharedDirector()
        {
            if (!directorPtr)
            {
                directorPtr = new HGDirector();
                directorPtr->init();
            }
            return directorPtr;
        }
        void drawRootNode()
        {
            rootNodePtr->draw(rootPosition, rootScale, rootRotate);
        }
        NodePtr getRootNode()
        {
            return rootNodePtr;
        }
    private:
        void init()
        {
            rootNodePtr = NodePtr(new HGNode());
            rootPosition = Vector(0,0,0);
            rootScale = Vector(1,1,1);
            rootRotate = Vector(0,0,0);
        }
        NodePtr rootNodePtr;
        Vector rootPosition;
        Vector rootScale;
        Vector rootRotate;
    };

}
#endif
