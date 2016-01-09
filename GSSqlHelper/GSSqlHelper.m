//
//  GSSqlHelper.m
//  GSSqlHelper
//
//  Created by gscool on 16/1/8.
//  Copyright © 2016年 gs. All rights reserved.
//

#import "GSSqlHelper.h"

#define kDBVersionTable @"versionTable"
#define kColumnVersion @"cVersion"

#ifdef DEBUG
#define SHOWLOG(format,...) NSLog(format,##__VA_ARGS__)
#else
#define SHOWLOG(format,...) nil
#endif
@implementation GSSqlHelper

- (id)initWithDbName:(NSString *)dbName andDbVersion:(NSInteger)dbVersion{
    self = [super init];
    if (!self) return nil;
    
    _dbName = dbName;
    _dbVersion = dbVersion;
    [self createDB];
    return self;
}

- (FMDatabaseQueue *)dbQueue{
    if (!_dbQueue) {
        NSString *dbPath = [self getDBPathWithName:_dbName];
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbPath];
    }
    
    return _dbQueue;
}

- (void)createDB{
    NSString *dbPath = [self getDBPathWithName:_dbName];
    SHOWLOG(@"create db to : %@",dbPath);
    m_db = [FMDatabase databaseWithPath:dbPath];
    NSInteger oldDBVersion = [self getDBVersion];
    __weak __typeof(self)weakSelf = self;
    if (oldDBVersion == 0) {
        SHOWLOG(@"Old database version is zero. create new database");
        [self createVersionTable];
        if ([self respondsToSelector:@selector(onCreateDb:)]) {
            [self.dbQueue inDatabase:^(FMDatabase *db) {
                [weakSelf onCreateDb:db];
            }];
        }
    }else{
        if (_dbVersion > oldDBVersion) {
            if ([self respondsToSelector:@selector(onUpgradeDb:FromOldDbVersion:toNewDbVersion:)]) {
                [self.dbQueue inDatabase:^(FMDatabase *db) {
                    [weakSelf onUpgradeDb:db FromOldDbVersion:oldDBVersion toNewDbVersion:_dbVersion];
                }];
            }
            SHOWLOG(@"upgrade database version to:%ld",(long)_dbVersion);
            [self updateDbVersion:_dbVersion];
        }
    }
}


-(BOOL)isExistsTable:(NSString *)tableName{
    __block BOOL ret = NO;
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", tableName];
        while ([rs next]){
            NSInteger count = [rs intForColumn:@"count"];
            if (0 == count){
                ret = NO;
            }else{
                ret = YES;
            }
        }
        [rs close];
    }];
    return ret;
}

-(NSString *)getDBPath{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return path;
}

-(NSString *)getDBPathWithName:(NSString *)DBName{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:DBName];
    return path;
}

- (NSInteger)getDBVersion{
    __block NSInteger version = 0;
    if ([self isExistsTable:kDBVersionTable]) {
        [_dbQueue inDatabase:^(FMDatabase *db) {
            NSString *sql = [NSString stringWithFormat:@"select * from  %@",kDBVersionTable];
            FMResultSet *set = [db executeQuery:sql];
            if ([set next]) {
                version = [set intForColumn:kColumnVersion];
            }
            [set close];
        }];
    }else{
        return 0;
    }
    return version;
}

- (void)createVersionTable{
    NSInteger newVersion = [[[NSBundle mainBundle]objectForInfoDictionaryKey:@"DBVersion"]integerValue];
    NSNumber *numberVersion = [NSNumber numberWithInteger:newVersion];
    if ([self isExistsTable:kDBVersionTable]) {
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            NSString *updatesql = [NSString stringWithFormat:@"update %@ set %@=?",kDBVersionTable,kColumnVersion];
            NSString *selectSql = [NSString stringWithFormat:@"select * from %@", kDBVersionTable];
            
            FMResultSet *set = [db executeQuery:selectSql];
            NSInteger count = 0;
            if ([set next]) {
                count = [set intForColumnIndex:0];
            }
            
            [set close];
            if (count > 0 ) {
                [db executeUpdate:updatesql,numberVersion];
            }else{
                NSString *sql = [NSString stringWithFormat:@"insert into %@(%@) values(?)",kDBVersionTable,kColumnVersion];
                [db executeUpdate:sql,numberVersion];
            }
        }];
        
    }else{
        NSString *sql = [NSString stringWithFormat:@"CREATE Table %@(%@ integer)",kDBVersionTable,kColumnVersion];
        //[m_db executeUpdate:sql];
        NSString *insertsql = [NSString stringWithFormat:@"insert into %@(%@) values(?)",kDBVersionTable,kColumnVersion];
        //[m_db executeUpdate:sql,numberVersion];
        [self.dbQueue inDatabase:^(FMDatabase *db) {
            [db executeUpdate:sql];
            [db executeUpdate:insertsql,numberVersion];
        }];
    }

}

-(void)updateDbVersion:(NSInteger)version{
    NSNumber *numberVersion = [NSNumber numberWithInteger:version];
    [self.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *updatesql = [NSString stringWithFormat:@"update %@ set %@=?",kDBVersionTable,kColumnVersion];
        [db executeUpdate:updatesql,numberVersion];
    }];
}
@end
