#import <string>

typedef struct Position
{
    float position[3];
} Position;

typedef struct UV
{
    float uv[2];
} UV;

typedef struct Normal
{
    float normal[3];
} Normal;

typedef struct Color
{
    float color[4];
} Color;

typedef short Index;

typedef struct VertexPC{
    VertexPC(Position p, Color c):position(p), color(c){}
    Position position;
    Color color;
} VertexPC;

typedef struct Vertex{
    Vertex(Position p, UV u, Normal n):position(p), uv(u), normal(n){}
    Position position;
    UV uv;
    Normal normal;
} Vertex;

float s2f(const std::string* str);

int s2i(const std::string* str);

bool operator==(Vertex p1, Vertex p2);
bool operator==(Position p1, Position p2);
bool operator==(Normal p1, Normal p2);
bool operator==(UV p1, UV p2);
