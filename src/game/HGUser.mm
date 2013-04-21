#import "HGUser.h"
#import <sstream>

namespace HGGame {
namespace userinfo {
    
    t_user* current_user;
    t_fighter_list* current_fighter_list;
    
    void loadData()
    {
        current_user = new t_user();
        current_fighter_list = new t_fighter_list();
        
        int a = 5;
        for (int i = 0; i < a; i++)
        {
            t_fighter f;
            if (i == 0)
            {
                f.player = 1;
            }
            else
            {
                f.player = 0;
            }
            f.type = HGF_PL1;
            f.life = 4000;
            f.maxLife =  1000;
            f.level = 1;
            f.battle = 1;
            std::stringstream ss;
            ss << "戦闘員" << (i + 1) << "号";
            f.name = ss.str();
            current_fighter_list->push_back(f);
        }
        
    }
    
}}
