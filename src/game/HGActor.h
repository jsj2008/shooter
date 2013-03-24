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
        friend void initActor(HGActor& actor, t_size2d size, int hitbox_id);
        
    public:
        HGActor():
        velocity(0),
        degree(0),
        radian(0),
        moveRadian(0),
        scale(1,1,1),
        rotate(0,0,0),
        position(0,0,0),
        acceleration(0,0,0),
        hitbox_id(-1)
        {}
        
        virtual ~HGActor(){}
        virtual void draw() = 0;
        virtual void update();
        
        // あたり判定を描画する
        void drawCollision();
        
        // 速度を設定する
        void setVelocity(float velocity);
        
        // 移動角度を設定する
        void setMoveDirectionWithDegree(float degree);
        void setMoveDirectionWithRadian(float radian);
        
        // 衝突しているかを返す
        bool isCollideWith(HGActor* another);
        
        // 向きを設定する(移動の向きとは無関係)
        void setDirectionWithDegree(float degree);
        void setDirectionWithRadian(float radian);
        
        // 自分の領域の中のランダムな点を返す
        hgles::HGLVector3 getRandomRealPosition();
        
        // 指定のactorに対する(平面xy上の)角度を返す
        float getDirectionByDegree(HGActor* target);
        
        // 位置
        hgles::HGLVector3 position;
        // 回転(描画のみに関係)
        hgles::HGLVector3 rotate;
        // 拡大率
        hgles::HGLVector3 scale;
        
        // 向き
        float degree;
        float radian;
        
        // 使用フラグ
        bool isActive;
        // 大きさ(架空のサイズ)
        t_size2d size;
        // 大きさ(3D上の実際の大きさ)
        t_size2d realSize;
    protected:
        
        float velocity; // 速度
        
    private:
        void initSize(t_size2d &size); // 初期化
        void initHitbox(int hitbox_id); // あたり判定初期化
        
        hgles::HGLVector3 acceleration; // 加速
        // 移動角度
        float moveRadian;
        // あたり判定ID
        int hitbox_id;
    };
    
    // 初期化関数
    void initActor(HGActor& actor, t_size2d size, int hitbox_id);
    
}
