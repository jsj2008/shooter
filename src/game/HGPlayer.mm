#import "HGGame.h"
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
        target = NULL;
        maxVelocity = velocity;
    }
    
    void HGPlayer::update()
    {
        base::update();
    }
    
    void HGPlayer::setVelocityWithPower(float power)
    {
        setVelocity(maxVelocity*power);
        updateAccel();
    }
    
    HGFighter* HGPlayer::tellTarget()
    {
#warning 部下にターゲットを知らせる
        return target;
    }
    
    void HGPlayer::draw()
    {
        base::draw();
    }
    
    void HGPlayer::damage(int damage, HGFighter* attacker)
    {
        target = attacker;
        life -= damage;
        if (life == 0)
        {
            createEffect(EFFECT_EXPLODE_NORMAL, &position);
        }
        else
        {
            createEffect(EFFECT_HIT_NORMAL, &position);
        }
    }
    
}
