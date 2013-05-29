//
//  HActorList.h
//  Shooter
//
//  Created by 濱田 洋太 on 13/05/05.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#ifndef __Shooter__HActorList__
#define __Shooter__HActorList__

#include <iostream>
#include <vector>

namespace hg {
    
    // 関数オブジェクト
    template <class T>
    class ActorIsActive
    {
    public:
        bool operator()(T* t) const {
            if (t->isActive())
            {
                return false;
            }
            else
            {
                t->release();
                return true;
            }
        }
    };
    
    template <class T>
    class ActorList
    {
        typedef std::vector<T*> List;
    public:
        typedef typename List::iterator iterator;
        ActorList()
        {
            list.reserve(300);
        }
        
        void removeInactiveActors()
        {
            typename List::iterator end_it = remove_if( list.begin(), list.end(), ActorIsActive<T>() );
            if (end_it != list.end())
            {
                list.erase( end_it, list.end() );
            }
        }
        
        void removeAllActor()
        {
            if (list.size() > 0)
            {
                for (typename List::iterator it = list.begin(); it != list.end(); ++it)
                {
                    (*it)->release();
                }
                list.clear();
            }
        }
        
        void addActor(T* t)
        {
            t->retain();
            list.push_back(t);
        }
        
        void removeActor(T* t)
        {
            // ********************
            // std::remove doesn't change the size of the container, it just moves the contents around
            // ********************
            list.erase(std::remove(list.begin(), list.end(), t), list.end());
            t->release();
        }
        
        T* getRandomActor()
        {
            if (list.size() <= 0)
            {
                return NULL;
            }
            int i = rand(0, list.size() - 1);
            return list[i];
        }
        
        iterator begin()
        {
            return list.begin();
        }
        
        iterator end()
        {
            return list.end();
        }
        
        int size()
        {
            return list.size();
        }
        
    private:
        List list;
        
    };
}

#endif /* defined(__Shooter__HActorList__) */
