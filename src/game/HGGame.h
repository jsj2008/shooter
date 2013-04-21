#ifndef INC_HGGAME
#define INC_HGGAME
#import "HGLVector3.h"
#import "HGCommon.h"
#import "HGFighter.h"

namespace HGGame
{
    
    // enum effect
    typedef enum GAME_STATE
    {
        GAME_STATE_NONE = 0,
        GAME_STATE_BATTLE = 1,
        GAME_STATE_WIN = 2,
        GAME_STATE_LOSE = 3,
        GAME_STATE_PAUSE = 10,
    } GAME_STATE;
    
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
    void updateActors(t_keystate* keystate);
    
    // 敵を出現させる
    void createEnemy(HG_FIGHTER_TYPE type, float x, float y);
    
    // ランダムにターゲットを返す
    HGFighter* getRandomTarget(WHICH_SIDE selfSide);
    
    // 弾を取得する
    class HGBullet;
    HGBullet* getBullet(WHICH_SIDE side);
    
    // 指定の範囲のランダム値を返す
    int rand(int from, int to);
    
    // 現在時間をdoubleで返す(秒が1の位)
    double getNowTime();
    
    // フィールドのサイズを返す
    t_size2d* get_size_of_field();
    
    // フィールドの中心を返す
    t_pos2d* get_center_of_field();
    
    // フィールドの中にいるかを返す
    bool is_out_of_field(hgles::HGLVector3* position, t_size2d* size);
    
    // ライフを描画する
    void drawLife(hgles::HGLVector3* position, t_size2d *realSize, float lifeRate);
}
#endif