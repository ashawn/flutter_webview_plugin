//
//  FlutterWABaseAPIReflectionImpl.h
//
//  Created by AShawn on 19/1/1.
//  Copyright © 2018年 YY.inc. All rights reserved.

#import <Foundation/Foundation.h>
#import "FlutterWebAppAPI.h"

#define CALLBACK_AND_RETURN(p) \
if (callback) {         \
callback((p));      \
}   \
return (p);

/**
 *  反射实现invokeClientMethod:parameter:callback
 *  
 *  子类只需要按以下格式实现响应函数即可
 *  - (id)XXXX:(id)parameter callback:(YYWACallback)callback;   
 *  其中XXXX与invokeClientMethod:parameter:callback中的name对应
 */
@interface FlutterWABaseAPIReflectionImpl : NSObject <FlutterWebAppAPI>

@property(weak, nonatomic) id webView;

//- (id)invokeClientMethod:(NSString *)name parameter:(id)parameter callback:(YYWACallback)callback;

@end


//回调给web的数据格式，与安卓的处理一致，以后可以逐步迁移到这个格式。
//现在的接口只有在一些失败的情况才用到这个数据。
@interface FlutterWAResultData : NSObject
@property (nonatomic, assign) NSInteger code;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) id data;
+ (FlutterWAResultData *)successData;
- (instancetype)initWithCode:(NSInteger)code msg:(NSString *)msg;
- (NSDictionary *)info;
@end
