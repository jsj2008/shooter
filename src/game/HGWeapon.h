#import "HGCommon.h"
#import "HGLVector3.h"
#import <vector>

namespace HGGame {
    
    typedef enum TYPE_WEAPON
    {
        WEAPON_LIFLE,
    } TYPE_WEAPON;
    
    class HGWeapon
    {
    public:
        HGWeapon():
            directionRadian(0){}
        ~HGWeapon();
        // 初期化
        void init(TYPE_WEAPON type, t_pos2d relative_position);
        // 発射
        void fire(hgles::HGLVector3 &shooter_pos, hgles::HGLVector3 &shooter_rotate, float shootDirectionRadian);
        // 向き設定
        void setDirectionRadian(float radian);
        
    private:
        // 武器の向き
        float directionRadian;
        // 武器の持ち主にとっての相対的な位置
        t_pos2d relativePosition;
        // 前回発射時間
        double lastFireTime;
        // 発射間隔
        double fireInterval;
        // 武器種類
        TYPE_WEAPON type;
    };
    
}
