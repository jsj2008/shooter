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
    
    void initialize(SpawnData sd, FighterInfo* pl);
    void render();
    void deployFriends();
    void retreat();
    void update(KeyInfo keyState);
    bool isGameEnd();
    BattleResult getResult();
    void cleanup();
    void setPause(bool shouldPause);
    void setCameraZPostion(float val);
    float getHPRatio();
    float getShieldRatio();
}
#endif