//
//  NSURL+Parameters.h
//  YYMobileFramework
//
//  Created by wuwei on 14-5-9.
//  Copyright (c) 2014年 YY Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Parameters)

@property (nonatomic, strong) NSDictionary *parameters;

- (NSString *)parameterForKey:(NSString *)key;

- (id)objectForKeyedSubscript:(id)key NS_AVAILABLE(10_8, 6_0);

@end
