#import "HGActor.h"
#import "HGObject.h"

typedef HGActor base;

HGObject::HGObject()
{
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
    s_draw1.position = position;
    s_draw1.scale = scale;
    HGActor::draw(&s_draw1);
}

void HGObject::Space1Init()
{
    s_draw1.object3D = object3DTable["rect"];
    s_draw1.texture = textureTable["space.png"];
    s_draw1.textureRepeatNum = 10;
    s_draw1.lookToCamera = false;
}





