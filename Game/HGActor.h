#import "HGLObject3D.h"
#import "HGLVector3.h"
#import "HGLTexture.h"
#import "HGLGraphics2D.h"
#import <vector>
#import <string>

// anime table
enum HG_TYPE_ACTOR {
    HG_TYPE_E_ROBO1,
    HG_TYPE_WEAPON1,
    HG_TYPE_MAX,
};

typedef struct t_hg_rect
{
    float x;
    float y;
    float width;
    float height;
    float realWidth;
    float realHeight;
} t_hg_rect;

typedef std::vector<t_hg_rect> t_hg_rectlist;

typedef struct t_hg_actorinf
{
    t_hg_actorinf():
    sprWidth(0),
    sprHeight(0)
    {}
    t_hg_rectlist rectlist;
    int sprWidth;
    int sprHeight;
    float realWidth;
    float realHeight;
} t_hg_actorinf;

typedef std::vector<t_hg_actorinf> t_hg_actorinf_list;

// 3dやテクスチャなどのデータを読み込む
#warning 後で適切な場所に移すことを検討
void HGLoadData();

class HGActor
{
public:
    HGActor():
        velocity(0),
        aspect(0),
        radian(0),
        moveAspect(0),
        scale(1,1,1),
        rotate(0,0,0),
        position(0,0,0),
        acceleration(0,0,0),
        updateCount(0)
        {}
    
    virtual void draw() = 0;
    void drawCollision();
    virtual void update();
    void setVelocity(float velocity);
    virtual void setAspect(float degree);
    void setMoveAspect(float degree);
    void setActorInfo(HG_TYPE_ACTOR t);
    bool isCollideWith(HGActor* another);
    
    ~HGActor();
    
    HGLVector3 position;
    HGLVector3 rotate;
    HGLVector3 scale;
    float velocity; // 速度
    float aspect; // degree
    float radian;
    float moveAspect; // radian
    unsigned int updateCount;
    t_hg_actorinf* info;
    
    float width;
    float height;
    
    void setSize(float width, float height);
    
    HGLVector3 acceleration; // 加速
    
    
};
