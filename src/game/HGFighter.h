#ifndef INC_HGFIGHTER
#define INC_HGFIGHTER
#import "HGLGraphics2D.h"
#import "HGActor.h"
#import "HGWeapon.h"
#import <vector>

namespace HGGame
{
    namespace userinfo{
        struct t_fighter;
    }
    
    class HGWeapon;
    class HGBullet;
    
    typedef std::vector<HGWeapon> t_weapon_list;

    enum HG_FIGHTER_TYPE {
        HGF_ENEMY1,
        HGF_PL1,
        HGF_ESHIP1,
    };
    
    enum HG_ANIME_TYPE {
        HG_ANIME_SPRITE,
        HG_NON_ANIME_SPRITE,
    };
    
    class HGFighter : public HGActor
    {
        
    public:
        HGFighter();
        int life;
        int maxlife;
        int explodeCount;
        HG_FIGHTER_TYPE type;
        
        void initWithData(userinfo::t_fighter* f, WHICH_SIDE side);
        virtual void init(HG_FIGHTER_TYPE type, WHICH_SIDE side);
        virtual void draw();
        virtual void update();
        virtual ~HGFighter(){}
        // ダメージを受けるとき
        virtual void damage(int damage, HGFighter* attacker, HGBullet* bullet) = 0;
        // ターゲットを尋ねる
        virtual HGFighter* tellTarget() = 0;
        
        // 攻撃する
        void fire();
        
        void setSide(WHICH_SIDE side);
        
        std::string getTextureName();
        
        ////////////////////
        // テクスチャ
        t_pos2d sprPos;
        hgles::HGLTexture texture;
        t_size2d sprSize;
        bool isTextureInit;
        std::string textureName;
        HG_ANIME_TYPE animeType;
    protected:
        WHICH_SIDE side;
    private:
        t_weapon_list weapon_list;
        void setMaxLife(int maxlife);
        
    private:
        
    };
    
}
#endif
