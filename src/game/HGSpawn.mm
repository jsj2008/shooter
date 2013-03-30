#import "HGActor.h"
#import "HGSpawn.h"
#import "HGUtil.h"
#import "HGCommon.h"
#import "HGGame.h"

namespace HGGame {

    typedef HGActor base;
    
    void HGSpawn::update()
    {
        base::update();
        updateCount++;
    }
    
    HGSpawn::HGSpawn()
    {
    }
    
    HGSpawn::~HGSpawn()
    {
        
    }
    
    void HGSpawn::init(HG_FIGHTER_TYPE type)
    {
        float r = rand(80, 120);
        initActor(*this, {r, r}, -1);
        updateCount = 0;
        isTextureInit = false;
        double rotateZ = rand(0, 360);
        rotate.z = rotateZ * M_PI/180;
        this->type = type;
        created = false;
    }
    
    void HGSpawn::draw()
    {
        if (!isTextureInit)
        {
            bomb = (*hgles::HGLTexture::createTextureWithAsset("nova.png"));
            bomb.color = {1.0, 1.0, 1.0, 1.0};
            bomb.isAlphaMap = 1;
            bomb.blend1 = GL_ALPHA;
            bomb.blend2 = GL_ALPHA;
            
            glow = *hgles::HGLTexture::createTextureWithAsset("wave2.png");
            glow.color = {0.4, 0.4, 1, 1};
            glow.isAlphaMap = 1;
            glow.blend1 = GL_ALPHA;
            glow.blend2 = GL_ALPHA;
            glowScale = scale;
            
            star = *hgles::HGLTexture::createTextureWithAsset("star.png");
            star.color = {1.0, 1.0, 1, 1};
            star.isAlphaMap = 1;
            star.blend1 = GL_ALPHA;
            star.blend2 = GL_ALPHA;
            starScale = scale;
            
            isTextureInit = true;
        }
        int index = updateCount/3;
        if (index < 3)
        {
            scale.multiply(1.2);
            starScale.multiply(1.2);
        }
        else
        {
            scale.multiply(0.8);
            starScale.multiply(0.7);
            star.color.a *= 0.8;
            if (scale.x <= 0.70 && index > 10)
            {
                isActive = false;
                return;
            }
        }
        if (index == 5 && !created)
        {
            createEnemy(type, position.x, position.y);
            created = true;
        }
        rotate.z += 0.1;
        glowScale = scale;
        glowScale.multiply(1.7);
        glow.color.a *= 0.7;
        
        hgles::HGLGraphics2D::draw(&position, &starScale, &rotate, &star);
        hgles::HGLGraphics2D::draw(&position, &glowScale, &rotate, &glow);
        hgles::HGLGraphics2D::draw(&position, &scale, &rotate, &bomb);
        
    }

    

}

