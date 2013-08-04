//
//  HFighter.cpp
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/03.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#include "HFighter.h"

namespace hg {

    float getPositionX(Fighter* fighter)
    {
        return fighter->getPositionX();
    }
    float getPositionY(Fighter* fighter)
    {
        return fighter->getPositionY();
    }
    void retainFighter(Fighter* fighter)
    {
        fighter->retain();
    }
    void releaseFighter(Fighter* fighter)
    {
        fighter->release();
    }
    
}