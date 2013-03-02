#import "HGActor.h"
#import "HGLMesh.h"
#import "HGLMaterial.h"
#import "HGLObjLoader.h"
#import "HGLGraphics2D.h"
#import <map>
#import <string>

using namespace std;

#warning 改善
std::map<std::string, HGLObject3D*> HGActor::object3DTable;
std::map<std::string, HGLTexture*> HGActor::textureTable;
void HGLoadData()
{
    HGActor::object3DTable["rect"] = HGLObjLoader::load(@"rect");
    //HGActor::object3DTable["droid"] = HGLObjLoader::load(@"droid");
    HGActor::textureTable["e_robo2.png"] = HGLTexture::createTextureWithAsset("e_robo2.png");
    HGActor::textureTable["divine.png"] = HGLTexture::createTextureWithAsset("divine.png");
    HGActor::textureTable["space.png"] = HGLTexture::createTextureWithAsset("space.png");
    HGActor::textureTable["star.png"] = HGLTexture::createTextureWithAsset("star.png");
    HGActor::textureTable["x6.png"] = HGLTexture::createTextureWithAsset("x6.png");
}

HGActor::~HGActor()
{
}

void HGActor::setVelocity(float inVelocity)
{
    velocity = inVelocity;
    acceleration.set(
        cos(moveAspect) * velocity,
        sin(moveAspect) * velocity * -1, // 上下逆に
        0
    );
}

void HGActor::setAspect(float degree)
{
    aspect = degree;
    radian = degree * M_PI / 180;
}

void HGActor::setMoveAspect(float degree)
{
    moveAspect = degree * M_PI / 180;
}

void HGActor::update()
{
    updateCount++;
    if (velocity)
    {
        position.x += acceleration.x;
        position.y += acceleration.y;
        position.z += acceleration.z;
    }
}
