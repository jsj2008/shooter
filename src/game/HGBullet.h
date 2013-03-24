#import "HGLTypes.h"
#import "HGLGraphics2D.h"
#import "HGActor.h"
#import "HGGame.h"

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
        void init(HG_BULLET_TYPE type, WHICH_SIDE side);
        
        int range; // 射程
    private:
        HG_BULLET_TYPE type;
        int updateCount;
        bool isTextureInit;
        hgles::HGLTexture core;
        hgles::HGLTexture glow;
        WHICH_SIDE side;
    };
    
}
