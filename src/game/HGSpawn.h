#import "HGLTypes.h"
#import "HGLGraphics2D.h"
#import "HGActor.h"
#import "HGFighter.h"

namespace HGGame {
    
    class HGSpawn : public HGActor
    {
    public:
        HGSpawn();
        ~HGSpawn();
        void draw();
        void update();
        void init(HG_FIGHTER_TYPE type);
        
    private:
        bool isTextureInit;
        hgles::HGLTexture bomb;
        hgles::HGLTexture glow;
        hgles::HGLTexture star;
        int updateCount;
        hgles::HGLVector3 glowScale;
        hgles::HGLVector3 starScale;
        hgles::HGLVector3 bombScale;
        HG_FIGHTER_TYPE type;
        bool created;
    };
    
}
