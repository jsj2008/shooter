#import "HGLTypes.h"
#import "HGLGraphics2D.h"
#import "HGActor.h"

namespace HGGame {
    
    class HGExplode : public HGActor
    {
    public:
        HGExplode();
        ~HGExplode();
        void draw();
        void update();
        void init();
        
    private:
        bool isTextureInit;
        hgles::HGLTexture bomb;
        hgles::HGLTexture glow;
        hgles::HGLTexture smoke[3];
        int updateCount;
        hgles::HGLVector3 glowScale;
        t_size2d sprSize;
    };
    
}
