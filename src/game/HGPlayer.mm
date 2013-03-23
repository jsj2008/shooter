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
        base::~HGFighter();
    }
    
    void HGPlayer::init(HG_FIGHTER_TYPE type)
    {
        base::init(type);
        explodeCount = 200;
    }
    
    void HGPlayer::update()
    {
        base::update();
    }
    

}
