//
//  KLWriteToFileManger.h
//  KLDataSave
//
//  Created by WKL on 2019/11/26.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


 @interface KLWriteToFileManger : NSObject

+(instancetype)shareManager;

/// 将 那是string nsdata nsarray nsdictionary 写入文件
/// @param appendPath 文件名称
/// @param data 写入数据
-(void)writeToFiled:(NSString*)appendPath data:(id)data;


/// 将数据写入文件末端
/// @param appendPath 文件名称
/// @param data 写入数据
-(void)writeAddToFiled:(NSString*)appendPath data:(id)data;


/// 归档
/// @param object mode实例
/// @param prefix 文件名称
-(void)archiveObject:(id)object prefix:(NSString *)prefix;


- (id)unarchiveClass:(Class)class prefix:(NSString *)prefix ;

@end

NS_ASSUME_NONNULL_END
