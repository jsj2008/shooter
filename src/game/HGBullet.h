#import "HGLTypes.h"
#import "HGLGraphics2D.h"
#import "HGActor.h"

namespace HGGame {
    
    enum HG_BULLET_TYPE {
        HG_BULLET_N1,
        HG_BULLET_N2
    };
    
    class HGBullet : public HGActor
    {
    public:
        HGBullet();
        ~HGBullet();
        void draw();
        void update();
        void init(HG_BULLET_TYPE type);
        
    private:
        HG_BULLET_TYPE type;
        int updateCount;
        bool isTextureInit;
        hgles::HGLTexture core;
        hgles::HGLTexture glow;
    };
    
}
