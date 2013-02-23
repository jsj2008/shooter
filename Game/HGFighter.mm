#import "HGActor.h"
#import "HGFighter.h"
#import "HGUtil.h"

typedef HGActor base;

HGFighter::HGFighter()
{
    base();
    base::useLight = false;
}

void HGFighter::setAspect(float degree)
{
    // 角度に応じてスプライトを選択する
    int spIdx = getSpriteIndex(degree + 0.5);
    int x = 64 * spIdx;
    base::setTextureArea(x, 0, 64, 64);
    base::setAspect(degree);
}
