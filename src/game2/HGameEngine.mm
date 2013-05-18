#include "HGameEngine.h"

namespace hg
{
    int f(float frame)
    {
        return (int)((frame*GAMEFPS/60.0) + 0.5);
    }
    float v(float vec)
    {
        return vec*60/GAMEFPS;
    }
    int rand(int from, int to)
    {
        if (from == to) return from;
        int r = std::rand()%(to - from + 1);
        int ret = r+from;
        assert(ret >= from);
        assert(to >= ret);
        return ret;
    }
    float toDeg(float radian)
    {
        return radian * 180/M_PI;
    }
    float toRad(float degree)
    {
        return degree * M_PI/180;
    }
    static double nowTime = 0;
    void updateNowTime()
    {
        timeb tb;
        ftime( &tb );
        nowTime = (double)tb.millitm/1000.0 + (double)(tb.time & 0xfffff);
    }
    double getNowTime()
    {
        return nowTime;
    }
    
    ////////////////////
    // ヒープ
    std::string HGHeap::getName()
    {
        return name;
    }
    void* HGHeap::alloc(size_t size)
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
        objectCount++;
#if IS_DEBUG_MEMORY
        HDebug(@"ALLOC: %d", objectCount);
#endif
        pHeader->pStart = pStartMemBlock;
        return pStartMemBlock;
    }
    void HGHeap::deleteAllocation(void *pMem)
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
        objectCount--;
#if IS_DEBUG_MEMORY
        HDebug(@"DELETE: %d", objectCount);
#endif
        assert(*pEndmarker == ENDMARKER);
        free(pHeader);
    }
    void HGHeap::freeAll()
    {
        pFirst = NULL;
        pLast = NULL;
        allocatedSize = 0;
    }
    void HGHeap::retain(void *pMem)
    {
        AllocHeader *pHeader = (AllocHeader *)((char *)pMem - sizeof(AllocHeader));
        assert(pHeader->iSignature == SIGNATURE);
        assert(pHeader->referenceCount >= 0);
        pHeader->referenceCount++;
    }
    void HGHeap::release(void *pMem)
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
    void HGHeap::addAllocation(size_t size)
    {
        allocatedSize += size;
    }
    void HGHeap::removeAllocation(size_t size)
    {
        allocatedSize -= size;
    }
    
    std::map<std::string,HGHeap*> HGHeapFactory::heapList;
    HGHeap* HGHeapFactory::CreateHeap(std::string name)
    {
        if (heapList.find(name) != heapList.end())
        {
            return heapList[name];
        }
        HGHeap* pHeap = new HGHeap(name);
        heapList[name] = pHeap;
        return pHeap;
    }
    
    ////////////////////
    // AutoRelease
    namespace AutoRelease
    {
        AutoReleaseList autoReleaseList;
    }
    
    ////////////////////
    // 基底
    
    HGHeap* HGObject::s_pHeap = NULL;
    void* HGObject::operator new(size_t size)
    {
        return operator new(size, DEFAULT_HEAP_NAME);
    }
    void* HGObject::operator new(size_t size, std::string heapName)
    {
        if (!s_pHeap)
        {
            s_pHeap = HGHeapFactory::CreateHeap(heapName);
        }
        HGObject* p = (HGObject*)s_pHeap->alloc(size);
        AutoRelease::addObject(p);
        return p;
    }
    /*
    void HGObject::operator delete(void *p, size_t size)
    {
        s_pHeap->deleteAllocation(p);
    }*/
    
    ////////////////////
    // ステート管理
    HGState::HGState()
    {
        isInitialUpdate = true;
    }
    
    std::string HGState::getName()
    {
        return "BaseState";
    }
    void HGState::update()
    {
        this->onUpdate();
        frameCount++;
        isInitialUpdate = false;
    }
    void HGState::suspend()
    {
        this->onSuspend();
    }
    void HGState::resume()
    {
        this->onResume();
    }

    static HGStateManager* pStateManager = NULL;
    HGStateManager* HGStateManager::sharedStateManger()
    {
        if (!pStateManager)
        {
            pStateManager = new (SYSTEM_HEAP_NAME)HGStateManager();
            pStateManager->retain();
        }
        return pStateManager;
    }
    
    void HGStateManager::clear()
    {
        while(stack.size())
        {
            stack.top()->release();
            stack.pop();
        }
    }
    
    void HGStateManager::update()
    {
        updateNowTime();
        if (!stack.empty())
        {
            HGState* state = stack.top();
            state->update();
        }
    }
    void HGStateManager::pop()
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
    void HGStateManager::push(HGState* state)
    {
        state->retain();
        if (stack.size() > 0)
        {
            stack.top()->suspend();
        }
        stack.push(state);
        HInfo(@"STATE PUSH : %s", state->getName().c_str());
    }
    
    ////////////////////
    // プロセス管理
    
    // プロセスクラス
    void HGProcess::setNext(HGProcess* nextPtr)
    {
        assert(nextPtr);
        nextPtr->retain();
        pNextProcess = nextPtr;
    }
    std::string HGProcess::getName()
    {
        return "BaseProcess";
    }
    
    // プロセス管理クラス
    void HGProcessManager::clear()
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
    
    void HGProcessManager::addAndExecProcess(HGProcess* pProcess)
    {
        this->addProcess(pProcess);
        this->exec(pProcess);
    }
    
    void HGProcessManager::addProcess(HGProcess* pProcess)
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
    
    void HGProcessManager::exec(HGProcess* tmp)
    {
        if (tmp->isIntercepted())
        {
            // 中断された場合、nextも中断
            assert(tmp->getRefCount() == 1);
            assert(tmp->_isIntercepted);
            delProcessList.push_back(tmp);
            return;
        }
        tmp->update();
        if (tmp->isEnd())
        {
#if IS_PROCESS_DEBUG
            HDebug(@"Process Ended: %s", tmp->getName().c_str());
#endif
            tmp->end();
            delProcessList.push_back(tmp);
            assert(tmp->_isEnd);
            HGProcess* pNext = tmp->pNextProcess;
            if (pNext)
            {
#if IS_PROCESS_DEBUG
                HDebug(@"Next Process Found : %s", tmp->pNextProcess->getName().c_str());
#endif
                this->addProcess(pNext);
                tmp->pNextProcess = NULL;
                pNext->release();
            }
        }
    }
    
    void HGProcessManager::update()
    {
        for (ProcessList::iterator it = addProcessList.begin(); it != addProcessList.end(); ++it)
        {
            processList.push_back(*it);
        }
        addProcessList.clear();
        for (ProcessList::iterator it = processList.begin(); it != processList.end(); ++it)
        {
            this->exec(*it);
        }
        for (ProcessList::iterator it = delProcessList.begin(); it != delProcessList.end(); ++it)
        {
            assert((*it)->getRefCount() <= 2);
            (*it)->release();
            processList.remove(*it);
        }
        delProcessList.clear();
    }
    void HGProcessManager::init()
    {
    }
    
    HGSprite* CreateAlphaMapSprite(std::string texture, Color color)
    {
        HGSprite* pSpr = new HGSprite();
        pSpr->setType(SPRITE_TYPE_BILLBOARD);
        pSpr->init(texture);
        pSpr->setColor(color);
        pSpr->shouldRenderAsAlphaMap(true);
        pSpr->setBlendFunc(GL_SRC_ALPHA, GL_ONE);
        return pSpr;
    }
    
    
    
}