#import "HGLGraphics2D.h"
#import "HGFighter.h"

namespace HGGame
{

    class HGPlayer : public HGFighter
    {
    public:
        ~HGPlayer();
        
        // override
        void init(HG_FIGHTER_TYPE type, WHICH_SIDE side);
        void update();
        HGFighter* tellTarget();
        void damage(int damage, HGFighter* attacker, HGBullet* bullet);
        void draw();
        
        // パワー(キー入力)に応じた速度に設定する
        void setVelocityWithPower(float power);
    private:
        float maxVelocity;
        HGFighter* target;
        
    };
    
}
