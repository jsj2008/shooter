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
    
    
    std::map<std::string,HGHeap*> HGHeapFactory::heapList;
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
        return (HGObject*)s_pHeap->alloc(size);
    }
    void HGObject::operator delete(void *p, size_t size)
    {
        s_pHeap->deleteAllocation(p);
    }
    
    
}