#import "HGActor.h"
#import "HGLMesh.h"
#import "HGLMaterial.h"
#import "HGLObjLoader.h"
#import "HGLGraphics2D.h"
#import <set>
#import <string>

#define SCRATE 0.01

using namespace std;

#warning 改善
// あたり判定用矩形リスト
static t_hg_actorinf_list actor_inf_list;
static t_hgl2d square;

void HGLoadData()
{
    // 画像ロード
    HGLTexture::createTextureWithAsset("e_robo2.png");
    HGLTexture::createTextureWithAsset("divine.png");
    HGLTexture::createTextureWithAsset("space.png");
    HGLTexture::createTextureWithAsset("space2.png");
    HGLTexture::createTextureWithAsset("star.png");
    HGLTexture::createTextureWithAsset("x6.png");
    HGLTexture::createTextureWithAsset("square.png");
    HGLTexture::createTextureWithAsset("galaxy-X.png");
    HGLTexture::createTextureWithAsset("galaxy-Y.png");
    HGLTexture::createTextureWithAsset("galaxy-Z.png");
    HGLTexture::createTextureWithAsset("galaxy+X.png");
    HGLTexture::createTextureWithAsset("galaxy+Y.png");
    HGLTexture::createTextureWithAsset("galaxy+Z.png");
    
    // debug
    square = t_hgl2d();
    square.alpha = 0.5;
    square.texture = (*HGLTexture::createTextureWithAsset("square.png"));
    square.texture.isAlphaMap = 1;
    square.texture.blend1 = GL_ALPHA;
    square.texture.blend2 = GL_ALPHA;
    
    // 種類別の情報設定
    for (int i = 0; i < HG_TYPE_MAX; ++i)
    {
        t_hg_actorinf t;
        t_hg_rect* rects = NULL;
        switch (i)
        {
            case HG_TYPE_E_ROBO1:
                t.sprWidth = 64;
                t.sprHeight = 64;
                rects = new t_hg_rect[1]{{20, 20, 24, 24}};
                break;
            case HG_TYPE_WEAPON1:
                t.sprWidth = 12;
                t.sprHeight = 12;
                rects = new t_hg_rect[1]{{-6, -6, 24, 24}};
                break;
            default:
                break;
        }
        if (rects != NULL)
        {
            int len = sizeof(*rects) / sizeof(t_hg_rect);
            for (int i = 0; i < len; i++)
            {
                rects[i].x *= SCRATE;
                rects[i].y *= SCRATE;
                rects[i].realWidth = rects[i].width * SCRATE;
                rects[i].realHeight = rects[i].height * SCRATE;
                t.rectlist.push_back(rects[i]);
            }
            delete[] rects;
        }
        t.realWidth = t.sprWidth * SCRATE;
        t.realHeight = t.sprHeight * SCRATE;
        actor_inf_list.push_back(t);
    }
}

HGActor::~HGActor()
{
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

void HGActor::setSize(float width, float height)
{
    this->width = width;
    this->height = height;
    scale.set(width*SCRATE, height*SCRATE, 1);
}

void HGActor::setAspect(float degree)
{
    aspect = degree;
    radian = degree * M_PI / 180;
}

void HGActor::setMoveAspect(float degree)
{
    moveAspect = degree * M_PI / 180;
}

void HGActor::setActorInfo(HG_TYPE_ACTOR t)
{
    info = &actor_inf_list[t];
    setSize(info->sprWidth, info->sprHeight);
}

bool HGActor::isCollideWith(HGActor* another)
{
    t_hg_rectlist* list1 = &this->info->rectlist;
    t_hg_rectlist* list2 = &another->info->rectlist;
    if (list1 == NULL || list2 == NULL) return false;
    int size1 = list1->size();
    int size2 = list1->size();
    HGLVector3* p1 = &position;
    HGLVector3* p2 = &another->position;
    float offx1 = p1->x - this->info->realWidth/2;
    float offy1 = p1->y - this->info->realHeight/2;
    float offx2 = p2->x - another->info->realWidth/2;
    float offy2 = p2->y - another->info->realHeight/2;
    for (int i = 0; i < size1; ++i)
    {
        t_hg_rect* r1 = &((*list1)[i]);
        for (int j = 0; j < size2; ++j)
        {
            t_hg_rect* r2 = &((*list2)[j]);
            if (offx1 + r1->x <= offx2 + r2->x + r2->realWidth
                && offx2 + r2->x <= offx1 + r1->x + r1->realWidth
                && offy1 + r1->y <= offy2 + r2->y + r2->realHeight
                && offy2 + r2->y <= offy1 + r1->y + r1->realHeight
            )
            {
                return true;
            }
        }
    }
    return false;
}

void HGActor::drawCollision()
{
    if (this->info == NULL)return;
    t_hg_rectlist* list1 = &this->info->rectlist;
    if (list1 == NULL) return;
    
    square.texture.color = {1,0,0,0.5};
    HGLVector3* p1 = &position;
    float offx1 = p1->x - this->info->realWidth/2;
    float offy1 = p1->y - this->info->realHeight/2;
    square.rotate = this->rotate;
    int size1 = list1->size();
    for (int i = 0; i < size1; ++i)
    {
        t_hg_rect* r1 = &((*list1)[i]);
        square.position.x = offx1 + r1->x + r1->realWidth/2;
        square.position.y = offy1 + r1->y + r1->realHeight/2;
        square.position.z = this->position.z;
        square.scale.set(r1->width*SCRATE, r1->height*SCRATE, 1);
        HGLGraphics2D::draw(&square);
    }
}

void HGActor::update()
{
    updateCount++;
    if (velocity)
    {
        position.x += acceleration.x;
        position.y += acceleration.y;
        position.z += acceleration.z;
    }
}
