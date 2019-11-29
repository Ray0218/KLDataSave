//
//  KLUserModel.m
//  KLDataSave
//
//  Created by WKL on 2019/11/26.
//  Copyright © 2019 Ray. All rights reserved.
//

#import "KLUserModel.h"

@implementation KLUserModel


- (void)encodeWithCoder:(nonnull NSCoder *)coder {
    NSLog(@"encodeWithCoder");
    [coder encodeObject:_rName forKey:@"name"];
    [coder encodeInt:_rAge forKey:@"age"];
}

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)coder {
    if (self = [super init]) {
         
        NSLog(@"initWithCoder");
        
        self.rName = [coder decodeObjectForKey:@"name"];
        self.rAge = [coder decodeIntForKey:@"age"];

    }
    return self ;
}
+(BOOL)supportsSecureCoding{
    
    return YES ;
}

@end


