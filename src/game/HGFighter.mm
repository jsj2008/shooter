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
        base::~HGActor();
    }
    
    void HGFighter::update()
    {
        base::update();
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
        int spIdx = getSpriteIndex(degree + 0.5);
        int x = texture.sprWidth * spIdx;
        texture.setTextureArea(x, 0, texture.sprWidth, texture.sprWidth);
        if (life == 0)
        {
            texture.blendColor = {0.5,0.5,0.5,1};
        }
        hgles::HGLGraphics2D::draw(&position, &scale, &rotate,  &texture);
    }
    
    void HGFighter::fire()
    {
        for (t_weapon_list::iterator ite = weapon_list.begin(); ite != weapon_list.end(); ++ite)
        {
            (*ite).fire(position, rotate, radian);
        }
    }
    
    void HGFighter::init(HG_FIGHTER_TYPE type)
    {
        type = type;
        isTextureInit = false;
        switch (type) {
            case HG_FIGHTER:
            {
                initActor(*this, {128, 128}, 2);
                textureName = "e_robo2.png";
                sprSize = {64,64};
                life = 5;
                HGWeapon w = HGWeapon();
                w.init(WEAPON_LIFLE, {0, 0});
                weapon_list.push_back(w);
                break;
            }
            default:
                assert(0);
        }
    }
    
    

}
