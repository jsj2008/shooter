#import "HGCommon.h"
#import "HGGame.h"
#import <vector>
#import "HGLGraphics2D.h"
#import "HGActor.h"
#import "HGLVector3.h"

namespace HGGame {
    
    static std::vector<std::vector<t_rect>> HITBOX_LIST;
    
    void initializeCollision();
    bool isIntersect(const hgles::HGLVector3* position1, const t_size2d* size1, int hitbox_id1,
                     const hgles::HGLVector3* position2, const t_size2d* size2, int hitbox_id2);
    void drawHitbox(const hgles::HGLVector3* position1, const t_size2d* size1, int hitbox_id1, const hgles::HGLVector3* rotate);

}