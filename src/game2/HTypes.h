#ifndef __HTYPE_H__
#define __HTYPE_H__

#import "HGLES.h"

namespace hg
{
    
    class HGHeap;
    ////////////////////
    //  typedef
    typedef struct AllocHeader
    {
        HGHeap *pHeap;
        int iSize;
        int iSignature;
        AllocHeader *pNext;
        AllocHeader *pPrev;
        int referenceCount = 0;
    } AllocHeader;
    
    typedef hgles::HGLVector3 Vector;
    
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
    
}
#endif
