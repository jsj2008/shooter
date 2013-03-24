#import "HGUtil.h"
#import "HGCommon.h"
#import "HGPlayer.h"

#import <string>

using namespace std;

namespace HGGame
{
    
    typedef HGFighter base;
    
    HGPlayer::~HGPlayer()
    {
    }
    
    void HGPlayer::init(HG_FIGHTER_TYPE type, WHICH_SIDE side)
    {
        base::init(type, side);
        maxVelocity = velocity;
    }
    
    void HGPlayer::update()
    {
        base::update();
    }
    
    void HGPlayer::setVelocityWithPower(float power)
    {
        setVelocity(maxVelocity*power);
    }
    

}
