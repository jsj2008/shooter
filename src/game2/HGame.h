#ifndef INC_HGGAME
#define INC_HGGAME
#include "HGLVector3.h"

namespace hg
{
    
    class HGObject;
    class HGNode;
    class HGSprite;
    
    class HGState;
    class HGStateManager;
    
    typedef struct t_keyState
    {
        int fire = 0;
    } t_keyState;
    
    void initialize();
    void render();
    void update(t_keyState* keyState);
    void onMoveLeftPad(int degree, float power);
}
#endif