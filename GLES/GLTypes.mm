#import "GLTypes.h"

float s2f(const std::string* str)
{
    return (float)atof(str->c_str());
}

int s2i(const std::string* str)
{
    return atoi(str->c_str());
}

/*
bool operator==(Vertex p1, Vertex p2)
{
    return p1.position == p2.position;
}*/

bool operator==(Vertex p1, Vertex p2)
{
    return p1.position == p2.position
    && p1.uv == p2.uv
    && p1.normal == p2.normal;
}

bool operator==(Position p1, Position p2)
{
    return p1.x == p2.x
    && p1.y == p2.y
    && p1.z == p2.z;
}
bool operator==(Normal p1, Normal p2)
{
    return p1.x == p2.x
    && p1.y == p2.y
    && p1.z == p2.z;
}

bool operator==(UV p1, UV p2)
{
    return p1.s == p2.s
    && p1.t == p2.t;
}
