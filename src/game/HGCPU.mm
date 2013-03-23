#import "HGUtil.h"
#import "HGCommon.h"
#import "HGCPU.h"
#import "HGGame.h"

#import <string>

using namespace std;

namespace HGGame
{
    
    typedef HGFighter base;
    
    HGCPU::~HGCPU()
    {
        base::~HGFighter();
    }
    
    void HGCPU::init(HG_FIGHTER_TYPE type)
    {
        base::init(type);
        explodeCount = 200;
        target = NULL;
        destination.set(0, 0, 0);
    }
    
    void HGCPU::update()
    {
        // targetがなくなっていたら消去する
        if (target && !target->isActive)
        {
            target = NULL;
        }
        if (!this->isActive)
        {
            return;
        }
        // tgの方向を向く
        if (target)
        {
            float w = base::getDirectionByDegree(target);
            base::setDirectionWithDegree(w);
        }
        
        if (destination.x == 0 || destination.y == 0)
        {
            // 最初の移動先を決定
            decideDestination();
        }
        else
        {
            // 目的地についたか？
            float diffX = position.x - destination.x;
            float diffY = position.y - destination.y;
            if (diffX < 0) diffX *= -1;
            if (diffY < 0) diffY *= -1;
            if (diffX < realSize.w/2 && diffY < realSize.h/2 ){
                // 移動先を決定
                decideDestination();
            }
        }
        
        // タゲの方向へ移動する
        float deg = atan2f(destination.x - position.x, destination.y - position.y);
        base::setMoveDirectionWithDegree(deg*180*M_PI - 90);
        
        // 攻撃する
        fire();
        
        base::update();
    }
    
    void HGCPU::decideDestination()
    {
        if (target)
        {
            // 遠距離
            float rad = rand(1, 359)*180/M_PI;
#warning 150は適当すぎるかも
            float viaX = (target->position.x + 400*SCRATE*cos(rad));
            float viaY = (target->position.y + 400*SCRATE*sin(rad));
            destination.x = viaX;
            destination.y = viaY;
        }
    }
    
}





