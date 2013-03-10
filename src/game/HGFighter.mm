#import "HGActor.h"
#import "HGFighter.h"
#import "HGUtil.h"
#import "HGCommon.h"

#import <string>

using namespace std;

namespace HGGame
{
    
    typedef HGActor base;
    
    HGFighter::HGFighter()
    {
    }
    
    HGFighter::~HGFighter()
    {
    }
    
    void HGFighter::init(HG_FIGHTER_TYPE type)
    {
        string img_name;
        int hitbox_id = 0;
        int w = 0;
        int h = 0;
        switch (type) {
            case HG_FIGHTER:
                img_name = "e_robo2.png";
                hitbox_id = 0;
                w = h = 64;
                break;
            default:
                break;
        }
        t_size2d size = {(float)w, (float)h};
        initActor(*this, size, hitbox_id);
        anime1 = hgles::t_hgl2di();
        anime1.texture = (*hgles::HGLTexture::createTextureWithAsset(img_name));
        anime1.position = position;
        anime1.scale = scale;
        anime1.texture.sprWidth = w;
        anime1.texture.sprHeight = h;
    }
    
    void HGFighter::draw()
    {
        anime1.position = position;
        hgles::HGLGraphics2D::draw(&anime1);
    }
    
    void HGFighter::update()
    {
        base::update();
        int spIdx = getSpriteIndex(aspect + 0.5);
        int x = anime1.texture.sprWidth * spIdx;
#warning テクスチャオブジェクトで行うように
        anime1.texture.setTextureArea(x, 0, anime1.texture.sprWidth, anime1.texture.sprWidth);
    }
    

}
