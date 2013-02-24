#import "HGLTypes.h"

enum BULLET_TYPE {
    BULLET_N1
};

class HGActor;
class HGBullet : public HGActor
{
public:
    HGBullet();
    Color color;
    void draw();
    void init(BULLET_TYPE type);
    HGLTexture* blurTexture;
private:
    
    // 描画用関数
    void (HGBullet::*pDrawFunc)();
    
    // 初期化用関数
    void (HGBullet::*pInitFunc)();
    
    // 種類別関数群
    void N1Draw();
    void N1Init();
    
};
