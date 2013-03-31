#import "HGActor.h"
#import "HGBullet.h"
#import "HGUtil.h"
#import "HGCommon.h"
#import "HGGame.h"

namespace HGGame {

    typedef HGActor base;
    
    void HGBullet::update()
    {
        base::update();
        updateCount++;
        
        // フィールド外チェック
        t_size2d* field_size = get_size_of_field();
        if (position.x > field_size->w + field_size->w/4)
        {
            isActive = false;
        }
        if (position.y > field_size->h + field_size->h/4)
        {
            isActive = false;
        }
        if (position.x < -field_size->h/4)
        {
            isActive = false;
        }
        if (position.y < -field_size->h/4)
        {
            isActive = false;
        }
        
        double rest = range - (getNowTime() - shotTime);
        if (rest <= 0.1)
        {
            scale.multiply(0.1);
            if (rest <= 0)
            {
                isActive = false;
            }
        }
    }
    
    HGBullet::HGBullet()
    {
    }
    
    HGBullet::~HGBullet()
    {
        
    }
    
    void HGBullet::init(HG_BULLET_TYPE type, WHICH_SIDE side, int power)
    {
        this->shotTime = getNowTime();
        this->type = type;
        this->side = side;
        isTextureInit = false;
        updateCount = 0;
        this->power = power;
        switch (type) {
            case HG_BULLET_N1:
                initActor(*this, {12,12}, 1);
                scale.set(0.5, 0.5, 0.5);
                break;
            default:
                assert(0);
        }
    }
    
    void HGBullet::draw()
    {
        switch (type) {
            case HG_BULLET_N1:
            {
                if (!isTextureInit)
                {
                    core = *hgles::HGLTexture::createTextureWithAsset("divine.png");
                    core.color = {1,1,1,1};
                    core.isAlphaMap = 1;
                    core.blend1 = GL_ALPHA;
                    core.blend2 = GL_ALPHA;
                    
                    glow = *hgles::HGLTexture::createTextureWithAsset("star.png");
                    if (side == FRIEND_SIDE)
                    {
                        glow.color = {0.7, 0.7, 1.0, 0.5};
                    }
                    else
                    {
                        glow.color = {1.0, 0.7, 0.7, 0.5};
                    }
                    glow.isAlphaMap = 1;
                    glow.blend1 = GL_ALPHA;
                    glow.blend2 = GL_ALPHA;
                }
                hgles::HGLVector3 glowScale = scale;
                glowScale.add(1.5);
                hgles::HGLGraphics2D::draw(&position, &glowScale, &rotate, &glow);
                hgles::HGLGraphics2D::draw(&position, &scale, &rotate, &core);
                break;
            }
            default:
                assert(0);
        }
        isTextureInit = true;
    }
    
    

}

