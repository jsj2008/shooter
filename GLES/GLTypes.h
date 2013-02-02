#import <string>

typedef float Position[3];
typedef float UV[2];
typedef float Normal[3];
typedef float Color[4];

typedef short Index;

typedef struct VertexPC{
    float position[3];
    float color[4];
} VertexPC;

typedef struct Vertex{
    float position[3];
    float uv[2];
    float normal[3];
} Vertex;

float s2f(const std::string* str);

int s2i(const std::string* str);
