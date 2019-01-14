//
//  FlutterWebAppFramework.h
//
//  Created by AShawn on 19/1/1.
//  Copyright © 2018年 YY.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol FlutterWebAppAPI;

@class WADeviceAPI;
@class WAUserInterfaceAPI;

typedef void(^WAFResponseCallback)(id responseData);
typedef void(^WAFHandler)(NSDictionary *jsonObject, WAFResponseCallback responseCallback);

@interface FlutterWebAppBridge : NSObject <UIWebViewDelegate>
-(instancetype)initWithWebView:(id)webView;
- (BOOL)registerAPI:(id<FlutterWebAppAPI>)api forModule:(NSString *)module;
- (void)unregisterAPIForModule:(NSString *)module;
- (void)unregisterAllModuleAPIs;
- (void)webView:(id)webView handleAPIWithURL:(NSURL *)url;

@end

@interface FlutterWebAppFramework : NSObject
@property (nonatomic, readonly) BOOL isUseWKWebView;//是否使用WKWebView的开关
+ (instancetype)sharedInstance;

/**
 *  WebAppBridge Creation
 */
- (FlutterWebAppBridge *)instantiateBridgeForWebView:(UIWebView *)webView
                                webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate
                                     moduleAPIs:(NSArray *)moduleAPIs;

@end
