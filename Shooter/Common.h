// debug
#define IS_DEBUG 1
#define IS_DEBUG_COLLISION 0
#define IS_TEST_VIEW 0

// game define
#define ENEMY_NUM 20
#define BULLET_NUM 2000
#define FPS 20

// util
#define LOG(A, ...) NSLog(@"LOG: %s:%d:%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);

