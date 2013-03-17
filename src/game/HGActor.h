#import "HGLObject3D.h"
#import "HGLVector3.h"
#import "HGLTexture.h"
#import "HGLGraphics2D.h"
#import "HGCommon.h"
#import <vector>
#import <string>

namespace HGGame {
    
    // 3dやテクスチャなどのデータを読み込む
#warning 後で適切な場所に移すことを検討
    void HGLoadData();
    
    class HGActor
    {
        friend void initActor(HGActor& actor, t_size2d &size, int &hitbox_id);
        
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
        hitbox_id(-1)
        {}
        
        virtual ~HGActor();
        
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
        float aspect; // degree
        float radian;
        bool isActive;
    protected:
        void init();
        
    private:
        void initSize(t_size2d &size);
        void initHitbox(int hitbox_id);
        
        // property
        hgles::HGLVector3 acceleration; // 加速
        float velocity; // 速度
        float moveAspect; // radian
        int hitbox_id;
        t_size2d size;
        t_size2d realSize;
    };
    
    void initActor(HGActor& actor, t_size2d &size, int &hitbox_id);
    
}
