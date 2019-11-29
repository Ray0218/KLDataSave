//
//  KLCoreDataManager.m
//  KLDataSave
//
//  Created by WKL on 2019/11/26.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "KLCoreDataManager.h"

@interface KLCoreDataManager ()

/**
 数据模型
 */
@property (nonatomic, strong) NSManagedObjectModel *objectModel;


/**
 持久化数据
 */
@property (nonatomic, strong) NSPersistentStoreCoordinator *coordinator;

/**
 管理数据的对象
 */
@property (nonatomic, strong) NSManagedObjectContext *objectContext;



@end

#define HJStrIsEmpty(str) ((str == nil) || ([str isEqualToString: @""]) || (str == NULL) ||     ([str isKindOfClass:[NSNull class]]))


@implementation KLCoreDataManager

static KLCoreDataManager *_manager = nil;

+(instancetype)shareManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[super allocWithZone:NULL]init] ;
        //不是使用alloc方法，而是调用[[super allocWithZone:NULL] init]
        //已经重载allocWithZone基本的对象分配方法，所以要借用父类（NSObject）的功能来帮助出处理底层内存分配的杂物
    });
    
    return _manager ;
}




- (instancetype)init
{
    self = [super init];
    if (self) {
        
        
        //创建托管对象模型
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"KLCoreModel" withExtension:@"momd"];
        
        if (@available(iOS 11.0,*)) {
            
        }else{
            url = [url URLByAppendingPathComponent:@"KLCoreModel.omo"] ;
        }
        
        _objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:url];
        //创建持久化数据协调器
        _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_objectModel];
        //关联并创建本地数据库文件
        
        
        //请求自动轻量级迁移
        //       NSDictionary *options = @{
        //          NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"},//禁用日志记录模式,即时的观察数据库的变化
        //          NSMigratePersistentStoresAutomaticallyOption :@YES, //试着把之前低版本的出现不兼容的持久化存储区迁移到新的模型中
        //NSInferMappingModelAutomaticallyOption:@YES//最合理的方式去尝试MappingModel，从源模型实体的某个属性，映射到目标模型实体的某个属性
        //        };
        
        //请求手动迁移,创建map文件
        NSDictionary *options = @{
            NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"},//禁用日志记录模式,即时的观察数据库的变化
            NSMigratePersistentStoresAutomaticallyOption :@YES, //试着把之前低版本的出现不兼容的持久化存储区迁移到新的模型中
            NSInferMappingModelAutomaticallyOption:@NO//最合理的方式去尝试MappingModel，从源模型实体的某个属性，映射到目标模型实体的某个属性
        };
        
        
        NSError *error ;
        [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self dbPath] options:options error:&error];
        //        [_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self dbPath] options:options error:&error];
        
        if (error == nil) {
            NSLog(@"数据库添加成功");
        } else {
            NSLog(@"数据库添加失败");
        }
        //创建托管对象上下文
        _objectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:(NSMainQueueConcurrencyType)];
        [_objectContext setPersistentStoreCoordinator:_coordinator];
    }
    return self;
}

+(id)alloc{
    NSLog(@"alloc");
    return [super alloc];
}

//用alloc返回也是唯一实例
+(id) allocWithZone:(struct _NSZone *)zone {
    
    NSLog(@"allocWithZone");
    return [KLCoreDataManager shareManager] ;
}
//对对象使用copy也是返回唯一实例
-(id)copyWithZone:(NSZone *)zone {
    NSLog(@"copyWithZone");
    
    return [KLCoreDataManager shareManager] ;
}
//对对象使用mutablecopy也是返回唯一实例
-(id)mutableCopyWithZone:(NSZone *)zone {
    return [KLCoreDataManager shareManager] ;
}


#pragma mark - 删除数据
+ (BOOL)deleteByEntityName:(NSString * _Nonnull)entityName
             withAttribute:(NSString * _Nonnull)attribute
               withMaching:(NSString * _Nonnull)searchString
{
    //没有输入删除条件
    if (HJStrIsEmpty(attribute) || HJStrIsEmpty(searchString)) {
        return YES;
    }
    //查询数据
    NSArray *array = [self selectByEntityName:entityName
                                withAttribute:attribute
                                  withMaching:searchString
                                    sortingBy:attribute
                                  isAscending:YES];
    if (array.count > 0) {
        //删除
        for (NSManagedObject *object in array) {
            [[KLCoreDataManager shareManager].objectContext deleteObject:object];
        }
        //执行保存操作
        return [KLCoreDataManager save];
    }
    return YES ;
    
}

