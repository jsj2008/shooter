#import "HGActor.h"
#import "HGLMesh.h"
#import "HGLMaterial.h"
#import "HGLObjLoader.h"
#import "HGLGraphics2D.h"
#import "HGCommon.h"
#import "HGCollision.h"
#import <set>
#import <string>

using namespace std;

namespace HGGame {
    
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
        return isIntersect(&position, &realSize, hitbox_id, &another->position, &another->realSize, another->hitbox_id);
    }
    
    void HGActor::drawCollision()
    {
        drawHitbox(&this->position, &this->realSize, this->hitbox_id, &this->rotate);
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
    
    void initializeGame()
    {
        initializeCollision();
        
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
    
}
