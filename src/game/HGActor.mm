#import "HGActor.h"
#import "HGLMesh.h"
#import "HGLMaterial.h"
#import "HGLObjLoader.h"
#import "HGLGraphics2D.h"
#import "HGCommon.h"
#import "HGCollision.h"
#import <set>
#import <string>

using namespace std;

namespace HGGame {
    
    void HGActor::setVelocity(float inVelocity)
    {
        velocity = inVelocity;
    }
    
    void HGActor::updateAccel()
    {
        acceleration.set(
                         cos(moveRadian) * velocity,
                         sin(moveRadian) * velocity * -1, // 上下逆に
                         0
                         );
    }
    
    void HGActor::setDirectionWithDegree(float degree)
    {
        this->degree = degree;
        radian = degree * M_PI / 180;
    }
    
    void HGActor::setDirectionWithRadian(float radian)
    {
        this->degree = degree*180/M_PI;
        radian = radian;
    }
    
    float HGActor::getDirectionByDegree(HGActor* target) {
        hgles::HGLVector3* mypos1 = &position;
        hgles::HGLVector3* tgpos2 = &target->position;
        float radian = atan2f(tgpos2->x - mypos1->x,
                             tgpos2->y - mypos1->y);
        float degree = radian*180/M_PI-90;
        return degree;
	}
    
    void HGActor::setMoveDirectionWithDegree(float degree)
    {
        moveRadian = degree * M_PI / 180;
        setVelocity(velocity);
        updateAccel();
    }
    
    void HGActor::setMoveDirectionWithRadian(float radian)
    {
        moveRadian = radian;
        setVelocity(velocity);
        updateAccel();
    }
    
    bool HGActor::isCollideWith(HGActor* another)
    {
        return isIntersect(&position, &realSize, hitbox_id, &another->position, &another->realSize, another->hitbox_id);
    }
    
    void HGActor::drawCollision()
    {
        drawHitbox(&this->position, &this->realSize, this->hitbox_id, &this->rotate);
    }
    
    void HGActor::update()
    {
        if (velocity)
        {
            position.x += acceleration.x;
            position.y += acceleration.y;
            position.z += acceleration.z;
        }
    }
    
    void HGActor::initHitbox(int hitbox_id)
    {
        this->hitbox_id = hitbox_id;
    }
    
    void HGActor::initSize(t_size2d &size)
    {
        this->size.w = size.w;
        this->size.h = size.h;
        this->realSize.w = size.w*SCRATE;
        this->realSize.h = size.h*SCRATE;
        this->hitbox_id = hitbox_id;
        this->scale.set(size.w*SCRATE, size.h*SCRATE, 1);
    }
    
    
    hgles::HGLVector3 HGActor::getRandomRealPosition()
    {
        float fromX = this->position.x - realSize.w/2;
        float fromY = this->position.y - realSize.h/2;
        int x = rand(0, this->size.w);
        int y = rand(0, this->size.h);
        return hgles::HGLVector3(x*SCRATE+fromX, y*SCRATE+fromY, this->position.z);
    }
    
    void initActor(HGActor& actor, t_size2d size, int hitbox_id)
    {
        actor.hitbox_id = -1;
        actor.isActive = true;
        actor.initSize(size);
        actor.initHitbox(hitbox_id);
    }
    

    
}
