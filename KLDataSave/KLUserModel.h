//
//  KLUserModel.h
//  KLDataSave
//
//  Created by WKL on 2019/11/26.
//  Copyright © 2019 Ray. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KLUserModel : NSObject<NSSecureCoding>

@property(nonatomic,strong)NSString *rName;
@property(nonatomic,assign)int rAge;


@end

NS_ASSUME_NONNULL_END
