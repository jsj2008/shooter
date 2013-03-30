#ifndef __HGLCOMMON
#define __HGLCOMMON
#define IS_DEBUG 1

#define FPS 30

#define LOG(A, ...) NSLog(@"LOG: %s:%d:%@", __PRETTY_FUNCTION__,__LINE__,[NSString stringWithFormat:A, ## __VA_ARGS__]);
#endif