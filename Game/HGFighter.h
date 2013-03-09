#import "HGLGraphics2D.h"

enum HG_FIGHTER_TYPE {
    HG_FIGHTER_N1,
    HG_DROID
};

class HGActor;
class HGFighter : public HGActor
{
public:
    HGFighter();
    void draw();
    void init(HG_FIGHTER_TYPE type);
    void update();
    
private:
    t_hgl2di anime1;
    
};
