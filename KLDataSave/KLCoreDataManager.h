//
//  KLCoreDataManager.h
//  KLDataSave
//
//  Created by WKL on 2019/11/26.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

NS_ASSUME_NONNULL_BEGIN

@interface KLCoreDataManager : NSObject

/// 获取数据模型
/// @param entityName mode名
+ (__kindof NSManagedObject *)getTableWithEntityName:(NSString *)entityName;

/// 保存数据
+ (BOOL)save;


/// 删除数据
/// @param entityName model 名称
/// @param attribute 要删除model的属性名称
///@param searchString 属性名的值对应的字符串
+ (BOOL)deleteByEntityName:(NSString * _Nonnull)entityName
             withAttribute:(NSString * _Nonnull)attribute
               withMaching:(NSString * _Nonnull)searchString;


/// 修改数据
/// @param managedObject mode 对象
+ (BOOL)updateManagedObject:(NSManagedObject *)managedObject;


/// 查找数据
/// @param entityName model名称
/// @param attribute 要查找model的属性名称
/// @param searchString 属性的值对应的字符
/// @param sortArribute 按哪个属性名称排序
/// @param ascending 是否升序
+ (NSArray *)selectByEntityName:(NSString * _Nonnull)entityName
                  withAttribute:(NSString * _Nullable)attribute
                    withMaching:(NSString * _Nullable)searchString
                      sortingBy:(NSString * _Nullable)sortArribute
                    isAscending:(BOOL)ascending;

@end

NS_ASSUME_NONNULL_END
