#import "HGLVector3.h"

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
    int rand(int from, int to);
}
