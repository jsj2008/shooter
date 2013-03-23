#import "HGActor.h"
#import "HGBullet.h"
#import "HGUtil.h"
#import "HGCommon.h"

namespace HGGame {
    namespace actor {
        
        typedef HGActor base;
        
        void HGBullet::update()
        {
            base::update();
            updateCount++;
        }
        
        HGBullet::HGBullet()
        {
        }
        
        HGBullet::~HGBullet()
        {
            
        }
        
        void HGBullet::init(HG_BULLET_TYPE type)
        {
            base::init();
            int hitbox_id = 0;
            t_size2d size;
            switch (type) {
                case HG_BULLET_N1:
                    hitbox_id = 1;
                    size.w = 12;
                    size.h = 12;
                    setVelocity(0.3);
                    scale.set(0.3, 0.3, 0.3);
                    break;
                default:
                    assert(0);
            }
            this->type = type;
            isTextureInit = false;
            initActor(*this, size, hitbox_id);
            updateCount = 0;
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
                        glow.color = {0.5, 0.5, 1.0, 0.8};
                        glow.isAlphaMap = 1;
                        glow.blend1 = GL_ALPHA;
                        glow.blend2 = GL_ALPHA;
                    }
                    hgles::HGLVector3 glowScale = scale;
                    if (updateCount % 4 <= 2)
                    {
                        glowScale.add(0.7);
                        glow.color.a = 0.5;
                    }
                    else
                    {
                        glowScale.add(0.6);
                        glow.color.a = 0.8;
                    }
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

}

