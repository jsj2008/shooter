#import "HGActor.h"
#import "HGLMesh.h"
#import "HGLMaterial.h"

HGActor::~HGActor()
{
    if (object3d)
    {
        delete object3d;
    }
}

void HGActor::draw()
{
    if (object3d)
    {
        object3d->useLight = useLight;
        object3d->position = position;
        object3d->rotate = rotate;
        object3d->scale = scale;
        if (texture)
        {
            texture->setTextureMatrix(textureMatrix);
        }
        object3d->draw();
    }
}

void HGActor::setObject3D(HGLObject3D* obj)
{
    object3d = obj;
    HGLMesh* mesh = object3d->getMesh(0);
    if (mesh)
    {
        HGLMaterial* mat = mesh->material;
        if (mat)
        {
            texture = mat->texture;
            textureMatrix = GLKMatrix4Identity;
        }
    }
}

void HGActor::setVelocity(float inVelocity)
{
    velocity = inVelocity;
    acceleration.set(
        cos(aspect) * velocity,
        sin(aspect) * velocity * -1, // 上下逆に
        0
    );
}

void HGActor::setTextureArea(int x, int y, int w, int h)
{
    if (texture)
    {
        textureMatrix = texture->getTextureMatrix(x, y, w, h);
    }
}

void HGActor::setAspect(float degree)
{
    aspect = degree * M_PI / 180;
}

void HGActor::move()
{
    if (velocity)
    {
        position.x += acceleration.x;
        position.y += acceleration.y;
        position.z += acceleration.z;
    }
}
