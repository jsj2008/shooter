//
//  CellManager.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/26.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__CellManager__
#define __Shooter__CellManager__

#include <iostream>
#include "HGameEngine.h"
#include "HTypes.h"

namespace hg {

    ////////////////////
    // あたり判定
    template <class T>
    class CellManager : HGObject
    {
    public:
        typedef std::list<T*> ActorList;
        typedef std::vector<ActorList> CellList;
        typedef std::list<int> CellNumberList;
        CellManager(HGSize fieldSize):
        fieldSize(fieldSize)
        {
            list.resize(CELL_SPLIT_NUM*CELL_SPLIT_NUM);
            CELL_SPLIT_NUM = 10;
            sizeOfCell = {fieldSize.width/CELL_SPLIT_NUM, fieldSize.height/CELL_SPLIT_NUM};
        }
        void clear()
        {
            //for_each(list.begin(), list.end(), Clear());
            for (typename CellList::iterator it = list.begin(); it != list.end(); it++)
            {
                (*it).clear();
            }
        }
        inline void addToCellList(T* actor)
        {
            HGPoint tmpPos = {actor->getPositionX(), actor->getPositionY()};
            float halfWidth = actor->getWidth()/2;
            float halfHeight = actor->getHeight()/2;
            tmpPos.x -= halfWidth;
            tmpPos.y -= halfHeight;
            int beforeNum = -1;
            while (1)
            {
                int num = getCellNumber(tmpPos);
                if (num > 0 && num > beforeNum)
                {
                    list[num].push_back(actor);
                }
                beforeNum = num;
                tmpPos.x += sizeOfCell.width;
                if (tmpPos.x > actor->getPositionX() + halfWidth)
                {
                    if (tmpPos.y + sizeOfCell.height > actor->getPositionY() + halfHeight)
                    {
                        break;
                    }
                    else
                    {
                        tmpPos.x = actor->getPositionX() - halfWidth;
                        tmpPos.y += sizeOfCell.height;
                    }
                }
            }
        }
        inline int getNumberInCell(int x, int y)
        {
            int cell = x + y * CELL_SPLIT_NUM;
            if (cell < 0 || cell >= CELL_SPLIT_NUM*CELL_SPLIT_NUM)
            {
                return 0;
            }
            return list[cell].size();
        }
        inline ActorList* getNearbyTargetList(float x, float y)
        {
            HGPoint p = {x, y};
            int cell = getCellNumber(p);
            if (cell < 0 || cell >= CELL_SPLIT_NUM*CELL_SPLIT_NUM)
            {
                return NULL;
            }
            if (list[cell].size() > 0)
            {
                return &list[cell];
            }
            std::vector<int> numList;
            numList.reserve(8);
            numList.push_back(cell - 1);
            numList.push_back(cell + 1);
            for (int i = 0, tmp = cell - CELL_SPLIT_NUM - 1; i < 3; i++)
            {
                numList.push_back(tmp + i);
            }
            for (int i = 0, tmp = cell + CELL_SPLIT_NUM - 1; i < 3; i++)
            {
                numList.push_back(tmp + i);
            }
            random_shuffle(numList.begin(), numList.end(), Random());
            for (std::vector<int>::iterator it = numList.begin(); it != numList.end(); ++it)
            {
                int tmp = *it;
                if (tmp < 0 || tmp >= CELL_SPLIT_NUM*CELL_SPLIT_NUM)
                {
                    continue;
                }
                if (list[tmp].size() > 0)
                {
                    return &list[tmp];
                }
            }
            
            return NULL;
        }
        
        inline const ActorList& getActorList(int cellNumber)
        {
            return list[cellNumber];
        }
        inline void GetCellList(HGRect rect, CellNumberList &list)
        {
            HGPoint tmpPos = {rect.point.x, rect.point.y};
            int beforeNum = -1;
            while (1)
            {
                int num = getCellNumber(tmpPos);
                if (num > 0 && num > beforeNum)
                {
                    list.push_back(num);
                }
                beforeNum = num;
                tmpPos.x += sizeOfCell.width;
                if (tmpPos.x > rect.point.x + rect.size.width)
                {
                    if (tmpPos.y + sizeOfCell.height > rect.point.y + rect.size.height)
                    {
                        break;
                    }
                    else
                    {
                        tmpPos.y += sizeOfCell.height;
                        tmpPos.x = rect.point.x;
                    }
                }
            }
        }
    private:
        struct Clear {
            void operator()(ActorList cell) { cell.clear(); }
        };
        CellList list;
        int CELL_SPLIT_NUM = 10;
        HGSize fieldSize = {0,0};
        HGSize sizeOfCell = {0,0};
        int getCellNumber(HGPoint& s)
        {
            if (s.x < 0 || s.y < 0)
            {
                return -1;
            }
            if (s.x > fieldSize.width || s.y > fieldSize.height)
            {
                return -1;
            }
            int wx = (int)(s.x / sizeOfCell.width);
            int wy = (int)(s.y / sizeOfCell.height);
            return wx + wy * CELL_SPLIT_NUM;
        }
    };
    
}

#endif /* defined(__Shooter__CellManager__) */
