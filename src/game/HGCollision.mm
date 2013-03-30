#import "HGCollision.h"

namespace HGGame {
    
    // あたり判定用矩形リスト
    typedef std::vector<t_rect> t_hitboxes;
    typedef struct t_hitbox
    {
        int hitbox_id;
        t_rect hitbox;
    } t_hitbox;
    
    // x, y, w, h
    static t_hitbox _HITBOX_LIST[] = {
        {0, {10, 10, 44, 44}},
        {1, {-6, -6, 24, 24}},
        {2, {20, 20, 88, 88}},
        {3, {280, 230, 1700, 390}},
    };
    
    static hgles::t_hgl2di square; // 矩形描画用
    
    void initializeCollision()
    {
        square = hgles::t_hgl2di();
        square.texture = (*hgles::HGLTexture::createTextureWithAsset("square.png"));
        square.texture.isAlphaMap = 1;
        square.texture.blend1 = GL_ALPHA;
        square.texture.blend2 = GL_ALPHA;
        
        // あたり判定
        {
            int len = (sizeof(_HITBOX_LIST)/sizeof(t_hitbox));
            int hitbox_id = _HITBOX_LIST[0].hitbox_id;
            t_hitboxes tmp_hitboxes;
            for (int i = 0; i < len; ++i)
            {
                t_hitbox t = _HITBOX_LIST[i];
                if (t.hitbox_id != hitbox_id)
                {
                    HITBOX_LIST.push_back(tmp_hitboxes);
                    tmp_hitboxes.clear();
                }
                t_rect r = t.hitbox;
                r.x *= SCRATE;
                r.y *= SCRATE;
                r.w *= SCRATE;
                r.h *= SCRATE;
                tmp_hitboxes.push_back(r);
            }
            HITBOX_LIST.push_back(tmp_hitboxes);
        }
        
    }


    bool isIntersect(const hgles::HGLVector3* position1, const t_size2d* size1, int hitbox_id1,
                     const hgles::HGLVector3* position2, const t_size2d* size2, int hitbox_id2)
    {
        t_hitboxes* list1 = &HITBOX_LIST[hitbox_id1];
        t_hitboxes* list2 = &HITBOX_LIST[hitbox_id2];
        int len1 = list1->size();
        int len2 = list2->size();
        float offx1 = position1->x - size1->w/2;
        float offy1 = position1->y - size1->h/2;
        float offx2 = position2->x - size2->w/2;
        float offy2 = position2->y - size2->h/2;
        for (int i = 0; i < len1; ++i)
        {
            t_rect* r1 = &((*list1)[i]);
            for (int j = 0; j < len2; ++j)
            {
                t_rect* r2 = &((*list2)[j]);
                if (offx1 + r1->x <= offx2 + r2->x + r2->w
                    && offx2 + r2->x <= offx1 + r1->x + r1->w
                    && offy1 + r1->y <= offy2 + r2->y + r2->h
                    && offy2 + r2->y <= offy1 + r1->y + r1->h)
                {
                    return true;
                }
            }
        }
        return false;
        
    }

    void drawHitbox(const hgles::HGLVector3* position1, const t_size2d* size1, int hitbox_id1, const hgles::HGLVector3* rotate)
    {
        if (hitbox_id1 == -1) return;
        t_hitboxes* list1 = &HITBOX_LIST[hitbox_id1];
        if (list1 == NULL)return;
        square.texture.color = {1,0,0,0.5};
        float offx1 = position1->x - size1->w/2;
        float offy1 = position1->y - size1->h/2;
        square.rotate = *rotate;
        int len1 = list1->size();
        for (int i = 0; i < len1; ++i)
        {
            t_rect* r1 = &((*list1)[i]);
            square.position.x = offx1 + r1->x + r1->w/2;
            square.position.y = offy1 + r1->y + r1->h/2;
            square.position.z = position1->z;
            square.scale.set(r1->w, r1->h, 1);
            hgles::HGLGraphics2D::draw(&square);
        }
    }

    
}
