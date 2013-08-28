//
//  UserDataManager.cpp
//  Shooter
//
//  Created by 濱田 洋太 on 13/08/04.
//  Copyright (c) 2013年 hayogame. All rights reserved.
//

#include "UserDataManager.h"
#include "FMDatabase.h"
#include <sstream>
#include "UserData.h"

namespace userdata {
    
    FMDatabase* getDatabase();
    void initDatabase(FMDatabase* db);
    bool deleteAllFighterData();
    
    FMDatabase* now_db = NULL;
    bool is_db_open = false;
    
    /////
    
    FMDatabase* getDatabase()
    {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* dir = [paths objectAtIndex:0];
        FMDatabase* db = [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"db.db"]];
        return db;
    }
    
    bool open()
    {
        now_db = getDatabase();
        if (now_db && [now_db open])
        {
            is_db_open = true;
            return true;
        }
        return false;
    }
    
    bool close()
    {
        return [now_db close];
    }
    
    bool begin()
    {
        return [now_db beginTransaction];
    }
    
    bool commit()
    {
        is_db_open = false;
        bool ret = [now_db commit];
        return ret;
    }
    
    bool rollback()
    {
        is_db_open = false;
        bool ret = [now_db rollback];
        return ret;
    }
    
    void initDatabase()
    {
        FMDatabase* db = getDatabase();
        NSString* sqla = @"create table if not exists tb_text(data_key text primary key, data text)";
        std::stringstream ss;
        ss << "create table if not exists tb_fighter("
        << " id            integer primary key"
        << ",record_type   integer"
        << ",fighter_type  integer"
        << ",name          text"
        << ",power         integer"
        << ",life          integer"
        << ",life_max      integer"
        << ",shield        integer"
        << ",shield_max    integer"
        << ",shield_heal   integer"
        << ",exp           integer"
        << ",exp_next      integer"
        << ",seed          integer"
        << ",is_ready      integer"
        << ",is_player     integer"
        << ",die_cnt       integer"
        << ",kill_cnt      integer"
        << ",total_die_cnt    integer"
        << ",total_kill_cnt   integer"
        << ",power_potential  integer"
        << ",def_potential    integer"
        << ",sld_potential    integer"
        << ",cpu_level     integer"
        << ",speed     integer"
        << ",level     integer"
        << ")";
        NSString* sqlb = [NSString stringWithCString:ss.str().c_str() encoding:NSUTF8StringEncoding];
        NSString* sqlc = @"create table if not exists tb_integer(data_key text primary key, data integer)";
        [db open];
        bool ret1 = [db executeUpdate:sqla];
        bool ret2 = [db executeUpdate:sqlb];
        bool ret3 = [db executeUpdate:sqlc];
        [db close];
    }
    
    void deleteDatabase()
    {
        FMDatabase* db = getDatabase();
        NSString* sqla = @"drop table tb_text";
        NSString* sqlb = @"drop table tb_fighter";
        NSString* sqlc = @"drop table tb_integer";
        [db open];
        bool ret1 = [db executeUpdate:sqla];
        bool ret2 = [db executeUpdate:sqlb];
        bool ret3 = [db executeUpdate:sqlc];
        [db close];
    }
    
    bool insertFighterInfo(int inc_id, int fighterRecordType, hg::FighterInfo* info)
    {
        assert(is_db_open);
        std::stringstream ss;
        ss << "insert into tb_fighter values("
           << " ?" // << " id            integer primary key"
           << ",?" // << ",record_type   integer"
           << ",?" // << ",fighter_type  integer"
           << ",?" // << ",name          text"
           << ",?" // << ",power         integer"
           << ",?" // << ",life          integer"
           << ",?" // << ",life_max      integer"
           << ",?" // << ",shield        integer"
           << ",?" // << ",shield_max    integer"
           << ",?" // << ",shield_heal   integer"
           << ",?" // << ",exp           integer"
           << ",?" // << ",exp_next      integer"
           << ",?" // << ",seed          integer"
           << ",?" // << ",is_ready      integer"
           << ",?" // << ",is_player     integer"
           << ",?" // << ",die_cnt       integer"
           << ",?" // << ",kill_cnt      integer"
           << ",?" // << ",total_die_cnt    integer"
           << ",?" // << ",total_kill_cnt   integer"
           << ",?" // << ",power_potential  integer"
           << ",?" // << ",def_potential    integer"
           << ",?" // << ",sld_potential    integer"
           << ",?" // << ",cpu_level    integer"
           << ",?" // << ",speed    integer"
           << ",?" // << ",level    integer"
        << ")"
        ;
        //return true;
        NSString* sql = [NSString stringWithCString:ss.str().c_str() encoding:NSUTF8StringEncoding];
        bool ret = [now_db executeUpdate:sql
                    ,[NSNumber numberWithInt:inc_id] // << " id            integer primary key"
                    ,[NSNumber numberWithInt:fighterRecordType] // << ",record_type   integer"
                    ,[NSNumber numberWithInt:info->fighterType] // << ",fighter_type  integer"
                    ,[NSString stringWithCString:info->name.c_str() encoding:NSUTF8StringEncoding] // << ",name          text"
                    ,[NSNumber numberWithInt:info->power] // << ",power         integer"
                    ,[NSNumber numberWithInt:info->life] // << ",life          integer"
                    ,[NSNumber numberWithInt:info->lifeMax] // << ",life_max      integer"
                    ,[NSNumber numberWithInt:info->shield] // << ",shield        integer"
                    ,[NSNumber numberWithInt:info->shieldMax] // << ",shield_max    integer"
                    ,[NSNumber numberWithInt:info->shieldHeal] // << ",shield_heal   integer"
                    ,[NSNumber numberWithInt:info->exp] // << ",exp           integer"
                    ,[NSNumber numberWithInt:info->expNext] // << ",exp_next      integer"
                    ,[NSNumber numberWithInt:info->seed] // << ",seed          integer"
                    ,[NSNumber numberWithInt:info->isReady] // << ",is_ready      integer"
                    ,[NSNumber numberWithInt:info->isPlayer] // << ",is_player     integer"
                    ,[NSNumber numberWithInt:info->dieCnt] // << ",die_cnt       integer"
                    ,[NSNumber numberWithInt:info->killCnt] // << ",kill_cnt      integer"
                    ,[NSNumber numberWithInt:info->totalDie] // << ",total_die_cnt    integer"
                    ,[NSNumber numberWithInt:info->totalKill] // << ",total_kill_cnt   integer"
                    ,[NSNumber numberWithInt:info->powerPotential] // << ",power_potential  integer"
                    ,[NSNumber numberWithInt:info->defencePotential] // << ",def_potential    integer"
                    ,[NSNumber numberWithInt:info->shieldPotential] // << ",shield_potential    integer"
                    ,[NSNumber numberWithInt:info->cpu_lv] // << ",cpu level integer"
                    ,[NSNumber numberWithInt:info->speed*10000] // << ",speed    integer"
                    ,[NSNumber numberWithInt:info->level] // << ",level    integer"
                    ];
        return ret;
    }
    
    hg::FighterList readFighter(int fighterRecordType)
    {
        assert(is_db_open);
        FMDatabase* db = now_db;
        FMResultSet *results = [db executeQuery:@"select * from tb_fighter where record_type = ?",
                                [NSNumber numberWithInt:fighterRecordType]];
        hg::FighterList list;
        while ([results next])
        {
            hg::FighterInfo* info = new hg::FighterInfo();
            
            // ",fighter_type  integer"
            NSNumber* fighterType = [results objectForColumnName:@"fighter_type"];
            info->fighterType = [fighterType intValue];
            // 気持ち悪いが・・直す時間がもったいないので。。。。。。。
            hg::UserData::sharedUserData()->setDefaultInfo(info, info->fighterType);
            
            {
                // ",name          text"
                NSString* name = [results objectForColumnName:@"name"];
                info->name = std::string([name UTF8String]);
            }
            
            {
                // ",power         integer"
                NSNumber* power = [results objectForColumnName:@"power"];
                info->power = [power intValue];
            }
            
            {
                // ",life          integer"
                NSNumber* life = [results objectForColumnName:@"life"];
                info->life = [life intValue];
            }
            
            {
                // ",life_max      integer"
                NSNumber* life_max = [results objectForColumnName:@"life_max"];
                info->lifeMax = [life_max intValue];
            }
            
            {
                // ",shield        integer"
                NSNumber* shield = [results objectForColumnName:@"shield"];
                info->shield = [shield intValue];
            }
            
            {
                // ",shield_max    integer"
                NSNumber* shield_max = [results objectForColumnName:@"shield_max"];
                info->shieldMax = [shield_max intValue];
            }
            
            {
                // ",exp           integer"
                NSNumber* exp = [results objectForColumnName:@"exp"];
                info->exp = [exp intValue];
            }
            
            {
                // ",exp_next      integer"
                NSNumber* expNext = [results objectForColumnName:@"exp_next"];
                info->expNext = [expNext intValue];
            }
            
            // ",seed          integer"
            {
                NSNumber* seed = [results objectForColumnName:@"seed"];
                info->seed = [seed intValue];
            }
            
            // ",is_ready      integer"
            {
                NSNumber* isReady = [results objectForColumnName:@"is_ready"];
                info->isReady = [isReady intValue];
            }
            
            // ",is_player     integer"
            {
                NSNumber* isPlayer = [results objectForColumnName:@"is_player"];
                info->isPlayer = [isPlayer intValue];
            }
            
            // ",die_cnt       integer"
            {
                NSNumber* die_cnt = [results objectForColumnName:@"die_cnt"];
                info->dieCnt = [die_cnt intValue];
            }
            
            // ",kill_cnt      integer"
            {
                NSNumber* kill_cnt = [results objectForColumnName:@"kill_cnt"];
                info->killCnt = [kill_cnt intValue];
            }
            
            // // ",total_die_cnt    integer"
            {
                NSNumber* total_die_cnt = [results objectForColumnName:@"total_die_cnt"];
                info->totalDie = [total_die_cnt intValue];
            }
            
            // ",total_kill_cnt   integer"
            {
                NSNumber* total_kill_cnt = [results objectForColumnName:@"total_kill_cnt"];
                info->totalKill = [total_kill_cnt intValue];
            }
            
            // ",power_potential  integer"
            {
                NSNumber* power_potential = [results objectForColumnName:@"power_potential"];
                info->powerPotential = [power_potential intValue];
            }
            
            // ",def_potential    integer"
            {
                NSNumber* def_potential = [results objectForColumnName:@"def_potential"];
                info->defencePotential = [def_potential intValue];
            }
            
            // ",sld_potential    integer"
            {
                NSNumber* sld_potential = [results objectForColumnName:@"sld_potential"];
                if (sld_potential  != nil && ![sld_potential isEqual:[NSNull null]]) {
                    info->shieldPotential = [sld_potential intValue];
                }
            }
            
            // ",cpu_level    integer"
            {
                NSNumber* cpu_level = [results objectForColumnName:@"cpu_level"];
                if (cpu_level  != nil && ![cpu_level isEqual:[NSNull null]]) {
                    info->cpu_lv = [cpu_level intValue];
                }
            }
            
            // ",speed    integer"
            {
                NSNumber* speed = [results objectForColumnName:@"speed"];
                if (speed  != nil && ![speed isEqual:[NSNull null]]) {
                    info->speed = [speed intValue] * 0.0001;
                }
            }
            
            // ",level    integer"
            {
                NSNumber* level = [results objectForColumnName:@"level"];
                if (level  != nil && ![level isEqual:[NSNull null]]) {
                    info->level = [level intValue];
                }
            }
            
            // end
            list.push_back(info);
        }
        return list;
    }
    
    bool deleteAllData()
    {
        if (!deleteAllFighterData()) return false;
        if (!deleteAllTextData()) return false;
        if (!deleteAllIntegerData()) return false;
        return true;
    }
    
    bool deleteAllFighterData()
    {
        assert(is_db_open);
        FMDatabase* db = now_db;
        NSString* sql = @"delete from tb_fighter";
        return [db executeUpdate:sql];
    }
    
    bool deleteAllTextData()
    {
        assert(is_db_open);
        FMDatabase* db = now_db;
        NSString* sql = @"delete from tb_text";
        return [db executeUpdate:sql];
    }
    
    std::string readTextData(const std::string& key)
    {
        assert(is_db_open);
        FMDatabase* db = now_db;
        [db open];
        FMResultSet *results = [db executeQuery:@"select * from tb_text where data_key = ?", [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding]];
        std::string ret = "";
        if ([results next])
        {
            ret = [[results stringForColumn:@"data"] cStringUsingEncoding:NSUTF8StringEncoding];
        }
        [db close];
        return ret;
    }
    
    bool updateOrInsertTextData(const std::string& key, const std::string& data)
    {
        assert(is_db_open);
        FMDatabase* db = now_db;
        FMResultSet *results = [db executeQuery:@"select * from tb_text where data_key = ?", [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding]];
        bool ret = false;
        if ([results next])
        {
            NSString* sql = @"update tb_text set data = ? where data_key = ?";
            ret = [db executeUpdate:sql, [NSString stringWithCString:data.c_str() encoding:NSUTF8StringEncoding], [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding]];
        }
        else
        {
            NSString* sql = @"insert into tb_text values(?,?)";
            ret = [db executeUpdate:sql, [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding], [NSString stringWithCString:data.c_str() encoding:NSUTF8StringEncoding]];
        }
        return ret;
    }
    
    bool deleteAllIntegerData()
    {
        assert(is_db_open);
        FMDatabase* db = now_db;
        NSString* sql = @"delete from tb_integer";
        return [db executeUpdate:sql];
    }
    
    long readIntegerData(const std::string& key)
    {
        assert(is_db_open);
        FMDatabase* db = now_db;
        [db open];
        FMResultSet *results = [db executeQuery:@"select * from tb_integer where data_key = ?", [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding]];
        long ret = 0;
        if ([results next])
        {
            ret = [results longForColumn:@"data"];
        }
        [db close];
        return ret;
    }
    
    bool updateOrInsertIntegerData(const std::string& k, const long& d)
    {
        assert(is_db_open);
        long data = d;
        std::string key = k;
        FMDatabase* db = now_db;
        FMResultSet *results = [db executeQuery:@"select * from tb_integer where data_key = ?", [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding]];
        bool ret = false;
        if ([results next])
        {
            NSString* sql = @"update tb_integer set data = ? where data_key = ?";
            ret = [db executeUpdate:sql, [NSNumber numberWithLong:data], [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding]];
        }
        else
        {
            NSString* sql = @"insert into tb_integer values(?,?)";
            ret = [db executeUpdate:sql, [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding], [NSNumber numberWithLong:data]];
        }
        return ret;
    }
    
}
