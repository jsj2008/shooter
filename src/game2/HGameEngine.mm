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
    
}