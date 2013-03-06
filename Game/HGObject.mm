#import "HGActor.h"
#import "HGObject.h"

typedef HGActor base;

HGObject::HGObject()
{
}

void HGObject::update()
{
    base::update();
}

typedef struct s_hg_object_type
{
    void (HGObject::*pInitFunc)();
    void (HGObject::*pDrawFunc)();
} t_hg_object_type;

t_hg_object_type hg_object_table[] =
{
    {&HGObject::Space1Init, &HGObject::Space1Draw},
    //{&HGBullet::N2Init, &HGBullet::N2Draw},
};

// 種類ごとに関数ポインタを設定
void HGObject::init(HG_OBJECT_TYPE type)
{
#warning テーブル化
    pDrawFunc = &HGObject::Space1Draw;
    pInitFunc = &HGObject::Space1Init;
    
    // 初期化
    (this->*pInitFunc)();
}

void HGObject::draw()
{
    (this->*pDrawFunc)();
}

// --------------------------------------------------
// 種類別
// --------------------------------------------------
void HGObject::Space1Draw()
{
    anime1.position = position;
    anime1.scale = scale;
    anime1.rotate = rotate;
    HGLGraphics2D::draw(&anime1);
    
}

void HGObject::Space1Init()
{
    anime1.texture = *HGLTexture::createTextureWithAsset("space.png");
    anime1.texture.repeatNum = 1;
    anime1.paralell = 0;
    anime1.alpha = 1;
    anime1.scale = scale;
    
}





