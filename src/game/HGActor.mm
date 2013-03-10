#import "HGActor.h"
#import "HGLMesh.h"
#import "HGLMaterial.h"
#import "HGLObjLoader.h"
#import "HGLGraphics2D.h"
#import "HGCommon.h"
#import <set>
#import <string>

using namespace std;

namespace HGGame {
    
    // あたり判定用矩形リスト
    typedef struct t_hitbox
    {
        int hitbox_id;
        t_rect hitbox;
    } t_hitbox;
    
    static t_hitbox _HITBOX_LIST[] = {
        {0, {20, 20, 24, 24}},
        {1, {-6, -6, 24, 24}},
    };
    
    static hgles::t_hgl2di square; // 矩形描画用
    
    void HGActor::initialize()
    {
        
        square = hgles::t_hgl2di();
        square.texture = (*hgles::HGLTexture::createTextureWithAsset("square.png"));
        square.texture.isAlphaMap = 1;
        square.texture.blend1 = GL_ALPHA;
        square.texture.blend2 = GL_ALPHA;
        
        // あたり判定
        {
            int len = (sizeof(_HITBOX_LIST)/sizeof(t_hitbox));
            int hitbox_id = _HITBOX_LIST[0].hitbox_id;
            t_hitboxes tmp_hitboxes;
            for (int i = 0; i < len; ++i)
            {
                t_hitbox t = _HITBOX_LIST[i];
                if (t.hitbox_id != hitbox_id)
                {
                    HITBOX_LIST.push_back(tmp_hitboxes);
                    tmp_hitboxes.clear();
                }
                t_rect r = t.hitbox;
                r.x *= SCRATE;
                r.y *= SCRATE;
                r.w *= SCRATE;
                r.h *= SCRATE;
                tmp_hitboxes.push_back(r);
            }
            HITBOX_LIST.push_back(tmp_hitboxes);
        }
        
        // 画像ロード
        hgles::HGLTexture::createTextureWithAsset("e_robo2.png");
        hgles::HGLTexture::createTextureWithAsset("divine.png");
        hgles::HGLTexture::createTextureWithAsset("space.png");
        hgles::HGLTexture::createTextureWithAsset("space2.png");
        hgles::HGLTexture::createTextureWithAsset("star.png");
        hgles::HGLTexture::createTextureWithAsset("x6.png");
        hgles::HGLTexture::createTextureWithAsset("square.png");
        hgles::HGLTexture::createTextureWithAsset("galaxy-X.png");
        hgles::HGLTexture::createTextureWithAsset("galaxy-Y.png");
        hgles::HGLTexture::createTextureWithAsset("galaxy-Z.png");
        hgles::HGLTexture::createTextureWithAsset("galaxy+X.png");
        hgles::HGLTexture::createTextureWithAsset("galaxy+Y.png");
        hgles::HGLTexture::createTextureWithAsset("galaxy+Z.png");
        
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
    
    void HGActor::setAspect(float degree)
    {
        aspect = degree;
        radian = degree * M_PI / 180;
    }
    
    void HGActor::setMoveAspect(float degree)
    {
        moveAspect = degree * M_PI / 180;
    }
    
    bool HGActor::isCollideWith(HGActor* another)
    {
        if (this->hitbox_id == -1) return false;
        if (another->hitbox_id == -1) return false;
        t_hitboxes* list1 = &HITBOX_LIST[this->hitbox_id];
        t_hitboxes* list2 = &HITBOX_LIST[another->hitbox_id];
        int size1 = list1->size();
        int size2 = list2->size();
        hgles::HGLVector3* p1 = &position;
        hgles::HGLVector3* p2 = &another->position;
        float offx1 = p1->x - this->realSize.w/2;
        float offy1 = p1->y - this->realSize.h/2;
        float offx2 = p2->x - another->realSize.w/2;
        float offy2 = p2->y - another->realSize.h/2;
        for (int i = 0; i < size1; ++i)
        {
            t_rect* r1 = &((*list1)[i]);
            for (int j = 0; j < size2; ++j)
            {
                t_rect* r2 = &((*list2)[j]);
                if (offx1 + r1->x <= offx2 + r2->x + r2->w
                    && offx2 + r2->x <= offx1 + r1->x + r1->w
                    && offy1 + r1->y <= offy2 + r2->y + r2->h
                    && offy2 + r2->y <= offy1 + r1->y + r1->h)
                {
                    return true;
                }
            }
        }
        return false;
    }
    
    void HGActor::drawCollision()
    {
        if (this->hitbox_id == -1) return;
        t_hitboxes* list1 = &HITBOX_LIST[this->hitbox_id];
        if (list1 == NULL)return;
        square.texture.color = {1,0,0,0.5};
        hgles::HGLVector3* p1 = &position;
        float offx1 = p1->x - this->realSize.w/2;
        float offy1 = p1->y - this->realSize.h/2;
        square.rotate = this->rotate;
        int size1 = list1->size();
        for (int i = 0; i < size1; ++i)
        {
            t_rect* r1 = &((*list1)[i]);
            square.position.x = offx1 + r1->x + r1->w/2;
            square.position.y = offy1 + r1->y + r1->h/2;
            square.position.z = this->position.z;
            square.scale.set(r1->w, r1->h, 1);
            hgles::HGLGraphics2D::draw(&square);
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
    
    void HGActor::initHitbox(int hitbox_id)
    {
        this->hitbox_id = hitbox_id;
    }
    
    void HGActor::initSize(t_size2d &size)
    {
        this->size.w = size.w;
        this->size.h = size.h;
        this->realSize.w = size.w*SCRATE;
        this->realSize.h = size.h*SCRATE;
        this->hitbox_id = hitbox_id;
        this->scale.set(size.w*SCRATE, size.h*SCRATE, 1);
    }
    
    void initActor(HGActor& actor, t_size2d &size, int &hitbox_id)
    {
        actor.initSize(size);
        actor.initHitbox(hitbox_id);
    }
    
}
