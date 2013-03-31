#ifndef INC_HGWEAPON
#define INC_HGWEAPON
#import "HGWeapon.h"
#import "HGCommon.h"
#import "HGGame.h"
#import "HGBullet.h"

using namespace std;

namespace HGGame {
    
    HGWeapon::~HGWeapon()
    {
    }
    
    // 初期化
    void HGWeapon::init(TYPE_WEAPON type, t_pos2d relative_position, HGFighter* owner, int power)
    {
        this->type = type;
        this->owner = owner;
        this->power = power;
        relativePosition = relative_position;
        switch (type) {
            case WEAPON_LIFLE:
                fireInterval = 0.2;
                break;
            default:
                break;
        }
    }
        
    // 発射
    void HGWeapon::fire(hgles::HGLVector3 &shooter_pos, hgles::HGLVector3 &shooter_rotate, float shootDirectionRadian, WHICH_SIDE side)
    {
        double now = getNowTime();
        if (now - lastFireTime < fireInterval)
        {
            return;
        }
        lastFireTime = now;
        
        switch (type) {
            case WEAPON_LIFLE:
            {
                HGBullet* t = getBullet(side);
                if (t == NULL) {
                    return;
                }
                t->position.x = shooter_pos.x + cos(shooter_rotate.z)*relativePosition.x;
                t->position.y = shooter_pos.y + sin(shooter_rotate.z)*relativePosition.y;
                t->position.z = shooter_pos.z;
                t->setMoveDirectionWithRadian(directionRadian);
                t->init(HG_BULLET_N1, side, power);
                t->setMoveDirectionWithRadian(shootDirectionRadian);
                t->setVelocity(0.55);
                t->range = 3;
                t->owner = owner;
                break;
            }
            default:
                assert(0); // error
        }
    }
    
    void HGWeapon::setDirectionRadian(float radian)
    {
        directionRadian = radian;
    }
}

#endif