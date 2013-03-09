#import "HGActor.h"
#import "HGFighter.h"
#import "HGUtil.h"
#import "HGCommon.h"

namespace HGGame
{
    
    typedef HGActor base;
    
    HGFighter::HGFighter()
    {
    }
    
    // 種類ごとに関数ポインタを設定
    void HGFighter::init(HG_FIGHTER_TYPE type)
    {
#warning テーブル化
        switch (type) {
            case HG_FIGHTER:
                width = 64;
                height = 64;
                scale.set(width*SCRATE, height*SCRATE, 1);
                break;
            default:
                break;
        }
        base::setActorInfo(HG_TYPE_E_ROBO1);
        setSize(width, height);
        
        anime1 = t_hgl2di();
        anime1.texture = (*HGLTexture::createTextureWithAsset("e_robo2.png"));
        anime1.position = position;
        anime1.scale = scale;
        anime1.texture.sprWidth = info->sprWidth;
        anime1.texture.sprHeight = info->sprHeight;
    }
    
    void HGFighter::draw()
    {
        anime1.position = position;
        HGLGraphics2D::draw(&anime1);
    }
    
    void HGFighter::update()
    {
#warning 種類別に
        base::update();
        int spIdx = getSpriteIndex(aspect + 0.5);
        int x = anime1.texture.sprWidth * spIdx;
#warning テクスチャオブジェクトで行うように
        anime1.texture.setTextureArea(x, 0, anime1.texture.sprWidth, anime1.texture.sprWidth);
    }
    

}
