#import "HGActor.h"
#import "HGExplode.h"
#import "HGUtil.h"
#import "HGCommon.h"
#import "HGGame.h"

namespace HGGame {

    namespace actor {
        
        typedef HGActor base;
    
    void HGExplode::update()
    {
        base::update();
        updateCount++;
    }
    
    HGExplode::HGExplode()
    {
    }
    
    HGExplode::~HGExplode()
    {
        
    }
    
    void HGExplode::init()
    {
        base::init();
        t_size2d size;
        int r = rand(128, 160);
        size.w = r;
        size.h = r;
        int hitbox_id = -1;
        initActor(*this, size, hitbox_id);
        updateCount = 0;
        isTextureInit = false;
    }
    
    void HGExplode::draw()
    {
        if (!isTextureInit)
        {
            bomb = (*hgles::HGLTexture::createTextureWithAsset("explode_small.png"));
            bomb.sprWidth = 64;
            bomb.sprHeight = 64;
            
            glow = *hgles::HGLTexture::createTextureWithAsset("star.png");
            glow.color = {1.0, 1.0, 1.0, 0.5};
            glow.isAlphaMap = 1;
            glow.blend1 = GL_ALPHA;
            glow.blend2 = GL_ALPHA;
            
            glowScale = scale;
            glowScale.add(1.6);
            
            isTextureInit = true;
        }
        int index = updateCount / 2;
        if (index >= 9)
        {
#warning 仮
            return;
        }
        
        int x = bomb.sprWidth * index;
        bomb.setTextureArea(x, 0, bomb.sprWidth, bomb.sprWidth);
        hgles::HGLGraphics2D::draw(&position, &scale, &rotate, &bomb);
        
        glowScale.multiply(0.7);
        hgles::HGLGraphics2D::draw(&position, &glowScale, &rotate, &glow);
        
    }
    
    }

}

