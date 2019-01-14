//
//  FlutterWKActionAPI.m
//  flutter_webview_plugin
//
//  Created by ashawn on 2019/1/4.
//

#import "FlutterWKActionAPI.h"

@implementation FlutterWKActionAPI

+ (instancetype)sharedInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSString*)module
{
    return @"action";
}

-(id)getToken:(id)param callback:(FlutterWACallback)callback
{
    NSString *code = @"{\"code\":1}";
    CALLBACK_AND_RETURN(code);
    
}

-(id)nativeShare:(id)param callback:(FlutterWACallback)callback
{
    NSString *code = @"{\"code\":1}";
    CALLBACK_AND_RETURN(code);
    
}

@end
