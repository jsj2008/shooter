#import "HGLGraphics2D.h"

namespace HGGame
{

    enum HG_FIGHTER_TYPE {
        HG_FIGHTER,
    };
    
    class HGActor;
    class HGFighter : public HGActor
    {
    public:
        HGFighter();
        ~HGFighter();
        void draw();
        void init(HG_FIGHTER_TYPE type);
        void update();
        int life;
        int explodeCount;
        
    private:
        hgles::HGLTexture texture;
        HG_FIGHTER_TYPE type;
        
        bool isTextureInit;
        std::string textureName;
        t_size2d sprSize;
    };
    
}
