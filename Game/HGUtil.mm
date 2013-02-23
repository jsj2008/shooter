#import "HGUtil.h"

static int SPRITE_INDEX_TABLE[359];

// テーブル初期化
void initSpriteIndexTable()
{
    int index = 0;
    for (int i = 0; i < 360; i++)
    {
        index = 0;
        if (i >= 338 || i <= 23) {
            index = 2;
        } else if (i >= 23 && i <= 68) {
            index = 3;
        } else if (i >= 68 && i <= 113) {
            index = 4;
        } else if (i >= 113 && i <= 158) {
            index = 5;
        } else if (i >= 158 && i <= 203) {
            index = 6;
        } else if (i >= 203 && i <= 248) {
            index = 7;
        } else if (i >= 248 && i <= 293) {
            index = 0;
        } else if (i >= 293 && i <= 338) {
            index = 1;
        }
        SPRITE_INDEX_TABLE[i] = index;
    }
}

int getSpriteIndex(int i)
{
    while (i < 0)
    {
        i += 360;
    }
    i = i % 360;
    return SPRITE_INDEX_TABLE[i];
}
