#import "HGLObject3D.h"
#import "HGLVector3.h"
#import "HGLTexture.h"
#import <map>
#import <string>

typedef struct t_draw {
    t_draw():
        object3D(NULL),
        texture(NULL),
        scale(1,1,1),
        color({1,1,1,1}),
        position(0,0,0),
        rotate(0,0,0),
        blend1(GL_SRC_ALPHA),
        blend2(GL_ONE_MINUS_SRC_ALPHA),
        isAlphaMap(0),
        alpha(1),
        lookToCamera(1),
        textureW(0),
        textureH(0),
        textureRepeatNum(1),
        textureMatrix(GLKMatrix4Identity)
    {}
    HGLObject3D* object3D;
    HGLTexture* texture;
    HGLVector3 scale;
    HGLVector3 position;
    HGLVector3 rotate;
    unsigned int blend1;
    unsigned int blend2;
    float isAlphaMap;
    float alpha;
    bool lookToCamera;
    GLKMatrix4 textureMatrix;
    Color color;
    short textureW;
    short textureH;
    short textureRepeatNum;
} t_draw;

// 3dやテクスチャなどのデータを読み込む
#warning 後で適切な場所に移すことを検討
void HGLoadData();

class HGActor
{
public:
    HGActor():
        velocity(0),
        aspect(0),
        radian(0),
        moveAspect(0),
        scale(1,1,1),
        rotate(0,0,0),
        position(0,0,0),
        acceleration(0,0,0),
        object3d(NULL),
        useLight(false),
        alpha(1.0),
        drawCounter(1),
        textureRepeatNum(1),
        lookToCamera(true),
        blend1(GL_SRC_ALPHA),
        blend2(GL_ONE_MINUS_SRC_ALPHA),
        texture(NULL){}
    
    virtual void draw() = 0;
    void move();
    void setVelocity(float velocity);
    virtual void setAspect(float degree);
    void setObject3D(HGLObject3D* obj);
    void setObject3D(HGLObject3D* obj, HGLTexture* tex);
    void setMoveAspect(float degree);
    
    ~HGActor();
    
    HGLVector3 position;
    HGLVector3 rotate;
    HGLVector3 scale;
    float velocity; // 速度
    float aspect; // degree
    float radian;
    float moveAspect; // radian
    float alpha; // alpha
    float textureRepeatNum;
    unsigned int drawCounter;
    bool lookToCamera;
    unsigned int blend1;
    unsigned int blend2;
    
#warning 後で適切な場所に移すことを検討
    static std::map<std::string, HGLObject3D*> object3DTable;
    static std::map<std::string, HGLTexture*> textureTable;
    
protected:
    bool useLight; // 光源
    HGLTexture* texture;
    HGLObject3D* object3d; // 3Dオブジェクト
    
    t_draw s_draw1;
    t_draw s_draw2;
    t_draw s_draw3;
    HGLVector3 acceleration; // 加速
    // スプライト処理用
    GLKMatrix4 textureMatrix;
    
    void draw(t_draw* p);
    
};
