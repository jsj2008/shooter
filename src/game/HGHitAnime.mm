#import "HGActor.h"
#import "HGHitAnime.h"
#import "HGUtil.h"
#import "HGCommon.h"
#import "HGGame.h"

#define HIT_TYPE_1 1

namespace HGGame {
    namespace actor {
        
    typedef HGActor base;
    
    void HGHitAnime::update()
    {
        base::update();
        updateCount++;
    }
    
    HGHitAnime::HGHitAnime()
    {
    }
    
    HGHitAnime::~HGHitAnime()
    {
        
    }
    
    void HGHitAnime::init()
    {
        base::init();
        t_size2d size;
        int r = rand(80, 128);
        size.w = r;
        size.h = r;
        int hitbox_id = -1;
        initActor(*this, size, hitbox_id);
        updateCount = 0;
        isTextureInit = false;
        double rotateZ = rand(0, 360);
        rotate.z = rotateZ * M_PI/180;
    }
    
    void HGHitAnime::draw()
    {
        if (!isTextureInit)
        {
            bomb = (*hgles::HGLTexture::createTextureWithAsset("hit_small.png"));
            bomb.sprWidth = 64;
            bomb.sprHeight = 64;
            
            glow = *hgles::HGLTexture::createTextureWithAsset("star.png");
            glow.color = {1.0, 1.0, 1, 1};
            glow.isAlphaMap = 1;
            glow.blend1 = GL_ALPHA;
            glow.blend2 = GL_ALPHA;
            
            isTextureInit = true;
        }
        int index = updateCount;
        if (index >= 8)
        {
#warning 仮
            return;
        }
        if (index >= 5)
        {
            bomb.color.a *= 0.5;
        }
        int x = bomb.sprWidth * index;
        bomb.setTextureArea(x, 0, bomb.sprWidth, bomb.sprWidth);
        hgles::HGLGraphics2D::draw(&position, &scale, &rotate, &bomb);
        
        hgles::HGLGraphics2D::draw(&position, &glowScale, &rotate, &glow);
        
    }

    }

}

