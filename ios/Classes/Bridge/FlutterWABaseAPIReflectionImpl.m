//
//  WABaseAPIReflectionImpl.m
//
//  Created by AShawn on 19/1/1.
//  Copyright © 2018年 YY.inc. All rights reserved.

#import "FlutterWABaseAPIReflectionImpl.h"

@implementation FlutterWABaseAPIReflectionImpl

- (NSString *)module
{
    return @"";
}

- (id)invokeClientMethod:(NSString *)name parameter:(id)parameter callback:(FlutterWACallback)callback
{
    NSLog(@"[+] WABaseAPIReflectionImpl invokeClientMethod(%@, %@, %@, %@)", self.module, name, parameter, callback);
    NSString *selectorName = [NSString stringWithFormat:@"%@:callback:", name];
    SEL selector = NSSelectorFromString(selectorName);
    if (![self respondsToSelector:selector])
    {
        return nil;
    }
    
    // Call the selector
    id result = nil;
    IMP imp = [self methodForSelector:selector];
    if (imp) {
        id(*func)(id, SEL, id, FlutterWACallback) = (void *)imp;
        result = func(self, selector, parameter, callback);
    }
    
    NSLog(@"[-] WABaseAPIReflectionImpl invokeClientMethod(%@, %@, %@, %@)", self.module, name, parameter, callback);

    return result;
}

@end

@implementation FlutterWAResultData

+ (FlutterWAResultData *)successData
{
    return [[FlutterWAResultData alloc] initWithCode:0 msg:@""];
}

- (instancetype)init
{
    return [self initWithCode:0 msg:@""];
}

- (instancetype)initWithCode:(NSInteger)code msg:(NSString *)msg
{
    self = [super init];
    if (self) {
        _code = code;
        _msg = [msg copy];
        _data = @"";
    }
    return self;
}

- (NSDictionary *)info
{
    NSDictionary *dic = @{@"code": @(self.code),
                          @"msg": self.msg,
                          @"data": self.data};
    return dic;
}

@end
