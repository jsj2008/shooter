#ifndef INC_HGGAME
#define INC_HGGAME
#include "HGLVector3.h"
#include "HGameCommon.h"
#include <vector>

namespace hg
{
    
    typedef struct t_keyState
    {
        int fire = 0;
    } t_keyState;
    
    // classes
    class HGObject;
    class HGNode;
    class HGSprite;
    class HGState;
    class HGStateManager;
    
    void initialize(SpawnData sd, FighterInfo pl, FriendData fd);
    void render();
    void update(t_keyState* keyState);
    void onMoveLeftPad(int degree, float power);
}
#endif