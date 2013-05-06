//
//  CallFunctionRepeatedlyProcess.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/03.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__CallFunctionRepeatedlyProcess__
#define __Shooter__CallFunctionRepeatedlyProcess__

#include <iostream>
#include "HGameEngine.h"
#include "HActor.h"

namespace hg {
    
    template <class T>
    class CallFunctionRepeadedlyProcess : public HGProcess
    {
    public:
        typedef HGProcess base;
        CallFunctionRepeadedlyProcess() :
        base(),
        actor(NULL)
        {
        };
        void init(HGProcessOwner* pProcOwner, bool (T::*func)(), T* actor)
        {
            base::init(pProcOwner);
            this->func = func;
            this->actor = actor;
            actor->retain();
        }
        ~CallFunctionRepeadedlyProcess()
        {
            if (actor)
            {
                actor->release();
            }
            //this->~HGProcess();
        }
    protected:
        void onUpdate()
        {
            assert(!this->isEnd());
            if ((actor->*func)())
            {
                this->setEnd();
            }
        }
        std::string getName()
        {
            return "CallFunctionRepeadedlyProcess";
        }
    private:
        bool (T::*func)();
        T* actor;
        
    };
}

#endif /* defined(__Shooter__CallFunctionRepeatedlyProcess__) */
