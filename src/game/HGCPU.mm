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
    }
    
    void HGCPU::init(HG_FIGHTER_TYPE type, WHICH_SIDE side)
    {
        base::init(type, side);
        target = NULL;
        destination.set(0, 0, 0);
    }
    
    void HGCPU::damage(int damage, HGFighter* attacker, HGBullet* bullet)
    {
        target = attacker;
        life -= damage;
        if (life == 0)
        {
            createEffect(EFFECT_EXPLODE_NORMAL, &bullet->position);
        }
        else
        {
            createEffect(EFFECT_HIT_NORMAL, &position);
        }
        if (attacker && attacker->isActive)
        {
            target = attacker;
        }
    }
    
    void HGCPU::update()
    {
        if (!this->isActive)
        {
            return;
        }
        if (target)
        {
            // targetがなくなっていたら消去する
            if (!target->isActive)
            {
                target = NULL;
            }
            else
            {
                // tgの方向を向く
                float w = base::getDirectionByDegree(target);
                base::setDirectionWithDegree(w);
                
                // 攻撃する
                if (target->life > 0)
                {
                    fire();
                }
            }
        }
        else
        {
            // ターゲットがなければ探す
            target = getRandomTarget(this->side);
            assert(target->maxlife > 0);
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
        float rad = atan2f(destination.x - position.x, destination.y - position.y);
        base::setMoveDirectionWithDegree(rad*180/M_PI - 90);
        
        base::update();
    }
    
    HGFighter* HGCPU::tellTarget()
    {
        if (target && target->isActive)
        {
            return target;
        }
        return NULL;
    }
    
    void HGCPU::decideDestination()
    {
        if (target && target->isActive)
        {
            // 遠距離
            float rad = rand(1, 359)*180/M_PI;
#warning 150は適当すぎるかも
            float viaX = (target->position.x + 1000*SCRATE*cos(rad));
            float viaY = (target->position.y + 1000*SCRATE*sin(rad));
            destination.x = viaX;
            destination.y = viaY;
        }
        else
        {
            float rad = rand(1, 359)*180/M_PI;
            float viaX = (position.x + 3000*SCRATE*cos(rad));
            float viaY = (position.y + 3000*SCRATE*sin(rad));
            destination.x = viaX;
            destination.y = viaY;
            
            float r = atan2f(viaX - position.x, viaY - position.y) ;
            float d = r * 180/M_PI - 90;
            base::setDirectionWithDegree(d);
        }
        
        // フィールド外チェック
        t_size2d* field_size = get_size_of_field();
        if (destination.x + realSize.w/2 > field_size->w)
        {
            destination.x = field_size->w - realSize.w/2;
        }
        if (destination.y + realSize.h/2 > field_size->h)
        {
            destination.y = field_size->h - realSize.h/2;
        }
        if (destination.x - realSize.w/2 < 0)
        {
            destination.x = realSize.w/2;
        }
        if (destination.y - realSize.h/2 < 0)
        {
            destination.y = realSize.h/2;
        }
    }
    
}





