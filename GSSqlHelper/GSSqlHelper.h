//
//  GSSqlHelper.h
//  GSSqlHelper
//
//  Created by gscool on 16/1/8.
//  Copyright © 2016年 gs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@protocol GSSqlHelperInterface <NSObject>
@optional
- (void)onCreateDb:(FMDatabase *)db;
- (void)onUpgradeDb:(FMDatabase *)db FromOldDbVersion:(NSInteger)oldVersion toNewDbVersion:(NSInteger)newVersion;

@end

@interface GSSqlHelper : NSObject<GSSqlHelperInterface>{
    FMDatabase *m_db;
}

@property(nonatomic, copy, readonly)    NSString *dbName;
@property(nonatomic, assign, readonly)  NSInteger dbVersion;
@property(nonatomic, strong)            FMDatabaseQueue *dbQueue;

/**
 *  Initialize a 'GSSqlHelper' object
 *  If the verion is greatter than old database version,the onUpgradeDb:FromOldDbVersion:toNewDbVersion method will be call
 *
 *  @param dbName    An database name which will be create
 *  @param dbVersion version of database.
 *
 *
 */
- (id)initWithDbName:(NSString *)dbName andDbVersion:(NSInteger)dbVersion;


/**
 *  detect a table
 *
 *  @param tableName tableName
 *
 *  @return If the table which named tableName is exists,return YES.
 */
- (BOOL)isExistsTable:(NSString *)tableName;
@end
