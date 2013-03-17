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
        base::init();
        int hitbox_id = 0;
        t_size2d size;
        explodeCount = 500;
        switch (type) {
            case HG_FIGHTER:
                textureName = "e_robo2.png";
                hitbox_id = 0;
                size.w = 64;
                size.h = 64;
                life = 5;
                break;
            default:
                break;
        }
        this->type = type;
        sprSize = size;
        isTextureInit = false;
        initActor(*this, sprSize, hitbox_id);
    }
    
    void HGFighter::draw()
    {
        if (!isTextureInit)
        {
            texture = (*hgles::HGLTexture::createTextureWithAsset(textureName));
            texture.sprWidth = sprSize.w;
            texture.sprHeight = sprSize.h;
            isTextureInit = true;
        }
        int spIdx = getSpriteIndex(aspect + 0.5);
        int x = texture.sprWidth * spIdx;
        texture.setTextureArea(x, 0, texture.sprWidth, texture.sprWidth);
        hgles::HGLGraphics2D::draw(&position, &scale, &texture);
    }
    
    void HGFighter::update()
    {
        base::update();
    }
    

}
