
class HGRect
{
public:
    HGRect(float x, float y, float width, float height):
    x(x),
    y(y),
    width(width),
    height(height)
    {}
    float x;
    float y;
    float width;
    float height;
    
    bool isIntersect(HGRect* other);

};
