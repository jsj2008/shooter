#import "HGLObject3D.h"
#import "HGLVector3.h"
#import "HGLTexture.h"
#import "HGLGraphics2D.h"
#import <vector>
#import <string>

namespace HGGame {
    
    typedef struct t_rect
    {
        /*
        t_rect(float x, float y, float w, float h):
            x(x),
            y(y),
            w(w),
            h(h) {}*/
        float x, y, w, h;
    } t_rect;
    
    typedef struct t_size2d
    {
        float w, h;
    } t_size2d;
    
    typedef std::vector<t_rect> t_hitboxes;
    
    static std::vector<std::vector<t_rect>> HITBOX_LIST;
    
    //typedef std::vector<t_hg_rect> t_hg_rectlist;
    
    /*
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
    */
     
    //typedef std::vector<t_hg_actorinf> t_hg_actorinf_list;
    
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
        updateCount(0),
        hitbox_id(-1)
        {}
        
        static void HGActor::initialize();
        ~HGActor();
        
        virtual void draw() = 0;
        virtual void update();
        void drawCollision();
        void setVelocity(float velocity);
        void setMoveAspect(float degree);
        bool isCollideWith(HGActor* another);
        void setAspect(float degree);
        
        // property
        hgles::HGLVector3 position;
        hgles::HGLVector3 rotate;
        hgles::HGLVector3 scale;
        
        unsigned int updateCount;
        float velocity; // 速度
        float aspect; // degree
        float radian;
        float moveAspect; // radian
        int hitbox_id;
        
        t_size2d size;
        t_size2d realSize;
        hgles::HGLVector3 acceleration; // 加速
    };
    
}
