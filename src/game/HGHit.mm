#import "HGActor.h"
#import "HGHit.h"
#import "HGUtil.h"
#import "HGCommon.h"
#import "HGGame.h"

#define HIT_TYPE_1 1

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
        float r = rand(300, 400);
        initActor(*this, {r, r}, -1);
        updateCount = 0;
        isTextureInit = false;
        double rotateZ = rand(0, 360);
        rotate.z = rotateZ * M_PI/180;
    }
    
    void HGHit::draw()
    {
        if (!isTextureInit)
        {
            bomb = (*hgles::HGLTexture::createTextureWithAsset("corona.png"));
            bomb.color = {1.0, 1.0, 1.0, 1.0};
            bomb.isAlphaMap = 1;
            bomb.blend1 = GL_ALPHA;
            bomb.blend2 = GL_ALPHA;
            
            glow = *hgles::HGLTexture::createTextureWithAsset("star.png");
            glow.color = {1.0, 1.0, 1, 1};
            glow.isAlphaMap = 1;
            glow.blend1 = GL_ALPHA;
            glow.blend2 = GL_ALPHA;
            
            isTextureInit = true;
        }
        int index = updateCount;
        if (index <= 3)
        {
            scale.multiply(1.5);
        }
        else
        {
            scale.multiply(0.6);
            if (scale.x <= 0.70)
            {
                isActive = false;
                return;
            }
        }
        rotate.z += 0.1;
        
        glowScale = scale;
        glowScale.multiply(0.8);
        hgles::HGLGraphics2D::draw(&position, &glowScale, &rotate, &glow);
        
        
        hgles::HGLGraphics2D::draw(&position, &scale, &rotate, &bomb);
        
    }

    

}

