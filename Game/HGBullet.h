#import "HGLTypes.h"

enum HG_BULLET_TYPE {
    HG_BULLET_N1,
    HG_BULLET_N2
};

class HGActor;
class HGBullet : public HGActor
{
public:
    HGBullet();
    Color color;
    void draw();
    void update();
    void init(HG_BULLET_TYPE type);
    HGLTexture* blurTexture;
    
    // 描画用関数
    void (HGBullet::*pDrawFunc)();
    
    // 初期化用関数
    void (HGBullet::*pInitFunc)();
    
    // 種類別関数群
    void N1Draw();
    void N1Init();
    void N2Draw();
    void N2Init();
    
};
