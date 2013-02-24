#import "HGActor.h"
#import "HGBullet.h"
#import "HGUtil.h"

typedef HGActor base;

HGBullet::HGBullet()
{
    base();
    base::useLight = false;
    color.r = 1.0; color.g = 1.0; color.b = 1.0; color.a = 1.0;
}

void HGBullet::draw()
{
    texture->color = color;
    base::draw();
}
