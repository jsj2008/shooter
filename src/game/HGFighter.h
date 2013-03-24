#ifndef INC_HGFIGHTER
#define INC_HGFIGHTER
#import "HGLGraphics2D.h"
#import "HGActor.h"
#import "HGWeapon.h"
#import "HGGame.h"
#import <vector>

namespace HGGame
{
    typedef std::vector<HGWeapon> t_weapon_list;

    enum HG_FIGHTER_TYPE {
        HG_FIGHTER,
    };
    
    class HGFighter : public HGActor
    {
        
    public:
        HGFighter();
        int life;
        int explodeCount;
        HG_FIGHTER_TYPE type;
        
        virtual void init(HG_FIGHTER_TYPE type, WHICH_SIDE side);
        virtual void draw();
        virtual void update();
        virtual ~HGFighter(){}
        
        // 攻撃する
        void fire();
        
        void setSide(WHICH_SIDE side);
        
    private:
        t_weapon_list weapon_list;
        WHICH_SIDE side;
        
    private:
        hgles::HGLTexture texture;
        t_size2d sprSize;
        bool isTextureInit;
        std::string textureName;
        
    };
    
}
#endif
