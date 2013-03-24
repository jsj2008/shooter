#import "HGLGraphics2D.h"
#import "HGFighter.h"

namespace HGGame
{

    class HGCPU : public HGFighter
    {
    public:
        ~HGCPU();
        
        // override
        void init(HG_FIGHTER_TYPE type, WHICH_SIDE side);
        void update();
        
        // ターゲット
        HGFighter* target;
        
        // 移動目的地
        hgles::HGLVector3 destination;
        
        // 移動目的地を初期化
        void decideDestination();
        
    };
    
}
