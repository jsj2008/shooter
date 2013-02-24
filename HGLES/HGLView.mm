//
//  GLObject.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "HGLView.h"
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

#import "HGLCommon.h"
#import "HGLObject3D.h"
#import "HGLVertexBuffer.h"
#import "HGLIndexBuffer.h"
#import "HGLMesh.h"
#import "HGLES.h"
#import "HGLTypes.h"
#import "HGLObjLoader.h"
#import "HGLVector3.h"

#define TEST_GL_VIEW 0

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface HGLView()
{
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _depthRenderBuffer;
    void (^render)();
    bool isRenderRequired;
    
    // FPS管理用
    NSTimeInterval lastDrawTime;
    
    // 光源設定
    Color HGLES::ambient;
    Color HGLES::diffuse;
    Color HGLES::specular;
    Position HGLES::lightPos;
    
}
@end

@implementation HGLView

@synthesize cameraPosition;
@synthesize cameraRotate;

- (id)initWithFrame:(CGRect)frame WithRenderBlock:(void (^)())block
{
    self = [super initWithFrame:frame];
    if (self)
    {
        render = [block copy];
        
        // initializing valuables
        self.cameraPosition = HGLVector3(0, 0, 0);
        self.cameraRotate = HGLVector3(0, 0, 0);
        lastDrawTime = 0;
        isRenderRequired = false;
        
        // setup gl
        [self setupLayer];
        [self setupContext];
        HGLES::initialize(self.frame.size.width, self.frame.size.height);
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        
        // シェーダのデフォルト値をセットする
        [self setDefault];
    }
    return self;
}

- (void)start
{
    [self setupDisplayLink];
}

- (void)dealloc
{
    [_context release];
    _context = nil;
    [super dealloc];
}

#pragma mark - overwrite UIView's methods
+ (Class)layerClass
{
    // OpenGLESでViewを描画する場合はCAEAGLLayerのクラスを返す
    return [CAEAGLLayer class];
}

#pragma mark - initialize OpenGLES 2.0

- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}

- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)setupLayer
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES; // 背景を透明にする
}

- (void)setupContext
{
    // OpenGLES 2.0のコンテキスト(OpenGLの状態をすべて保持する物)を作成
    // @see http://www.opengl.org/wiki/OpenGL_Context
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    // 作成したコンテキストを現在のコンテキストとして設定
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

// @see http://www.opengl.org/wiki/Renderbuffer_Object
- (void)setupRenderBuffer
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}


// @see http://www.opengl.org/wiki/Framebuffer_Objects
- (void)setupFrameBuffer {
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (void)initFrame
{
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
}

- (void)setDefault
{
    // light
    ambient = {1.0, 1.0, 1.0, 1.0};
    diffuse = {0.7, 0.7, 0.7, 1.0};
    specular = {1.9, 1.9, 1.9, 1.0};
    lightPos = {115.0, 115.0, 0.0};
    glUniform4fv(HGLES::uLightAmbientSlot, 1, (GLfloat*)(&ambient));
    glUniform4fv(HGLES::uLightDiffuseSlot, 1, (GLfloat*)(&diffuse));
    glUniform4fv(HGLES::uLightSpecular, 1, (GLfloat*)(&specular));
    glUniform3fv(HGLES::uLightPos, 1, (GLfloat*)(&lightPos));
    glUniform1f(HGLES::uUseLight, 1);
    glUniform1f(HGLES::uAlpha, 1.0);
}

- (void)updateCamera
{
    // camera setting
    HGLES::cameraPosition = self.cameraPosition;
    HGLES::cameraRotate = self.cameraRotate;
    HGLES::mvMatrix = GLKMatrix4Identity;
    HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, self.cameraRotate.x, 1, 0, 0);
    HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, self.cameraRotate.y, 0, 1, 0);
    HGLES::mvMatrix = GLKMatrix4Rotate(HGLES::mvMatrix, self.cameraRotate.z, 0, 0, 1);
    HGLES::mvMatrix = GLKMatrix4Translate(HGLES::mvMatrix, self.cameraPosition.x, self.cameraPosition.y, self.cameraPosition.z);
}

- (void)showBuffer
{
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)draw
{
    isRenderRequired = true;
}

- (void)render:(CADisplayLink*)displayLink {
    // FPS計算
    NSDate* nowDate = [NSDate date];
    NSTimeInterval now = [nowDate timeIntervalSince1970];
    if (lastDrawTime > 0)
    {
        if (now - lastDrawTime < (1.0 / FPS))
        {
#if IS_DEBUG && 0
            NSLog(@"frame skip");
#endif
            return;
        }
    }
    
    if (!isRenderRequired)
    {
        return;
    }
    isRenderRequired = false;
    
    [self initFrame];
    if (render)
    {
        // call block
        render();
    }
    [self showBuffer];
    
    lastDrawTime = now;
}

@end
