#import "HGGame.h"
#import "HGFighter.h"
#import "HGUtil.h"
#import "HGCommon.h"
#import "HGUser.h"

#import <string>

using namespace std;

namespace HGGame
{
    
    typedef std::vector<HGWeapon> t_weapon_list;
    typedef HGActor base;
    
    HGFighter::HGFighter()
    {
    }
    
    void HGFighter::initWithData(userinfo::t_fighter* f, WHICH_SIDE side)
    {
        init(f->type, side);
        life = f->life;
        maxlife = f->life;
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
            isTextureInit = true;
        }
        switch (animeType) {
            case HG_ANIME_SPRITE:
            {
                int spIdx = getSpriteIndex(degree + 0.5);
                int x = sprSize.w * spIdx + sprPos.x;
                texture.setTextureArea(x, sprPos.y, sprSize.w, sprSize.h);
                break;
            }
            case HG_NON_ANIME_SPRITE:
                texture.setTextureArea(sprPos.x, sprPos.y, 204, 78);
                break;
            default:
                assert(0);
        }
        
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
    
    void HGFighter::setMaxLife(int maxlife)
    {
        life = maxlife;
        this->maxlife = maxlife;
    }
    
    std::string HGFighter::getTextureName()
    {
        return textureName;
    }
    
    void HGFighter::init(HG_FIGHTER_TYPE type, WHICH_SIDE side)
    {
        this->side = side;
        this->type = type;
        isTextureInit = false;
        explodeCount = 15;
        animeType = HG_ANIME_SPRITE;
        switch (type) {
            case HGF_ENEMY1:
            {
                initActor(*this, {128, 128}, 2);
                textureName = "e_robo2.png";
                sprSize = {64,64};
                sprPos = {0, 0};
                setVelocity(0.2);
                setMaxLife(30);
                HGWeapon w = HGWeapon();
                w.init(WEAPON_LIFLE, {0, 0}, this, 10);
                weapon_list.push_back(w);
                break;
            }
            case HGF_ESHIP1:
            {
                initActor(*this, {2040, 780}, 3);
                textureName = "e_senkan1_4.png";
                animeType = HG_NON_ANIME_SPRITE;
                setVelocity(0.1);
                setMaxLife(300);
                sprSize = {204, 78};
                sprPos = {0, 0};
                HGWeapon w = HGWeapon();
                w.init(WEAPON_LIFLE, {0, 0}, this, 8);
                w.init(WEAPON_LIFLE, {-50*SCRATE, -50*SCRATE}, this, 8);
                w.init(WEAPON_LIFLE, {-50*SCRATE, 50*SCRATE}, this, 8);
                w.init(WEAPON_LIFLE, {50*SCRATE,  50*SCRATE}, this, 8);
                w.init(WEAPON_LIFLE, {50*SCRATE, -50*SCRATE}, this, 8);
                weapon_list.push_back(w);
                break;
            }
            case HGF_PL1:
            {
                initActor(*this, {128, 128}, 2);
                textureName = "p_robo1.png";
                sprSize = {16,16};
                sprPos = {0, 0};
                setVelocity(0.7);
                setMaxLife(8000);
                HGWeapon w = HGWeapon();
                w.init(WEAPON_LIFLE, {0, 0}, this, 10);
                weapon_list.push_back(w);
                break;
            }
            default:
                assert(0);
        }
    }
    
    

}
