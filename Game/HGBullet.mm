#import "HGActor.h"
#import "HGBullet.h"
#import "HGUtil.h"
#import "HGCommon.h"

namespace HGGame {

    typedef HGActor base;
    
    typedef struct s_hg_bullet_type
    {
        void (HGBullet::*pInitFunc)();
        void (HGBullet::*pDrawFunc)();
    } t_hg_bullet_type;
    
    t_hg_bullet_type hg_bullet_table[] =
    {
        {&HGBullet::N1Init, &HGBullet::N1Draw},
        //{&HGBullet::N2Init, &HGBullet::N2Draw},
    };
    
    void HGBullet::update()
    {
        base::update();
    }
    
    HGBullet::HGBullet()
    {
        color.r = 1.0; color.g = 1.0; color.b = 1.0; color.a = 1.0;
    }
    
    void HGBullet::init(HG_BULLET_TYPE type)
    {
        // オブジェクトの種類別の関数を設定
#warning テーブル化
        //base::setSize(64, 64);
        pInitFunc = hg_bullet_table[type].pInitFunc;
        pDrawFunc = hg_bullet_table[type].pDrawFunc;
        
        // 初期化
        (this->*pInitFunc)();
    }
    
    void HGBullet::draw()
    {
        // 関数ポインタを呼び出す
        (this->*pDrawFunc)();
    }
    
    
    // ==================================================
    // 種類別の関数
    // ==================================================
    
    void HGBullet::N1Draw()
    {
        if (updateCount % 4 <= 2)
        {
            anime1.scale.x = scale.x + 0.7;
            anime1.scale.y = scale.x + 0.7;
            anime1.scale.z = scale.x + 0.7;
            anime1.alpha = 0.5;
        }
        else
        {
            anime1.scale.x = scale.x + 0.6;
            anime1.scale.y = scale.x + 0.6;
            anime1.scale.z = scale.x + 0.6;
            anime1.alpha = 0.8;
        }
        anime1.position = position;
        HGLGraphics2D::draw(&anime1);
        
        anime2.position = position;
        HGLGraphics2D::draw(&anime2);
    }
    
    void HGBullet::N1Init()
    {
        int hitbox_id = 1;
        int w = 12;
        int h = 12;
        
        //setSize(w, h);
        this->size.w = w;
        this->size.h = h;
        this->realSize.w = w*SCRATE;
        this->realSize.h = h*SCRATE;
        this->hitbox_id = hitbox_id;
        this->scale.set(w*SCRATE, h*SCRATE, 1);
        
        setVelocity(0.3);
        scale.set(0.3, 0.3, 0.3);
        color = {1.0, 1.0, 1.0};
        
        anime1.texture = (*HGLTexture::createTextureWithAsset("star.png"));
        anime1.position = position;
        anime1.scale = scale;
        anime1.alpha = 0.8;
        anime1.texture.color = {0.5, 0.5, 1.0, 1.0};
        anime1.texture.isAlphaMap = 1;
        anime1.texture.blend1 = GL_ALPHA;
        anime1.texture.blend2 = GL_ALPHA;
        
        anime2.texture = *HGLTexture::createTextureWithAsset("divine.png");
        anime2.position = position;
        anime2.scale = scale;
        anime2.alpha = 1;
        anime2.texture.color = {1,1,1,1};
        anime2.texture.isAlphaMap = 1;
        anime2.texture.blend1 = GL_ALPHA;
        anime2.texture.blend2 = GL_ALPHA;
    }
    

}

