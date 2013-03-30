#import "HGActor.h"
#import "HGExplode.h"
#import "HGUtil.h"
#import "HGCommon.h"
#import "HGGame.h"

namespace HGGame {

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
        float r = rand(150, 200);
        initActor(*this, {r, r}, -1);
        updateCount = 0;
        isTextureInit = false;
        double rotateZ = rand(0, 360);
        rotate.z = rotateZ * M_PI/180;
    }
    
    void HGExplode::draw()
    {
        if (!isTextureInit)
        {
            bomb = (*hgles::HGLTexture::createTextureWithAsset("explode_small.png"));
            sprSize = {64,64};
            
            glow = *hgles::HGLTexture::createTextureWithAsset("star.png");
            glow.color = {1.0, 1.0, 1.0, 0.5};
            glow.isAlphaMap = 1;
            glow.blend1 = GL_ALPHA;
            glow.blend2 = GL_ALPHA;
            
            glowScale = scale;
            glowScale.add(3.6);
            
            isTextureInit = true;
        }
        int index = updateCount / 2;
        if (index >= 9)
        {
            isActive = false;
            return;
        }
        
        int x = sprSize.w * index;
        bomb.setTextureArea(x, 0, sprSize.w, sprSize.h);
        hgles::HGLGraphics2D::draw(&position, &scale, &rotate, &bomb);
        
        glowScale.multiply(0.7);
        hgles::HGLGraphics2D::draw(&position, &glowScale, &rotate, &glow);
        
    }
    
    

}