#pragma mark - 更新数据
+ (BOOL)updateManagedObject:(NSManagedObject *)managedObject {
    [[KLCoreDataManager shareManager].objectContext refreshObject:managedObject mergeChanges:YES];
    return [KLCoreDataManager save];
}
#pragma mark - 查询数据
+ (NSArray *)selectByEntityName:(NSString * _Nonnull)entityName
                  withAttribute:(NSString * _Nullable)attribute
                    withMaching:(NSString * _Nullable)searchString
                      sortingBy:(NSString * _Nullable)sortArribute
                    isAscending:(BOOL)ascending{
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[KLCoreDataManager shareManager].objectContext];
    //创建fetch请求
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    fetchRequest.entity = entity;
    //一次性获取完
    [fetchRequest setFetchBatchSize:0];
    if (!HJStrIsEmpty(sortArribute)) {
        //排序
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:sortArribute ascending:ascending selector:nil];
        NSArray *descriptors = @[sortDescriptor];
        fetchRequest.sortDescriptors = descriptors;
    } else {
        fetchRequest.sortDescriptors = @[];
    }
    
    if (!HJStrIsEmpty(searchString) && !HJStrIsEmpty(attribute)) {
        //某个属性的值包含某个字符串
        //%K 某个属性的值
        //%@ 传递过来的字符串
        //模糊查询 contains[cd] 包含某个值 c标识忽略大小写，d标识忽略重音
        //查询 ==
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"%K == %@",attribute, searchString];
        // po  [NSPredicate predicateWithFormat:@"%K == %@",attribute, searchString]
        //        rAge == "20"
        //
        //        (lldb) po [NSPredicate predicateWithFormat:@"%@ == %@",attribute, searchString]
        //        "rAge" == "20"
    }
    NSError *error;
    NSFetchedResultsController *fetchedController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:[KLCoreDataManager shareManager].objectContext sectionNameKeyPath:nil cacheName:nil];
    //执行获取操作
    if ([fetchedController performFetch:&error]) {
        //获取数据
        return [fetchedController fetchedObjects];
    } else {
        return @[];
    }
}


#pragma mark - 保存数据
+ (BOOL)save {
    NSError *error;
    BOOL success = [[KLCoreDataManager shareManager].objectContext save:&error];
    if (error) {
         
        NSArray *errorsArr =  [error.userInfo objectForKey:@"NSDetailedErrors"] ;

        NSError *detail = errorsArr.firstObject ;
        NSLog(@"#######  NSValidationErrorKey = %@", [detail.userInfo objectForKey:@"NSValidationErrorKey"]);
    }
    return success;
}

#pragma mark - 获取数据模型
+ (__kindof NSManagedObject *)getTableWithEntityName:(NSString *)entityName {
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:[KLCoreDataManager shareManager].objectContext];
    return managedObject;
}

/**
 获取数据库路径
 
 @return return value description
 */
- (NSURL *)dbPath {
    
    NSURL *dbUrl = [[NSURL fileURLWithPath:[self dpFloder]] URLByAppendingPathComponent:@"db.sqlite"];
    return dbUrl;
}

