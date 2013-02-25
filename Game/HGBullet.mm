#import "HGActor.h"
#import "HGBullet.h"
#import "HGUtil.h"

typedef HGActor base;

typedef struct s_hg_bullet_type
{
    void (HGBullet::*pInitFunc)();
    void (HGBullet::*pDrawFunc)();
} t_hg_bullet_type;

t_hg_bullet_type hg_bullet_table[] =
{
    {&HGBullet::N1Init, &HGBullet::N1Draw},
    {&HGBullet::N2Init, &HGBullet::N2Draw},
};

HGBullet::HGBullet()
{
    color.r = 1.0; color.g = 1.0; color.b = 1.0; color.a = 1.0;
}

void HGBullet::init(HG_BULLET_TYPE type)
{
    // オブジェクトの種類別の関数を設定
#warning テーブル化
    pInitFunc = hg_bullet_table[type].pInitFunc;
    pDrawFunc = hg_bullet_table[type].pDrawFunc;
    
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
    setVelocity(0.3);
    scale.set(0.3, 0.3, 0.3);
    color = {1.0, 1.0, 1.0};
    
    s_draw1.texture = textureTable["star.png"];
    s_draw1.object3D = object3DTable["rect"];
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
    s_draw2.object3D = object3DTable["rect"];
    s_draw2.position = position;
    s_draw2.scale = scale;
    s_draw2.alpha = 1;
    s_draw2.color = {1,1,1,1};
    s_draw2.isAlphaMap = true;
    s_draw2.blend1 = GL_ALPHA;
    s_draw2.blend2 = GL_ALPHA;
}

void HGBullet::N2Draw()
{
    s_draw2.rotate.z += 0.45;
    s_draw3.rotate.z += 0.45;
    
    s_draw1.position = position;
    HGActor::draw(&s_draw1);
    
    s_draw2.position = position;
    HGActor::draw(&s_draw2);
    
    s_draw3.position = position;
    HGActor::draw(&s_draw3);
}

void HGBullet::N2Init()
{
    setVelocity(1.7);
    scale.set(1.2, 1.2, 1.2);
    color = {1.0, 1.0, 1.0};
    
    s_draw1.texture = textureTable["star.png"];
    s_draw1.object3D = object3DTable["rect"];
    s_draw1.position = position;
    s_draw1.scale = scale;
    s_draw1.scale.x -= 0.1;
    s_draw1.scale.y -= 0.1;
    s_draw1.scale.z -= 0.1;
    s_draw1.alpha = 0.7;
    s_draw1.color = {0.9, 0.7, 0.7, 1.0};
    s_draw1.isAlphaMap = true;
    s_draw1.blend1 = GL_ALPHA;
    s_draw1.blend2 = GL_ALPHA;
    
    s_draw2.texture = textureTable["x6.png"];
    s_draw2.object3D = object3DTable["rect"];
    s_draw2.position = position;
    s_draw2.scale = scale;
    s_draw2.alpha = 1;
    s_draw2.color = {1.0, 0.0, 0.0, 1.0};
    s_draw2.isAlphaMap = true;
    s_draw2.blend1 = GL_ALPHA;
    s_draw2.blend2 = GL_ALPHA;
    
    s_draw3.texture = textureTable["x6.png"];
    s_draw3.object3D = object3DTable["rect"];
    s_draw3.position = position;
    s_draw3.scale = scale;
    s_draw3.scale.x -= 0.05;
    s_draw3.scale.y -= 0.05;
    s_draw3.scale.z -= 0.05;
    s_draw3.alpha = 1;
    s_draw3.color = {1.0, 0.9, 0.9, 1.0};
    s_draw3.isAlphaMap = true;
    s_draw3.blend1 = GL_ALPHA;
    s_draw3.blend2 = GL_ONE;
}


