#import "GLTypes.h"

float s2f(const std::string* str)
{
    return (float)atof(str->c_str());
}

int s2i(const std::string* str)
{
    return atoi(str->c_str());
}
