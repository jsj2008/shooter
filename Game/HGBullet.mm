#import "HGActor.h"
#import "HGBullet.h"
#import "HGUtil.h"

typedef HGActor base;

HGBullet::HGBullet()
{
    base();
    base::useLight = false;
    color.r = 1.0; color.g = 1.0; color.b = 1.0; color.a = 1.0;
    blend1 = GL_ALPHA;
    blend2 = GL_ALPHA;
}

void HGBullet::init(BULLET_TYPE type)
{
    // オブジェクトの種類別の関数を設定
#warning テーブル化
    pDrawFunc = &HGBullet::N1Draw;
    pInitFunc = &HGBullet::N1Init;
    
    // 初期化
    (this->*pInitFunc)();
}

void HGBullet::draw()
{
    // 関数ポインタを呼び出す
    (this->*pDrawFunc)();
}


// ==================================================
// 種類別の関数
// ==================================================

void HGBullet::N1Draw()
{
    if (drawCounter % 10 <= 5)
    {
        s_draw1.scale.x = scale.x + 0.8;
        s_draw1.scale.y = scale.x + 0.8;
        s_draw1.scale.z = scale.x + 0.8;
    }
    else
    {
        s_draw1.scale.x = scale.x + 1.0;
        s_draw1.scale.y = scale.x + 1.0;
        s_draw1.scale.z = scale.x + 1.0;
    }
    s_draw1.position = position;
    HGActor::draw(&s_draw1);
    
    s_draw2.position = position;
    HGActor::draw(&s_draw2);
}

void HGBullet::N1Init()
{
    s_draw1.texture = textureTable["star.png"];
    s_draw1.position = position;
    s_draw1.scale = scale;
    s_draw1.scale.x += 0.8;
    s_draw1.scale.y += 0.8;
    s_draw1.scale.z += 0.8;
    s_draw1.alpha = 0.8;
    s_draw1.color = {0.5, 0.5, 1.0, 1.0};
    s_draw1.isAlphaMap = true;
    s_draw1.blend1 = GL_ALPHA;
    s_draw1.blend2 = GL_ALPHA;
    
    s_draw2.texture = textureTable["divine.png"];
    s_draw2.position = position;
    s_draw2.scale = scale;
    s_draw2.alpha = 1;
    s_draw2.color = {1,1,1,1};
    s_draw2.isAlphaMap = true;
    s_draw2.blend1 = GL_ALPHA;
    s_draw2.blend2 = GL_ALPHA;
}



