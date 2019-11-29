//
//  KLWriteToFileManger.m
//  KLDataSave
//
//  Created by WKL on 2019/11/26.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "KLWriteToFileManger.h"

@implementation KLWriteToFileManger
static KLWriteToFileManger *_manager = nil ;

+(instancetype)shareManager{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[super allocWithZone:NULL]init] ;
        //不是使用alloc方法，而是调用[[super allocWithZone:NULL] init]
        //已经重载allocWithZone基本的对象分配方法，所以要借用父类（NSObject）的功能来帮助出处理底层内存分配的杂物
    });
    
    return _manager ;
}

+(id)alloc{
    NSLog(@"alloc");
    return [super alloc];
}

//用alloc返回也是唯一实例
+(id) allocWithZone:(struct _NSZone *)zone {
    
    NSLog(@"allocWithZone");
    return [KLWriteToFileManger shareManager] ;
}
//对对象使用copy也是返回唯一实例
-(id)copyWithZone:(NSZone *)zone {
    NSLog(@"copyWithZone");
    
    return [KLWriteToFileManger shareManager] ;
}
//对对象使用mutablecopy也是返回唯一实例
-(id)mutableCopyWithZone:(NSZone *)zone {
    return [KLWriteToFileManger shareManager] ;
}


-(void)writeToFiled:(NSString*)appendPath data:(id)data{
    
    
    //第一个参数：要查询的文件的路径
    //第二个参数：要查询路径所属的用户 iOS是单用户
    //第三个参数的意思 YES是绝对路径 NO是相对路径
    //区别于OS-X系统 iOS应用文件夹中通常只有一个文件路径 由于OC同时支持的苹果系列产品的开发 在MacOS里面会同时存在很多软件 通常生成的路径放在一个数组里面
    //iOS端一次只有一个应用 所以取数组唯一的一个元素即可
    //writetofile 保存的数组和字典是以plist格式书写的
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask ,YES).firstObject;
    
    NSString *filePath = [documentPath stringByAppendingString:appendPath];
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil] ;
    }
    
    NSError *error ;
    BOOL isSuccess =   NO;
    
    if ([data isKindOfClass:[NSString class]]) {
        isSuccess =   [data writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    }else if([data isKindOfClass:[NSArray class]] || [data isKindOfClass:[NSDictionary class]]  || [data isKindOfClass:[NSData class]]){
        isSuccess = [data writeToFile:filePath atomically:YES];
    }
    
    if (isSuccess && error == nil) {
        NSLog(@"成功") ;
    }
    else{
        
        NSLog(@"error == %@",error) ;
    }
    
}


-(void)writeAddToFiled:(NSString*)appendPath data:(id)data{
  
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask ,YES).firstObject;
    
    NSString *filePath = [documentPath stringByAppendingString:appendPath];
    
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager]createFileAtPath:filePath contents:nil attributes:nil] ;
    }
    
    
    NSData *rData = nil ;
    
    if ([data isKindOfClass:[NSData class]]) {
        rData = data ;
    }else  if ([data isKindOfClass:[NSArray class]] || [data isKindOfClass:[NSDictionary class]]) {
        rData = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:nil];
        
    }else if ([data isKindOfClass:[NSString class]]){
        rData = [data dataUsingEncoding:NSUTF8StringEncoding] ;
    }
    
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath] ;
    if (fileHandle) {
        [fileHandle seekToEndOfFile];
        [fileHandle writeData:rData] ;
        [fileHandle closeFile];
    }
    
}


-(NSString*)getPathWithPrefix:(NSString*)prefix{
    
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask ,YES).firstObject;

    
    return [documentPath stringByAppendingString:prefix] ;
    
}
#pragma mark - 归档解归档

-(void)archiveObject:(id)object prefix:(NSString *)prefix {
    if (!object)
        return ;
    
    //会调用对象的encodeWithCoder方法

    if (@available(iOS 11.0, *)) {
           NSError *error ;
           
           NSData *data = [NSKeyedArchiver  archivedDataWithRootObject:object requiringSecureCoding:YES error:&error] ;
           
           if (error) {
               return;
           }
           
           [data writeToFile:[self getPathWithPrefix:prefix] atomically:YES];

       }else{
           
           BOOL isSuccess = [NSKeyedArchiver archiveRootObject:object toFile:[self getPathWithPrefix:prefix]];
           if (isSuccess) {
               NSLog(@"Success") ;
           }
           
       }
    
 
}

- (id)unarchiveClass:(Class)class prefix:(NSString *)prefix {
    
    //会调用对象的initWithCoder方法
    
    NSData *data = [NSData dataWithContentsOfFile:[self getPathWithPrefix:prefix]] ;
    
    if (@available(iOS 11.0, *)) {
        NSError *error ;
        
        id content = [NSKeyedUnarchiver unarchivedObjectOfClass:class fromData:data error:&error];
        if (error) {
               return nil;
           }
        return content;
        
    } else {
        //Fallback on earlier versions
        
        //       id content = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        id content = [NSKeyedUnarchiver unarchiveObjectWithFile:[self getPathWithPrefix:prefix]];
        return content;

     }
 
 }

@end
