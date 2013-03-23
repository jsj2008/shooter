#import "HGGame.h"
#import "HGLES.h"
#import "HGUtil.h"
#import "HGLObject3D.h"
#import "HGLObjLoader.h"
#import "HGExplode.h"
#import "HGHit.h"
#import "HGLTexture.h"
#import "HGLVector3.h"
#import "HGActor.h"
#import "HGFighter.h"
#import "HGBullet.h"
#import "HGCommon.h"
#import "HGCollision.h"
#import "HGHitAnime.h"

#import <vector>
#import <mutex>

namespace HGGame {
    
    class RemoveActor
    {
    public:
        bool operator()(actor::HGActor* a) const { return !a->isActive; }
    };
    
    // flag
    bool fire;
    NSTimeInterval lastFireTime;
    float fireAspect;
    
    // game objects
    actor::HGFighter* _player;
    
    using namespace actor;
    std::vector<HGBullet*> _bullets;
    std::vector<HGBullet*> _bulletsInActive;
    std::vector<actor::HGFighter*> _enemies;
    std::vector<hgles::t_hgl2di*> background;
    std::vector<hgles::t_hgl2di*> barriar;
    std::vector<hgles::t_hgl2di*> nebula;
    std::vector<HGActor*> _effects;
    
    // camera
    hgles::HGLVector3 _cameraPosition;
    hgles::HGLVector3 _cameraRotate;
    
    unsigned int updateCount;
    
    //pthread_mutex_t	mutex;  // MUTEX
    
    int rand(int from, int to)
    {
        int r = std::rand()%(to - from);
        return r+from;
    }
    
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
        srand((unsigned int)time(NULL));
        updateCount = 0;
        initSpriteIndexTable();
        initializeCollision();
        
        // create players
        _player = new actor::HGFighter();
        _player->init(actor::HG_FIGHTER);
        _player->position.set(0, 0, ZPOS);
        _player->setAspect(0);
        fire = false;
        
        // create enemies
        for (int i = 0; i < ENEMY_NUM; ++i)
        {
            actor::HGFighter* t;
            t = new actor::HGFighter();
            t->init(actor::HG_FIGHTER);
            t->position.x = (i*2) + -2;
            t->position.y = 1;
            t->position.z = 0;
            t->setAspect(90);
            t->setMoveAspect(90);
            t->setVelocity(0.1);
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
        for (int i = 0; i < 5; ++i)
        {
            hgles::t_hgl2di* t = new hgles::t_hgl2di();
            t->texture = *hgles::HGLTexture::createTextureWithAsset("space.png");
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
                    /*
                case 5:
                    t->position.set(0, 0, 1*BACKGROUND_SCALE/2 + ZPOS);
                    t->rotate.set(180*M_PI/180, 0, 0);
                    break;*/
                default:
                    break;
            }
            background.push_back(t);
        }
        
