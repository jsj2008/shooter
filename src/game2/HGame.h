#ifndef INC_HGGAME
#define INC_HGGAME
#include "HGLVector3.h"
#include "HGameCommon.h"
#include "Common.h"
#include <vector>

namespace hg
{
    
    typedef struct GameMessage {
        GameMessage(std::string _message):
            message(_message)
        {
        }
        GameMessage(std::string _message, std::string _colorHex):
            message(_message), colorHex(_colorHex)
        {
        }
        std::string message;
        std::string colorHex = "#ffffff";
    } GameMessage;
    typedef std::vector<GameMessage> GameMessageList;
    
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
    bool isControllable();
    GameMessageList getGameMessageList();
    void clearGameMessageList();
}
#endif