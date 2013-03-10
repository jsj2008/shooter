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
        
    private:
        hgles::t_hgl2di anime1;
        
    };
    
}