        // create deep sky
        for (int i = 0; i < 4; ++i)
        {
            hgles::t_hgl2di* t = new hgles::t_hgl2di();
            t->texture = *hgles::HGLTexture::createTextureWithAsset("space_a.png");
            t->texture.repeatNum = 1;
            t->texture.blendColor = {2.0, 2.0, 2.0, 1.0};
            t->scale.set(500, 500, 300);
            int x = rand(0, 20) * (rand(0, 1)?-1:1);
            int y = rand(0, 20) * (rand(0, 1)?-1:1);
            int rz = rand(0, 360) * (rand(0, 1)?-1:1);
            t->position.set(x, y, -200 + ZPOS + i * 20);
            t->rotate.set(0, 0, rz*M_PI/180);
            nebula.push_back(t);
        }
        
        
        // create nebula
        for (int i = 0; i < 1; ++i)
        {
            int SIZE = rand(500, 650);
            hgles::t_hgl2di* t = new hgles::t_hgl2di();
            t->texture = *hgles::HGLTexture::createTextureWithAsset("proc_sheet_nebula.png");
            t->texture.repeatNum = 1;
            t->texture.color = {1.0, 1.0, 1.0, 0.6};
            t->texture.blendColor = {0.7, 0.7, 0.7, 0.6};
            t->texture.sprWidth = 256;
            t->texture.sprHeight = 256;
            t->texture.setTextureArea(rand(0,4)*256, rand(0,4)*256, 256, 256);
            t->scale.set(SIZE, SIZE, SIZE);
            int x = rand(0, STAGE_SCALE);
            int y = rand(0, STAGE_SCALE);
            t->position.set(x, y, -1*BACKGROUND_SCALE/2 + ZPOS);
            t->rotate.set(0, 0, rand(0, 360)*M_PI/180);
            nebula.push_back(t);
        }
        
    }
    
    
    void update(t_keystate* keystate)
    {
        //pthread_mutex_lock(&mutex); // スレッド保護
        //try {
            ++updateCount;
        
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
            
            // update effects
            for (std::vector<HGActor*>::reverse_iterator itr = _effects.rbegin(); itr != _effects.rend(); ++itr)
            {
                HGActor* a = *itr;
                a->update();
            }
            
            // collision check (enemy with bullet)
            for (std::vector<HGFighter*>::iterator itr = _enemies.begin(); itr != _enemies.end(); ++itr)
            {
                HGFighter* a = *itr;
                for (std::vector<HGBullet*>::iterator itr2 = _bullets.begin(); itr2 != _bullets.end(); ++itr2)
                {
                    HGBullet* b = *itr2;
                    if (a->life > 0)
                    {
                        if (a->isCollideWith(b))
                        {
                            b->isActive = false;
#warning 仮
                            a->life--;
                            if (a->life == 0)
                            {
                                createEffect(EFFECT_EXPLODE_NORMAL, &a->position);
                            }
                            else
                            {
                                createEffect(EFFECT_HIT_NORMAL, &a->position);
                            }
                        }
                    }
                    else
                    {
                        
                        a->explodeCount--;
                        if (a->explodeCount == 0)
                        {
                            a->isActive = false;
                            createEffect(EFFECT_EXPLODE_NORMAL, &a->position);
                        }
                        else if (a->explodeCount%100 == 0)
                        {
                            hgles::HGLVector3 pos = a->getRandomRealPosition();
                            createEffect(EFFECT_EXPLODE_NORMAL, &pos);
                        }
                        
                        
                    }
                }
                
            }
        
            // 不要となったものを削除
            {
                std::vector<HGBullet*>::iterator end_it = remove_if( _bullets.begin(), _bullets.end(), RemoveActor() );
                _bullets.erase( end_it, _bullets.end() );
            }
        
            {
                std::vector<HGFighter*>::iterator end_it = remove_if( _enemies.begin(), _enemies.end(), RemoveActor() );
                _enemies.erase( end_it, _enemies.end() );
            }
        
        /*
        }
        catch (...) // 全例外をキャッチ
        {
            LOG(@"some error happed");
        }
        pthread_mutex_unlock(&mutex);*/
        
    }
    
    void createEffect(EFFECT_TYPE type, hgles::HGLVector3* position)
    {
        switch (type) {
            case EFFECT_HIT_NORMAL:
            {
                HGHitAnime* ex = new HGHitAnime();
                ex->init();
                ex->position = *position;
                _effects.push_back((HGActor*)ex);
                break;
            }
            case EFFECT_EXPLODE_NORMAL:
            {
                HGExplode* ex = new HGExplode();
                ex->init();
                ex->position = *position;
                _effects.push_back((HGActor*)ex);
                break;
            }
            default:
                assert(0);
        }
        
    }
    
    
    void render()
    {
        /*
        pthread_mutex_lock(&mutex); // スレッド保護
        try {*/
            
            // 光源なし
            glUniform1f(hgles::HGLES::uUseLight, 0.0);
            
            // set camera
            _cameraPosition.x = _player->position.x * -1;
            _cameraPosition.y = _player->position.y * -1 + 3.5;
            _cameraPosition.z = -7;
            _cameraRotate.x = -22 * M_PI/180;
            hgles::HGLES::cameraMatrix = GLKMatrix4Identity;
            hgles::HGLES::cameraMatrix = GLKMatrix4Rotate(hgles::HGLES::cameraMatrix, _cameraRotate.x, 1, 0, 0);
            hgles::HGLES::cameraMatrix = GLKMatrix4Rotate(hgles::HGLES::cameraMatrix, _cameraRotate.y, 0, 1, 0);
            hgles::HGLES::cameraMatrix = GLKMatrix4Rotate(hgles::HGLES::cameraMatrix, _cameraRotate.z, 0, 0, 1);
            hgles::HGLES::cameraMatrix = GLKMatrix4Translate(hgles::HGLES::cameraMatrix, _cameraPosition.x, _cameraPosition.y, _cameraPosition.z);
            
            // 2d
            glDisable(GL_DEPTH_TEST);
            
            // draw bg
            /*
             for (std::vector<HGObject*>::reverse_iterator itr = _background.rbegin(); itr != _background.rend(); ++itr)
             {
             HGObject* a = *itr;
             a->draw();
             }*/
        
            hgles::HGLES::pushMatrix();
            hgles::HGLES::mvMatrix = GLKMatrix4Rotate(hgles::HGLES::mvMatrix, hgles::HGLES::cameraRotate.x*-1, 1, 0, 0);
            hgles::HGLES::mvMatrix = GLKMatrix4Rotate(hgles::HGLES::mvMatrix, hgles::HGLES::cameraRotate.y*-1, 0, 1, 0);
        
            // draw bg
            for (std::vector<hgles::t_hgl2di*>::reverse_iterator itr = background.rbegin(); itr != background.rend(); ++itr)
            {
                hgles::HGLGraphics2D::draw(*itr);
            }
        
            // draw nebula
            for (std::vector<hgles::t_hgl2di*>::reverse_iterator itr = nebula.rbegin(); itr != nebula.rend(); ++itr)
            {
                hgles::HGLGraphics2D::draw(*itr);
            }
        
            hgles::HGLES::popMatrix();
        
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
            
            // draw effects
            for (std::vector<HGActor*>::reverse_iterator itr = _effects.rbegin(); itr != _effects.rend(); ++itr)
            {
                HGActor* a = *itr;
                a->draw();
            }
        
        /*
        }
        catch (...) // 全例外をキャッチ
        {
            LOG(@"some error happed");
        }
        pthread_mutex_unlock(&mutex);
        */
    }
    
    
}
