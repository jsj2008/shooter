#import "HGActor.h"
#import "HGHitAnime.h"
#import "HGUtil.h"
#import "HGCommon.h"
#import "HGGame.h"

#define HIT_TYPE_1 1

namespace HGGame {

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
        float r = rand(300, 400);
        initActor(*this, {r, r}, -1);
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
#warning 見方と敵で色をかえる
            if (rand(0, 1) == 0)
            {
            bomb.blendColor = {0.8,1,1.5,1};
            }
            else
            {
            }
            sprSize = {64,64};
            isTextureInit = true;
        }
        int index = updateCount;
        if (index >= 8)
        {
            isActive = false;
            return;
        }
        if (index >= 5)
        {
            bomb.color.a *= 0.5;
        }
        int x = sprSize.w * index;
        bomb.setTextureArea(x, 0, sprSize.w, sprSize.h);
        hgles::HGLGraphics2D::draw(&position, &scale, &rotate, &bomb);
        
    }

    

}

