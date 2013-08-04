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

namespace userdata {
    
    FMDatabase* getDatabase();
    void initDatabase(FMDatabase* db);
    
    /////
    
    FMDatabase* getDatabase()
    {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* dir = [paths objectAtIndex:0];
        FMDatabase* db = [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"db.db"]];
        initDatabase(db);
        return db;
    }
    
    void initDatabase(FMDatabase* db)
    {
        NSString* sqla = @"create table if not exists tb_text(data_key text, data text)";
        std::stringstream ss;
        ss << "create table if not exists tb_fighter("
        << " id        integer primary key"
        << ",name      text"
        << ",type      integer"
        << ",power     integer"
        << ",life      integer"
        << ",lifeMax   integer"
        << ",shield    integer"
        << ",shieldMax integer"
        << ",exp       integer"
        << ",expNext   integer"
        << ",seed      integer"
        << ")";
        [db open];
        [db executeUpdate:sqla];
        [db close];
    }
    
    bool deleteAllTextData()
    {
        FMDatabase* db = getDatabase();
        if ([db beginTransaction] == false)
        {
            return false;
        }
        NSString* sql = @"delete from tb_text";
        bool ret = [db executeUpdate:sql];
        if (!ret)
        {
            [db rollback];
            NSLog(@"delete all Text Data failed.");
            return false;
        }
        if ([db commit])
        {
            return true;
        }
        [db rollback];
        NSLog(@"commit failed");
        return false;
    }
    
    std::string readTextData(const std::string& key)
    {
        FMDatabase* db = getDatabase();
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
    
    bool writeTextData(const std::string& key, const std::string& data)
    {
        FMDatabase* db = getDatabase();
        [db open];
        try {
            if ([db beginTransaction] == false)
            {
                throw "begin failed";
            }
            FMResultSet *results = [db executeQuery:@"select * from tb_text where data_key = ?", [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding]];
            bool ret = false;
            if ([results next])
            {
                NSString* sql = @"update tb_text set data = ? where data_key = ?";
                ret = [db executeUpdate:sql, [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding], [NSString stringWithCString:data.c_str() encoding:NSUTF8StringEncoding]];
            }
            else
            {
                NSString* sql = @"insert into tb_text values(?,?)";
                ret = [db executeUpdate:sql, [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding], [NSString stringWithCString:data.c_str() encoding:NSUTF8StringEncoding]];
            }
            if (!ret)
            {
                throw "write data failed";
            }
            if (![db commit])
            {
                throw "commit failed";
            }
            [db close];
            return true;
        } catch (char* err) {
            [db rollback];
            [db close];
            NSLog(@"Err:%@", [NSString stringWithCString:err encoding:NSUTF8StringEncoding]);
            return false;
        }
    }
    
    
}
