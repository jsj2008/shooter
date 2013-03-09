#import "HGGame.h"
#import "HGLES.h"
#import "HGUtil.h"
#import "HGLObject3D.h"
#import "HGLObjLoader.h"
#import "HGLVector3.h"
#import "HGActor.h"
#import "HGFighter.h"
#import "HGBullet.h"
#import "HGCommon.h"

#import <vector>

namespace HGGame {
    
    // flag
    bool fire;
    NSTimeInterval lastFireTime;
    float fireAspect;
    
    // game objects
    HGFighter* _player;
    
    std::vector<HGBullet*> _bullets;
    std::vector<HGBullet*> _bulletsInActive;
    std::vector<HGFighter*> _enemies;
    std::vector<t_hgl2di*> background;
    
    HGLObject3D* skybox;
    
    
    // camera
    HGLVector3 _cameraPosition;
    HGLVector3 _cameraRotate;
    
    void onMoveLeftPad(int degree, float power)
    {
        if (power > 0)
        {
            if (!fire) _player->setAspect(degree);
            _player->setMoveAspect(degree);
        }
        _player->setVelocity(0.4*power);
    }
    
    void initialize()
    {
#warning 後でdelete
        // initialize utility program
        initSpriteIndexTable();
        HGLoadData();
        
        // create players
        _player = new HGFighter();
        _player->init(HG_FIGHTER);
        _player->position.set(0, 0, ZPOS);
        _player->setAspect(0);
        fire = false;
        
        // create enemies
        for (int i = 0; i < ENEMY_NUM; ++i)
        {
            HGFighter* t;
            t = new HGFighter();
            t->init(HG_FIGHTER);
            t->position.x = (i*2) + -2;
            t->position.y = 1;
            t->position.z = 0;
            t->setAspect(90);
            t->setMoveAspect(90);
            t->setVelocity(0.05);
            _enemies.push_back(t);
        }
        
        // create bullets
        for (int i = 0; i < BULLET_NUM; ++i)
        {
            HGBullet* t;
            //if (i == 0)
            t = new HGBullet();
            _bulletsInActive.push_back(t);
        }
        
        // create background
        for (int i = 0; i < 6; ++i)
        {
            t_hgl2di* t = new t_hgl2di();
            t->texture = *HGLTexture::createTextureWithAsset("space.png");
            t->texture.repeatNum = 1;
            t->scale.set(BACKGROUND_SCALE, BACKGROUND_SCALE, BACKGROUND_SCALE);
            switch (i) {
                case 0:
                    t->position.set(-1*BACKGROUND_SCALE/2, 0, ZPOS);
                    t->rotate.set(0, 90*M_PI/180, 0);
                    break;
                case 1:
                    t->position.set(BACKGROUND_SCALE/2, 0, ZPOS);
                    t->rotate.set(0, -90*M_PI/180, 180*M_PI/180);
                    break;
                case 2:
                    t->position.set(0, BACKGROUND_SCALE/2, ZPOS);
                    t->rotate.set(-90*M_PI/180, 0, 0);
                    break;
                case 3:
                    t->position.set(0, -BACKGROUND_SCALE/2, ZPOS);
                    t->rotate.set(90*M_PI/180, 0, 0);
                    break;
                case 4:
                    t->position.set(0, 0, -1*BACKGROUND_SCALE/2 + ZPOS);
                    t->rotate.set(0, 0, 0);
                    break;
                case 5:
                    t->position.set(0, 0, 1*BACKGROUND_SCALE/2 + ZPOS);
                    t->rotate.set(180*M_PI/180, 0, 0);
                    break;
                default:
                    break;
            }
            background.push_back(t);
        }
        
        // camera
        _cameraPosition = HGLVector3(0,0,0);
        
    }
    
