#import "TitleView.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>

#import <vector>

// openGL
#import "HGLView.h"
#import "HGLES.h"
#import "HGLGraphics2D.h"

typedef enum TYPE_TITLE_BTN
{
    TITLE_START_BTN,
    TITLE_BTN_NUM
} TYPE_BTN;

typedef struct t_title_btn
{
    float x;
    float y;
    float w;
    float h;
    NSString* btnName;
} t_title_btn;

t_title_btn title_btn_info[] = {
    {
        0,
        100,
        200,
        50,
        @"start"
    }
};


@interface TitleView ()
{
    
    UIButton* _buttons[TITLE_BTN_NUM];
    
    // OpenGL
    HGLView* _glview;
    // game's main thread
    dispatch_queue_t _game_queue;
    
    // background
    hgles::t_hgl2di* background;
    std::vector<hgles::t_hgl2di*> nebula;
    
    bool isEnd;
    bool is3DInitialized;
}

@end

@implementation TitleView

- (id)init
{
    CGRect win = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:win];
    if (self)
    {
        [self initialize];
        isEnd = false;
        is3DInitialized = false;
    }
    return self;
}

-(void)initialize
{
    ////////////////////
    // 3d描画用ビューを初期化
    CGRect win = [[UIScreen mainScreen] bounds];
    _glview = [[HGLView alloc] initWithFrame:win WithRenderBlock:^{
        @synchronized(self)
        {
            ////////////////////
            // openGLのコンテキストで初期化
            if (!is3DInitialized)
            {
                [self setUp];
                is3DInitialized = true;
            }
            // レンダリング
            [self renderTitle];
        }
    }];
    [self addSubview:_glview];
    
    // ゲームスレッド
    _game_queue = dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, NULL);
    dispatch_async(_game_queue, ^{
        NSDate* nowDt;
        NSTimeInterval start;
        NSTimeInterval end;
        float base_sleep = 1.0/20;
        float sleep;
        while (1)
        {
            if (isEnd)
            {
                break;
            }
            nowDt = [NSDate date];
            start = [nowDt timeIntervalSince1970];
            {
                // calling game's main process
                @synchronized(self)
                {
                    [self update];
                }
                [_glview draw];
            }
            nowDt = [NSDate date];
            end = [nowDt timeIntervalSince1970];
            sleep = base_sleep - (end - start);
            if (sleep > 0)
            {
                [NSThread sleepForTimeInterval:sleep];
            }
            
        }
    });
    
    // button
    CGPoint center = CGPointMake(win.size.width/2, win.size.height/2);
    for (int i = 0; i < TITLE_BTN_NUM; ++i)
    {
        t_title_btn info = title_btn_info[i];
        UIButton* b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [b setFrame: CGRectMake(0, 0, info.w, info.h)];
        [b setCenter:CGPointMake(center.x + info.x, center.y + info.y)];
        [b setTag:i];
        [b setTitle:info.btnName forState:UIControlStateNormal];
        [b setTitle:info.btnName forState:UIControlStateDisabled];
        [b setTitle:info.btnName forState:UIControlStateHighlighted];
        [b setTitle:info.btnName forState:UIControlStateSelected];
        [b addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:b];
    }
    
    ////////////////////
    // 描画開始
    [_glview start];
}

- (void)setUp
{
    // background
    hgles::t_hgl2di* t = new hgles::t_hgl2di();
    t->texture = *hgles::HGLTexture::createTextureWithAsset("space.png");
    t->texture.repeatNum = 1;
    t->scale.set(200,200,200);
    t->position.z = -100;
    background = t;
    
    // create deep sky
    {
        float z = -250;
        for (int i = 0; i < 5; ++i)
        {
            hgles::t_hgl2di* t = new hgles::t_hgl2di();
            t->texture = *hgles::HGLTexture::createTextureWithAsset("space_a.png");
            t->texture.repeatNum = 1;
            t->texture.blendColor = {2.0, 2.0, 2.0, 1.0};
            t->scale.set(500, 500, 300);
            int x = rand()%20 * ((rand()%2 == 0)?-1:1);
            int y = rand()%20 * ((rand()%2 == 0)?-1:1);
            t->position.set(x, y, z);
            t->rotate.set(0, 0, rand()%360*M_PI/180);
            nebula.push_back(t);
            z += 50;
        }
    }
}

- (void)update
{
    
    // update nebula
    for (std::vector<hgles::t_hgl2di*>::reverse_iterator itr = nebula.rbegin(); itr != nebula.rend(); ++itr)
    {
        hgles::t_hgl2di* n = *itr;
        n->position.z += 10;
        
        if (n->position.z >= -50)
        {
            n->texture.color.a *= 0.9;
        }
        if (n->position.z >= -10)
        {
            n->position.z = -250;
            n->texture.color.a = 1;
            n->rotate.set(0, 0, rand()%360*M_PI/180);
        }
    }
    
}

- (void)renderTitle
{
    // 光源なし
    glUniform1f(hgles::currentContext->uUseLight, 0.0);
    
    // 2d
    glDisable(GL_DEPTH_TEST);
    
    // set camera
    hgles::HGLVector3 cameraPos = hgles::HGLVector3(0, 0, -5);
    hgles::currentContext->cameraPosition = cameraPos;
    hgles::HGLES::updateCameraMatrix();
    
    // draw background
    hgles::HGLGraphics2D::draw(background);
    
    // draw nebula
    for (std::vector<hgles::t_hgl2di*>::reverse_iterator itr = nebula.rbegin(); itr != nebula.rend(); ++itr)
    {
        hgles::HGLGraphics2D::draw(*itr);
    }
}

- (void)buttonPressed:(UIButton*)button
{
    switch (button.tag) {
        case TITLE_START_BTN:
            [MainViewController StartShooting];
            isEnd = true;
            break;
        default:
            assert(0);
    }
}

- (void)clear3DContext
{
    if (_glview) {
        [_glview removeFromSuperview];
        [_glview release];
    }
    // このコンテキストのデータをすべて削除
    hgles::HGLTexture::deleteAllTextures();
    for (std::vector<hgles::t_hgl2di*>::reverse_iterator itr = nebula.rbegin(); itr != nebula.rend(); ++itr)
    {
        delete *itr;
    }
    nebula.clear();
}

-(void)dealloc
{
    [super dealloc];
}


@end
