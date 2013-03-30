#import "HGLTypes.h"
#import "HGLGraphics2D.h"
#import "HGActor.h"
#import "HGGame.h"
#import "HGFighter.h"

namespace HGGame {
    
    enum HG_BULLET_TYPE {
        HG_BULLET_N1,
    };
    
    class HGBullet : public HGActor
    {
    public:
        HGBullet();
        ~HGBullet();
        void draw();
        void update();
        void init(HG_BULLET_TYPE type, WHICH_SIDE side, int power);
        
        float range; // 射程
        HGFighter* owner; // 発射した人
        int power; // 威力
        
    private:
        HG_BULLET_TYPE type;
        int updateCount;
        bool isTextureInit;
        hgles::HGLTexture core;
        hgles::HGLTexture glow;
        WHICH_SIDE side;
        double shotTime; // 発車時間
    };
    
}
