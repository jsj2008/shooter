#import "HGLGraphics2D.h"
#import "HGFighter.h"

namespace HGGame
{

    class HGPlayer : public HGFighter
    {
    public:
        ~HGPlayer();
        
        // override
        void init(HG_FIGHTER_TYPE type);
        void update();
        
    };
    
}
