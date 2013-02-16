#import "HGLObject3D.h"

class Actor
{
public:
    Actor():x(0),y(0),z(0),speed(0),vx(0),vy(0),vz(0),scale(1){}
    float x, y, z;
    float speed;
    float vx, vy, vz;
    float scale;
    HGLObject3D* object3d;
};
