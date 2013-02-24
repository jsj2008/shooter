#import "HGActor.h"
#import "HGFighter.h"
#import "HGUtil.h"

typedef HGActor base;

HGFighter::HGFighter()
{
    base();
    base::useLight = false;
}

// 種類ごとに関数ポインタを設定
void HGFighter::init(HG_FIGHTER_TYPE type)
{
#warning テーブル化
    pDrawFunc = &HGFighter::N1Draw;
    pInitFunc = &HGFighter::N1Init;
    
    // 初期化
    (this->*pInitFunc)();
}

void HGFighter::draw()
{
    (this->*pDrawFunc)();
}

// --------------------------------------------------
// 種類別
// --------------------------------------------------
void HGFighter::N1Draw()
{
    s_draw1.position = position;
    s_draw1.textureMatrix = textureMatrix;
    
    int spIdx = getSpriteIndex(aspect + 0.5);
    int x = s_draw1.textureW * spIdx;
    s_draw1.texture->setTextureArea(x, 0, 64, 64);
    
    HGActor::draw(&s_draw1);
}

void HGFighter::N1Init()
{
    s_draw1.object3D = object3DTable["rect"];
    s_draw1.texture = textureTable["e_robo2.png"];
    s_draw1.position = position;
    s_draw1.scale = scale;
    s_draw1.textureW = 64;
    s_draw1.textureH = 64;
}




