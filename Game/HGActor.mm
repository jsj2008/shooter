#import "HGActor.h"
#import "HGLMesh.h"
#import "HGLMaterial.h"
#import "HGLObjLoader.h"
#import <map>
#import <string>

using namespace std;

#warning 後で移すと思う
std::map<std::string, HGLObject3D*> HGActor::object3dTable;
std::map<std::string, HGLTexture*> HGActor::textureTable;
void HGLoadData()
{
    HGActor::object3dTable["rect"] = HGLObjLoader::load(@"rect");
    HGActor::textureTable["e_robo2.png"] = HGLTexture::createTextureWithAsset("e_robo2.png");
    HGActor::textureTable["divine.png"] = HGLTexture::createTextureWithAsset("divine.png");
    HGActor::textureTable["space.png"] = HGLTexture::createTextureWithAsset("space.png");
    HGActor::textureTable["star.png"] = HGLTexture::createTextureWithAsset("star.png");
}

HGActor::~HGActor()
{
    if (object3d)
    {
        delete object3d;
    }
}

// サブクラスから呼ばれる
void HGActor::draw(t_draw* p)
{
    drawCounter++;
    
    object3d->useLight = false; // 2Dのため
    object3d->position = p->position;
    object3d->rotate = p->rotate;
    object3d->scale = p->scale;
    object3d->alpha = p->alpha;
    object3d->looktoCamera = p->lookToCamera;
    
    // テクスチャ設定
    HGLTexture* t = p->texture;
    t->setTextureMatrix(p->textureMatrix);
    t->isAlphaMap = p->isAlphaMap;
    t->color = p->color;
    t->repeatNum = textureRepeatNum; // とりあえずオブジェクト単位
    
    // 合成方法指定
    t->blend1 = p->blend1;
    t->blend2 = p->blend2;
    
    HGLMesh* mesh = object3d->getMesh(0);
    assert(mesh->texture == NULL);
    mesh->texture = t;
    
    // 描画
    object3d->draw();
    mesh->texture = NULL;
}

void HGActor::draw()
{
    object3d->useLight = useLight;
    object3d->position = position;
    object3d->rotate = rotate;
    object3d->scale = scale;
    object3d->alpha = alpha;
    object3d->looktoCamera = lookToCamera;
    if (texture)
    {
        // テクスチャ設定
        HGLMesh* mesh = object3d->getMesh(0);
        assert(mesh->texture == NULL);
        mesh->texture = texture;
        texture->setTextureMatrix(textureMatrix);
        texture->repeatNum = textureRepeatNum;
        
        // 合成方法指定
        texture->blend1 = blend1;
        texture->blend2 = blend2;
        
        // 描画
        object3d->draw();
        mesh->texture = NULL;
    }
    else
    {
        object3d->draw();
    }
}

void HGActor::setObject3D(HGLObject3D* obj, HGLTexture* tex)
{
    object3d = obj;
    HGLMesh* mesh = object3d->getMesh(0);
    // textureが指定されている場合
    if (tex)
    {
        texture = tex;
        assert(mesh->texture == NULL);
    }
    else
    {
        texture = mesh->texture;
    }
    textureMatrix = GLKMatrix4Identity;
}

void HGActor::setObject3D(HGLObject3D* obj)
{
    setObject3D(obj, NULL);
}

void HGActor::setVelocity(float inVelocity)
{
    velocity = inVelocity;
    acceleration.set(
        cos(moveAspect) * velocity,
        sin(moveAspect) * velocity * -1, // 上下逆に
        0
    );
}

void HGActor::setTextureArea(int x, int y, int w, int h)
{
    if (texture)
    {
        textureMatrix = texture->getTextureMatrix(x, y, w, h);
    }
}

void HGActor::setAspect(float degree)
{
    aspect = degree * M_PI / 180;
}

void HGActor::setMoveAspect(float degree)
{
    moveAspect = degree * M_PI / 180;
}

void HGActor::move()
{
    if (velocity)
    {
        position.x += acceleration.x;
        position.y += acceleration.y;
        position.z += acceleration.z;
    }
}
