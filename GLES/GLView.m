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

#import "VertexBuffer.h"
#import "IndexBuffer.h"
#import "Mesh.h"
#import "Shader.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

#define SH 1

@implementation GLView

CAEAGLLayer* _eaglLayer;
EAGLContext* _context;
GLuint _colorRenderBuffer;

#if SH
#else
GLuint _positionSlot;
GLuint _colorSlot;
GLuint _projectionUniform;
GLuint _modelViewUniform;
#endif

float _currentRotation;
GLuint _depthRenderBuffer;

Mesh* mesh;

const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}},
    {{1, 1, 0}, {1, 0, 0, 1}},
    {{-1, 1, 0}, {0, 1, 0, 1}},
    {{-1, -1, 0}, {0, 1, 0, 1}},
    {{1, -1, -1}, {1, 0, 0, 1}},
    {{1, 1, -1}, {1, 0, 0, 1}},
    {{-1, 1, -1}, {0, 1, 0, 1}},
    {{-1, -1, -1}, {0, 1, 0, 1}}
};


const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 7, 6,
    // Left
    2, 7, 3,
    7, 6, 2,
    // Right
    0, 4, 1,
    4, 1, 5,
    // Top
    6, 2, 1,
    1, 6, 5,
    // Bottom
    0, 3, 7,
    0, 7, 4
};

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // initialize
        [self setupLayer];
        [self setupContext];
#if SH
        [Shader compileShaders];
#else
        [self compileShaders];
#endif
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

float z = -1;
float rotateX = 0;
float rotateY = 0;
float rotateZ = 0;

- (void)render:(CADisplayLink*)displayLink {

    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    //glClear(GL_COLOR_BUFFER_BIT);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    // projection matrix
    float aspect = fabsf(self.frame.size.width / self.frame.size.height);
    GLKMatrix4 projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
#if SH
    glUniformMatrix4fv([Shader projectionMatrixSlot], 1, 0, projection.m);
#else
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.m);
#endif
    
    // modelview matrix
    // - transform
    z -= 0.01;
    GLKMatrix4 modelView = GLKMatrix4MakeTranslation(0, 0, z);
    
    // - rotation
    rotateX += 0.1;
    rotateY += 0.2;
    rotateZ += 0.3;
    modelView = GLKMatrix4Rotate(modelView, rotateX, rotateY, rotateZ, 1);
    
#if SH
    glUniformMatrix4fv([Shader modelViewMatrixSlot], 1, 0, modelView.m);
#else
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.m);
#endif
    
    // 1
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    // 2
#if SH
    [mesh draw:[Shader positionSlot] colorHandle:[Shader colorSlot]];
#else
    [mesh draw:_positionSlot colorHandle:_colorSlot];
#endif
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark compile shaders
#if SH
#else
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (void)compileShaders {
    
    // 1
    GLuint vertexShader = [self compileShader:@"vertex"
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"fragment"
                                       withType:GL_FRAGMENT_SHADER];
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    
}
#endif // SH

#pragma mark buffer objects

- (void)setupVBOs {
 
    VertexBuffer* vertexBuffer = [[VertexBuffer alloc] initWithWithVertices:Vertices size:sizeof(Vertices)];
    IndexBuffer* indexBuffer = [[IndexBuffer alloc] initWithIndices:Indices size:sizeof(Indices)];
    
    mesh = [[Mesh alloc] init];
    [mesh setIndexBuffer:indexBuffer];
    [mesh setVertexBuffer:vertexBuffer];
 
}

@end
