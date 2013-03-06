#import "HGLGraphics2D.h"

enum HG_OBJECT_TYPE {
    HG_OBJECT_SPACE1,
    HG_OBJECT_SPACE2,
};

class HGActor;
class HGObject : public HGActor
{
public:
    HGObject();
    void draw();
    void init(HG_OBJECT_TYPE type);
    void update();
    
    // 描画用関数
    void (HGObject::*pDrawFunc)();
    
    // 初期化用関数
    void (HGObject::*pInitFunc)();
    
    // 種類別関数群
    void Space1Draw();
    void Space1Init();
    
    t_hgl2d anime1;
    t_hgl2d anime2;
    
};
