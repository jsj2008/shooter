#ifndef INC_HGFIGHTER
#define INC_HGFIGHTER
#import "HGLGraphics2D.h"
#import "HGActor.h"
#import "HGWeapon.h"
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
        
        virtual void init(HG_FIGHTER_TYPE type);
        virtual void draw();
        virtual void update();
        virtual ~HGFighter();
        
        // 攻撃する
        void fire();
        
    private:
        t_weapon_list weapon_list;
        
    private:
        hgles::HGLTexture texture;
        t_size2d sprSize;
        bool isTextureInit;
        std::string textureName;
        
    };
    
}
#endif