-(NSString*)dpFloder {
    
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *dbFolder = [documentPath stringByAppendingPathComponent:@"CoreData"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dbFolder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dbFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    return dbFolder ;
    
}

/*
 
 #pragma mark- 通过代码进行数据迁移
 
 //是否需要合并
 - (BOOL)isMigrationNecessaryForStore:(NSURL*)storeUrl
 {
 NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
 
 if (![[NSFileManager defaultManager] fileExistsAtPath:[self dbPath].path])
 {
 NSLog(@"SKIPPED MIGRATION: Source database missing.");
 return NO;
 }
 
 NSError *error = nil;
 NSDictionary *sourceMetadata =
 [NSPersistentStoreCoordinator metadataForPersistentStoreOfType:NSSQLiteStoreType URL:storeUrl options:nil error:&error] ;
 
 
 NSManagedObjectModel *destinationModel = [KLCoreDataManager shareManager].coordinator.managedObjectModel;
 
 if ([destinationModel isConfiguration:nil compatibleWithStoreMetadata:sourceMetadata])
 {
 NSLog(@"SKIPPED MIGRATION: Source is already compatible");
 return NO;
 }
 
 return YES;
 }
 
 
 - (BOOL)migrateStore:(NSURL*)sourceStore {
 
 NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
 BOOL success = NO;
 NSError *error = nil;
 
 // STEP 1 - 收集 Source源实体, Destination目标实体 和 Mapping Model文件
 NSDictionary *sourceMetadata = [NSPersistentStoreCoordinator
 metadataForPersistentStoreOfType:NSSQLiteStoreType
 URL:sourceStore
 options:nil
 error:&error];
 
 NSManagedObjectModel *sourceModel =
 [NSManagedObjectModel mergedModelFromBundles:nil
 forStoreMetadata:sourceMetadata];
 
 NSManagedObjectModel *destinModel = [KLCoreDataManager shareManager].objectModel;
 
 NSMappingModel *mappingModel =
 [NSMappingModel mappingModelFromBundles:nil
 forSourceModel:sourceModel
 destinationModel:destinModel];
 
 // STEP 2 - 开始执行 migration合并, 前提是 mapping model 不是空，或者存在
 if (mappingModel) {
 NSError *error = nil;
 NSMigrationManager *migrationManager =
 [[NSMigrationManager alloc] initWithSourceModel:sourceModel
 destinationModel:destinModel];
 [migrationManager addObserver:self
 forKeyPath:@"migrationProgress"
 options:NSKeyValueObservingOptionNew
 context:NULL];
 
 
 
 NSURL *destinStore =
 [[NSURL fileURLWithPath:[self dpFloder]]
 URLByAppendingPathComponent:@"Temp.sqlite"];
 
 success =
 [migrationManager migrateStoreFromURL:sourceStore
 type:NSSQLiteStoreType options:nil
 withMappingModel:mappingModel
 toDestinationURL:destinStore
 destinationType:NSSQLiteStoreType
 destinationOptions:nil
 error:&error];
 if (success)
 {
 // STEP 3 - 用新的migrated store替换老的store
 //            if ([self replaceStore:sourceStore withStore:destinStore])
 //            {
 NSLog(@"SUCCESSFULLY MIGRATED %@ to the Current Model",
 sourceStore.path);
 [migrationManager removeObserver:self
 forKeyPath:@"migrationProgress"];
 //            }
 }
 else
 {
 NSLog(@"FAILED MIGRATION: %@",error);
 }
 }
 else
 {
 NSLog(@"FAILED MIGRATION: Mapping Model is null");
 }
 
 return YES; // migration已经完成
 }
 
 
 - (void)performBackgroundManagedMigrationForStore:(NSURL*)storeURL
 {
 NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
 
 dispatch_async(
 dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
 BOOL done = [self migrateStore:storeURL];
 if(done) {
 dispatch_async(dispatch_get_main_queue(), ^{
 NSError *error = nil;
 [KLCoreDataManager shareManager].store =
 [[KLCoreDataManager shareManager].coordinator addPersistentStoreWithType:NSSQLiteStoreType
 configuration:nil
 URL:[self dbPath]
 options:nil
 error:&error];
 if (error) {
 NSLog(@"Failed to add a migrated store. Error: %@",
 error);abort();}
 else {
 NSLog(@"Successfully added a migrated store: %@",
 [KLCoreDataManager shareManager].store );}
 });
 }
 });
 }
 
 
 - (void)loadStore
 {
 NSLog(@"Running %@ '%@'", self.class, NSStringFromSelector(_cmd));
 
 if (_store) {return;} // 不要再次加载了，因为已经加载过了
 
 BOOL useMigrationManager = YES;
 if (useMigrationManager &&
 [self isMigrationNecessaryForStore:[self dbPath]])
 {
 [self performBackgroundManagedMigrationForStore:[self dbPath]];
 }
 else
 {
 //自动迁移
 //请求手动迁移
 NSDictionary *options = @{
 NSSQLitePragmasOption: @{@"journal_mode": @"DELETE"},//禁用日志记录模式,即时的观察数据库的变化
 NSMigratePersistentStoresAutomaticallyOption :@YES, //试着把之前低版本的出现不兼容的持久化存储区迁移到新的模型中
 NSInferMappingModelAutomaticallyOption:@YES//最合理的方式去尝试MappingModel，从源模型实体的某个属性，映射到目标模型实体的某个属性
 };
 
 NSError *error = nil;
 _store = [_coordinator addPersistentStoreWithType:NSSQLiteStoreType
 configuration:nil
 URL:[self dbPath]
 options:options
 error:&error];
 if (!_store)
 {
 NSLog(@"###### Failed to add store. Error: %@", error);abort();
 }
 else
 {
 NSLog(@"####### Successfully added store: %@", _store);
 }
 }
 
 }
 
 - (void)observeValueForKeyPath:(NSString *)keyPath
 ofObject:(id)object
 change:(NSDictionary *)change
 context:(void *)context {
 
 if ([keyPath isEqualToString:@"migrationProgress"]) {
 
 dispatch_async(dispatch_get_main_queue(), ^{
 
 float progress =
 [[change objectForKey:NSKeyValueChangeNewKey] floatValue];
 
 int percentage = progress * 100;
 NSString *string =
 [NSString stringWithFormat:@"Migration Progress: %i%%",
 percentage];
 NSLog(@"%@",string);
 
 });
 }
 }
 */
@end
