#import "HGLTypes.h"
#import "HGLGraphics2D.h"
#import "HGActor.h"

namespace HGGame {
    
    class HGHit : public HGActor
    {
    public:
        HGHit();
        ~HGHit();
        void draw();
        void update();
        void init();
        
    private:
        bool isTextureInit;
        hgles::HGLTexture bomb;
        hgles::HGLTexture glow;
        int updateCount;
        hgles::HGLVector3 glowScale;
        hgles::HGLVector3 bombScale;
    };
    
}
