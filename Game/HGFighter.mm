#import "HGActor.h"
#import "HGFighter.h"
#import "HGUtil.h"

typedef HGActor base;

typedef struct s_hg_fighter_type
{
    void (HGFighter::*pInitFunc)();
    void (HGFighter::*pDrawFunc)();
} t_hg_fighter_type;

t_hg_fighter_type hg_fighter_table[] =
{
    {&HGFighter::N1Init, &HGFighter::N1Draw},
    {&HGFighter::DroidInit, &HGFighter::DroidDraw},
};

HGFighter::HGFighter()
{
}

// 種類ごとに関数ポインタを設定
void HGFighter::init(HG_FIGHTER_TYPE type)
{
#warning テーブル化
    pInitFunc = hg_fighter_table[type].pInitFunc;
    pDrawFunc = hg_fighter_table[type].pDrawFunc;
    
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
void HGFighter::N1Init()
{
    s_draw1.object3D = object3DTable["rect"];
    s_draw1.texture = textureTable["e_robo2.png"];
    s_draw1.position = position;
    s_draw1.scale = scale;
    s_draw1.textureW = 64;
    s_draw1.textureH = 64;
}

void HGFighter::N1Draw()
{
    s_draw1.position = position;
    
    int spIdx = getSpriteIndex(aspect + 0.5);
    int x = s_draw1.textureW * spIdx;
    s_draw1.texture->setTextureArea(x, 0, 64, 64);
    
    HGActor::draw(&s_draw1);
}

void HGFighter::DroidInit()
{
    s_draw1.object3D = object3DTable["droid"];
    s_draw1.texture = NULL;
}

void HGFighter::DroidDraw()
{
    s_draw1.position = position;
    s_draw1.scale = scale;
    s_draw1.rotate = rotate;
    s_draw1.useLight = 1.0;
    HGActor::draw(&s_draw1);
}


