#import "HGActor.h"
#import "HGFighter.h"
#import "HGUtil.h"

typedef HGActor base;

HGFighter::HGFighter()
{
    base();
    base::useLight = false;
}

void HGFighter::init(FIGHTER_TYPE type)
{
    // オブジェクトの種類別の関数を設定
#warning テーブル化
    pDrawFunc = &HGFighter::N1Draw;
    pInitFunc = &HGFighter::N1Init;
    
    // 初期化
    (this->*pInitFunc)();
    
}

void HGFighter::setAspect(float degree)
{
    // 角度に応じてスプライトを選択する
    int spIdx = getSpriteIndex(degree + 0.5);
    int x = 64 * spIdx;
    base::setTextureArea(x, 0, 64, 64);
    base::setAspect(degree);
}

void HGFighter::draw()
{
    //base::draw();
    (this->*pDrawFunc)();
}


// ==================================================
// 種類別の関数
// ==================================================

void HGFighter::N1Draw()
{
    s_draw1.position = position;
    s_draw1.textureMatrix = textureMatrix;
    HGActor::draw(&s_draw1);
}

void HGFighter::N1Init()
{
    s_draw1.texture = textureTable["e_robo2.png"];
    s_draw1.position = position;
    s_draw1.scale = scale;
}




