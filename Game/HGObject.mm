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
    HGLGraphics2D::draw(&anime1);
}

void HGObject::Space1Init()
{
    if (anime1.texture)
    {
        delete anime1.texture; anime1.texture = NULL;
    }
    anime1.texture = HGLTexture::createTextureWithAsset("space.png");
    anime1.texture->repeatNum = 10;
    anime1.paralell = 0;
}





