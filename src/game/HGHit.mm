#import "HGActor.h"
#import "HGHit.h"
#import "HGUtil.h"
#import "HGCommon.h"
#import "HGGame.h"

namespace HGGame {

    typedef HGActor base;
    
    void HGHit::update()
    {
        base::update();
        updateCount++;
    }
    
    HGHit::HGHit()
    {
    }
    
    HGHit::~HGHit()
    {
        
    }
    
    void HGHit::init()
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
    
    void HGHit::draw()
    {
        if (!isTextureInit)
        {
            bomb = (*hgles::HGLTexture::createTextureWithAsset("hit_small.png"));
            bomb.sprWidth = 64;
            bomb.sprHeight = 64;
            
            glow = *hgles::HGLTexture::createTextureWithAsset("star.png");
            glow.color = {1.0, 1.0, 1.0, 0.01};
            glow.isAlphaMap = 1;
            glow.blend1 = GL_ALPHA;
            glow.blend2 = GL_ALPHA;
            
            glowScale = scale;
            glowScale.add(0.5);
            
            isTextureInit = true;
        }
        int index = updateCount;
        if (index >= 7)
        {
#warning 仮
            return;
        }
        
        int x = bomb.sprWidth * index;
        bomb.setTextureArea(x, 0, bomb.sprWidth, bomb.sprWidth);
        hgles::HGLGraphics2D::draw(&position, &scale, &bomb);
        
        if (updateCount%2)
        {
            glowScale.add(-0.05);
            glow.color.a = 0;
        }
        else
        {
            glowScale.add(0.05);
            glow.color.a = 0.25;
        }
        //hgles::HGLGraphics2D::draw(&position, &glowScale, &glow);
        
    }
    
    

}

