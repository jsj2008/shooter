#ifndef INC_HGGAME
#define INC_HGGAME
#include "HGLVector3.h"
#include "HGameCommon.h"
#include <vector>

namespace hg
{
    
    // classes
    class HGObject;
    class HGNode;
    class HGSprite;
    class HGState;
    class HGStateManager;
    
    void initialize(SpawnData sd, FighterInfo* pl, FriendData fd);
    void render();
    void update(KeyInfo keyState);
}
#endif