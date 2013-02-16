//
//  GLObject.m
//  Shooter
//
//  Created by 濱田 洋太 on 12/12/24.
//  Copyright (c) 2012年 hayogame. All rights reserved.
//

#import "GLView.h"
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <GLKit/GLKit.h>

#import "HGLObject3D.h"
#import "VertexBuffer.h"
#import "IndexBuffer.h"
#import "Mesh.h"
#import "HGLES.h"
#import "HGLTypes.h"
#import "HGLObjLoader.h"
#import "HGLVector3.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@implementation GLView
#define SA 1

CAEAGLLayer* _eaglLayer;
EAGLContext* _context;
GLuint _colorRenderBuffer;
GLuint _depthRenderBuffer;
HGLVector3 _cameraPosition(0,0,0);

HGLObject3D* obj3d;
HGLObject3D* obj3d2;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // initialize
        [self setupLayer];
        [self setupContext];
        HGLES::initialize(self.frame.size.width, self.frame.size.height);
        [self setupDepthBuffer];
        [self setupRenderBuffer];
        [self setupFrameBuffer];
        [self setupVBOs];
        [self setupDisplayLink];
    }
    return self;
}

- (void)dealloc
{
    [_context release];
    _context = nil;
    [super dealloc];
    if (obj3d)
    {
        delete obj3d;
    }
    if (obj3d2)
    {
        delete obj3d2;
    }
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

- (void)render
{
    _cameraPosition.z = 1;
    HGLES::mvMatrix = GLKMatrix4Identity;
    HGLES::mvMatrix = GLKMatrix4Translate(HGLES::mvMatrix, _cameraPosition.x, _cameraPosition.y, _cameraPosition.z);
    
    if (obj3d2)
    {
        obj3d2->position.z = -5;
        obj3d2->position.y = -0.2;
        obj3d2->rotate.x += 0.01;
        obj3d2->rotate.y += 0.01;
        obj3d2->rotate.z += 0.01;
        obj3d2->draw();
    }
    
    obj3d->position.z = -5;
    obj3d->position.y = -0.2;
    obj3d->rotate.x += 0.01;
    obj3d->rotate.y += 0.01;
    obj3d->rotate.z += 0.01;
    obj3d->scale.set(0.1, 0.1, 0.1);
    obj3d->draw();
    
}

- (void)showBuffer
{
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)render:(CADisplayLink*)displayLink {
    
    [self initFrame];
    [self render];
    [self showBuffer];
}

#pragma mark buffer objects

- (void)setupVBOs {
     //obj3d = ObjLoader::load(@"block");
     obj3d = HGLObjLoader::load(@"floor");
     obj3d2 = HGLObjLoader::load(@"droid");
}

@end
