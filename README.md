# GSSqlHelper
GSSqlHelper is a sql helper class. Be similar to SQLiteHelper class in Android.

It use FMDB to support operate sqlite.

In iOS SDK,I can not find a class that can create or upgrate database like SQLiteHelper in Android, So I do it.

Usage
==============
You can use GSSqlHelper directly ,but I strongly propose inherit it.

### CocoaPods

1. Update cocoapods to the latest version.
1. Add pod 'GSSqlHelper' to your Podfile.

```cpp
TestDbHelper.h
#import "GSSqlHelper.h"
@interface TestDbHelper : GSSqlHelper
+(TestDbHelper *)instances;
@end


TestDbHelper.m
#import "TestDbHelper.h"
@implementation YBTDbHelper
- (void)onCreateDb:(FMDatabase *)db{
	//when create a new db, this method will be call.
}
- (void)onUpgradeDb:(FMDatabase *)db FromOldDbVersion:(NSInteger)oldVersion toNewDbVersion:(NSInteger)newVersion{
	//when db need to upgrade,this method will be call.
}
+(TestDbHelper *)instances{
	static TestDbHelper *dbHelper;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken,^{
        NSString *strDbName = @"testDb";
        NSInteger newDbVersion = 0;
        NSString *dbname = [NSString stringWithFormat:@"%@",strDbName];
        dbHelper = [[TestDbHelper alloc]initWithDbName:dbname Version:newDbVersion];
    });
    return dbHelper;
}

TestDbHelper *dbhelper = [TestDbHelper instances];
 [dbhelper.dbQueue inDatabase:^(FMDatabase *db) {
 		//operate db here.
 }
```
