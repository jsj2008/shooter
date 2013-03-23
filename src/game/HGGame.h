#import "HGLVector3.h"
#import "HGBullet.h"

namespace HGGame
{
    
    // enum effect
    typedef enum
    {
        EFFECT_EXPLODE_NORMAL,
        EFFECT_HIT_NORMAL,
    } EFFECT_TYPE;
    
    typedef struct t_keystate
    {
        int fire = 0;
    } t_keystate;
    void initialize();
    void render();
    void update(t_keystate* keystate);
    void onMoveLeftPad(int degree, float power);
    void createEffect(EFFECT_TYPE type, hgles::HGLVector3* position);
    
    // 弾を取得する
    HGBullet* getBullet();
    
    // 指定の範囲のランダム値を返す
    int rand(int from, int to);
    
    // 現在時間をdoubleで返す(秒が1の位)
    double getNowTime();
}