    void update(t_keystate* keystate)
    {
        {
#warning sync start
            _player->update();
#warning sync end
        }
        
        if (keystate->fire)
        {
            fire = true;
            fireAspect = _player->aspect;
        }
        else
        {
            fire = false;
        }
        
        if (fire)
        {
            NSDate* nowDt = [NSDate date];
            NSTimeInterval now = [nowDt timeIntervalSince1970];
            if (now - lastFireTime > 0.3)
            {
                lastFireTime = now;
                if (_bulletsInActive.size() > 0)
                {
                    HGBullet* t = _bulletsInActive.back();
                    t->position.x = _player->position.x;
                    t->position.y = _player->position.y;
                    t->position.z = _player->position.z;
                    t->setMoveAspect(fireAspect);
                    t->init(HG_BULLET_N1);
                    _bulletsInActive.pop_back();
                    _bullets.push_back(t);
                }
            }
        }
        
        // move enemies
        for (std::vector<HGFighter*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
        {
            HGFighter* a = *itr;
            a->update();
        }
        
        // move bullets
        for (std::vector<HGBullet*>::iterator itr = _bullets.begin(); itr != _bullets.end(); ++itr)
        {
            HGBullet* a = *itr;
            a->update();
        }
        
        // collision check (enemy with bullet)
        for (std::vector<HGFighter*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
        {
            HGFighter* a = *itr;
            for (std::vector<HGBullet*>::iterator itr2 = _bullets.begin(); itr2 != _bullets.end(); ++itr2)
            {
                HGBullet* b = *itr2;
                if (a->isCollideWith(b))
                {
                    NSLog(@"hit");
                }
            }
            
        }
        
    }
    
    void render()
    {
#warning sync start
        // 光源なし
        glUniform1f(HGLES::uUseLight, 0.0);
        
        // set camera
        _cameraPosition.x = _player->position.x * -1;
        _cameraPosition.y = _player->position.y * -1 + 3.5;
        _cameraPosition.z = -7;
        _cameraRotate.x = -22 * M_PI/180;
        HGLES::cameraMatrix = GLKMatrix4Identity;
        HGLES::cameraMatrix = GLKMatrix4Rotate(HGLES::cameraMatrix, _cameraRotate.x, 1, 0, 0);
        HGLES::cameraMatrix = GLKMatrix4Rotate(HGLES::cameraMatrix, _cameraRotate.y, 0, 1, 0);
        HGLES::cameraMatrix = GLKMatrix4Rotate(HGLES::cameraMatrix, _cameraRotate.z, 0, 0, 1);
        HGLES::cameraMatrix = GLKMatrix4Translate(HGLES::cameraMatrix, _cameraPosition.x, _cameraPosition.y, _cameraPosition.z);
        
        // 2d
        glDisable(GL_DEPTH_TEST);
        
        // draw bg
        /*
        for (std::vector<HGObject*>::reverse_iterator itr = _background.rbegin(); itr != _background.rend(); ++itr)
        {
            HGObject* a = *itr;
            a->draw();
        }*/
        // draw bg
        for (std::vector<t_hgl2di*>::reverse_iterator itr = background.rbegin(); itr != background.rend(); ++itr)
        {
            HGLGraphics2D::draw(*itr);
        }
        
        // draw enemies
        for (std::vector<HGFighter*>::reverse_iterator itr = _enemies.rbegin(); itr != _enemies.rend(); ++itr)
        {
            HGFighter* a = *itr;
            a->draw();
#if IS_DEBUG_COLLISION
            a->drawCollision();
#endif
        }
        
        // draw bullets
        for (std::vector<HGBullet*>::reverse_iterator itr = _bullets.rbegin(); itr != _bullets.rend(); ++itr)
        {
            HGBullet* a = *itr;
            a->draw();
#if IS_DEBUG_COLLISION
            a->drawCollision();
#endif
        }
    
        // draw player
        _player->draw();
#if IS_DEBUG_COLLISION
        _player->drawCollision();
#endif
#warning sync end
        
    }
    
    
}
