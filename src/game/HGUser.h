#ifndef INC_HGUESR
#define INC_HGUESR

#import "HGCommon.h"
#import "HGFighter.h"
#import <vector>
#import <string>

namespace HGGame {
    
namespace userinfo {
    
    typedef struct t_user
    {
        
        
    } t_user;
    
    typedef struct t_fighter
    {
        HG_FIGHTER_TYPE type;
        int life;
        int maxLife;
        int level;
        int exp;
        int expNext;
        int player;
        int battle;
        std::string name;
    } t_fighter;
    
    typedef std::vector<t_fighter> t_fighter_list;
    
    extern t_user* current_user;
    
    extern t_fighter_list* current_fighter_list;
    
    void loadData();
    
}}
#endif