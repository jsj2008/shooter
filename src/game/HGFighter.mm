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
    
    void HGFighter::update()
    {
        base::update();
        if (life > 0)
        {
            // フィールド外チェック
            t_size2d* field_size = get_size_of_field();
            if (position.x + realSize.w/2 > field_size->w)
            {
                position.x = field_size->w - realSize.w/2;
            }
            if (position.y + realSize.h/2 > field_size->h)
            {
                position.y = field_size->h - realSize.h/2;
            }
            if (position.x - realSize.w/2 < 0)
            {
                position.x = realSize.w/2;
            }
            if (position.y - realSize.h/2 < 0)
            {
                position.y = realSize.h/2;
            }
        }
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
            texture.color.a -= 0.1;
            if (texture.color.a <= 0)
            {
                return;
            }
        }
        hgles::HGLGraphics2D::draw(&position, &scale, &rotate,  &texture);
    }
    
    void HGFighter::fire()
    {
        for (t_weapon_list::iterator ite = weapon_list.begin(); ite != weapon_list.end(); ++ite)
        {
            (*ite).fire(position, rotate, radian, side);
        }
    }
    
    void HGFighter::setSide(WHICH_SIDE side)
    {
        this->side = side;
    }
    
    void HGFighter::init(HG_FIGHTER_TYPE type, WHICH_SIDE side)
    {
        this->side = side;
        this->type = type;
        isTextureInit = false;
        explodeCount = 15;
        switch (type) {
            case HG_FIGHTER:
            {
                initActor(*this, {128, 128}, 2);
                textureName = "e_robo2.png";
                sprSize = {64,64};
                if (side == ENEMY_SIDE)
                {
                    setVelocity(0.2);
                    life = 3;
                }
                else
                {
                    setVelocity(0.5);
                    life = 725;
                }
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
