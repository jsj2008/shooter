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
    //{&HGFighter::DroidInit, &HGFighter::DroidDraw},
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

void HGFighter::update()
{
#warning 種類別に
    base::update();
    int spIdx = getSpriteIndex(aspect + 0.5);
    int x = anime1.texture.sprWidth * spIdx;
#warning テクスチャオブジェクトで行うように
    anime1.texture.setTextureArea(x, 0, anime1.texture.sprWidth, anime1.texture.sprWidth);
}

// --------------------------------------------------
// 種類別
// --------------------------------------------------
void HGFighter::N1Init()
{
    base::setActorInfo(HG_TYPE_E_ROBO1);
    //base::setSize(64, 64);
    anime1 = t_hgl2d();
    anime1.texture = (*HGLTexture::createTextureWithAsset("e_robo2.png"));
    anime1.position = position;
    anime1.scale = scale;
    anime1.texture.sprWidth = 64;
    anime1.texture.sprHeight = 64;
}

void HGFighter::N1Draw()
{
    anime1.position = position;
    HGLGraphics2D::draw(&anime1);
    //base::draw(&anime1);
}

/*
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
}*/


