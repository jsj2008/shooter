
enum HG_FIGHTER_TYPE {
    HG_FIGHTER_N1
};

class HGActor;
class HGFighter : public HGActor
{
public:
    HGFighter();
    void draw();
    void init(HG_FIGHTER_TYPE type);
    
private:
    
    // 描画用関数
    void (HGFighter::*pDrawFunc)();
    
    // 初期化用関数
    void (HGFighter::*pInitFunc)();
    
    // 種類別関数群
    void N1Draw();
    void N1Init();
    
};
