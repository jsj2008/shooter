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
    //{&HGBullet::N2Init, &HGBullet::N2Draw},
};

void HGBullet::update()
{
    base::update();
}

HGBullet::HGBullet()
{
    color.r = 1.0; color.g = 1.0; color.b = 1.0; color.a = 1.0;
}

void HGBullet::init(HG_BULLET_TYPE type)
{
    // オブジェクトの種類別の関数を設定
#warning テーブル化
    base::setSize(64, 64);
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
    if (updateCount % 10 <= 5)
    {
        anime1.scale.x = scale.x + 0.8;
        anime1.scale.y = scale.x + 0.8;
        anime1.scale.z = scale.x + 0.8;
    }
    else
    {
        anime1.scale.x = scale.x + 1.0;
        anime1.scale.y = scale.x + 1.0;
        anime1.scale.z = scale.x + 1.0;
    }
    anime1.position = position;
    HGLGraphics2D::draw(&anime1);
    //base::draw(&anime1);
    
    anime2.position = position;
    HGLGraphics2D::draw(&anime2);
    //base::draw(&anime2);
}

void HGBullet::N1Init()
{
    base::setActorInfo(HG_TYPE_WEAPON1);
    //base::setSize(12, 12);
    
    setVelocity(0.3);
    scale.set(0.3, 0.3, 0.3);
    color = {1.0, 1.0, 1.0};
    
    /*
    if (anime1.texture)
    {
        //delete anime1.texture; anime1.texture = NULL;
    }*/
    anime1.texture = (*HGLTexture::createTextureWithAsset("star.png"));
    anime1.position = position;
    anime1.scale = scale;
    anime1.alpha = 0.8;
    anime1.texture.color = {0.5, 0.5, 1.0, 1.0};
    anime1.texture.isAlphaMap = 1;
    anime1.texture.blend1 = GL_ALPHA;
    anime1.texture.blend2 = GL_ALPHA;
    
    /*
    if (anime2.texture)
    {
        //delete anime2.texture; anime2.texture = NULL;
    }*/
    anime2.texture = *HGLTexture::createTextureWithAsset("divine.png");
    anime2.position = position;
    anime2.scale = scale;
    anime2.alpha = 1;
    anime2.texture.color = {1,1,1,1};
    anime2.texture.isAlphaMap = 1;
    anime2.texture.blend1 = GL_ALPHA;
    anime2.texture.blend2 = GL_ALPHA;
}

/*
void HGBullet::N2Draw()
{
    anime2.rotate.z += 0.45;
    anime3.rotate.z += 0.45;
    
    anime1.position = position;
    HGActor::draw(&anime1);
    
    anime2.position = position;
    HGActor::draw(&anime2);
    
    anime3.position = position;
    HGActor::draw(&anime3);
}

void HGBullet::N2Init()
{
    setVelocity(1.7);
    scale.set(1.2, 1.2, 1.2);
    color = {1.0, 1.0, 1.0};
    
    anime1.texture = textureTable["star.png"];
    anime1.object3D = object3DTable["rect"];
    anime1.position = position;
    anime1.scale = scale;
    anime1.scale.x -= 0.1;
    anime1.scale.y -= 0.1;
    anime1.scale.z -= 0.1;
    anime1.alpha = 0.7;
    anime1.color = {0.9, 0.7, 0.7, 1.0};
    anime1.isAlphaMap = true;
    anime1.blend1 = GL_ALPHA;
    anime1.blend2 = GL_ALPHA;
    
    anime2.texture = textureTable["x6.png"];
    anime2.object3D = object3DTable["rect"];
    anime2.position = position;
    anime2.scale = scale;
    anime2.alpha = 1;
    anime2.color = {1.0, 0.0, 0.0, 1.0};
    anime2.isAlphaMap = true;
    anime2.blend1 = GL_ALPHA;
    anime2.blend2 = GL_ALPHA;
    
    anime3.texture = textureTable["x6.png"];
    anime3.object3D = object3DTable["rect"];
    anime3.position = position;
    anime3.scale = scale;
    anime3.scale.x -= 0.05;
    anime3.scale.y -= 0.05;
    anime3.scale.z -= 0.05;
    anime3.alpha = 1;
    anime3.color = {1.0, 0.9, 0.9, 1.0};
    anime3.isAlphaMap = true;
    anime3.blend1 = GL_ALPHA;
    anime3.blend2 = GL_ONE;
}*/


