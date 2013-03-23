#define IS_DEBUG_COLLISION 1

// game define
#define ENEMY_NUM 20
#define BULLET_NUM 2000
#define FIELD_SIZE 200
#define ZPOS 0
#define BACKGROUND_SCALE 1000
#define STAGE_SCALE 100
#define SCRATE 0.01

// util
#define LOG(A, ...) NSLog(@"[Debug] Func:%s Line:%d %@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#define HDebugLOG(A, ...) NSLog(@"[Debug] Func:%s Line:%d %@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);

namespace HGGame {
    
    typedef struct t_rect
    {
        float x, y, w, h;
    } t_rect;
    
    typedef struct t_size2d
    {
        float w, h;
    } t_size2d;
    
    typedef struct t_pos2d
    {
        float x, y;
    } t_pos2d;
    
    
}
