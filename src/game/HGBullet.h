#import "HGLTypes.h"
#import "HGLGraphics2D.h"

namespace HGGame {
    
    enum HG_BULLET_TYPE {
        HG_BULLET_N1,
        HG_BULLET_N2
    };
    
    class HGActor;
    class HGBullet : public HGActor
    {
    public:
        HGBullet();
        ~HGBullet();
        void draw();
        void update();
        void init(HG_BULLET_TYPE type);
        hgles::HGLTexture* blurTexture;
        
        // 描画用関数
        void (HGBullet::*pDrawFunc)();
        
        // 初期化用関数
        void (HGBullet::*pInitFunc)();
        
        // 種類別関数群
        void N1Draw();
        void N2Draw();
        void N2Init();
        
    private:
        hgles::t_hgl2di anime1;
        hgles::t_hgl2di anime2;
        HG_BULLET_TYPE type;
        
        bool isTextureInit;
        hgles::HGLTexture core;
        hgles::HGLTexture glow;
        int updateCount;
    };
    
}
