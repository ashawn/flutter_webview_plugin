//
//  FlutterWebAppFramework.m
//
//  Created by AShawn on 19/1/1.
//  Copyright © 2018年 YY.inc. All rights reserved.
//

#import "FlutterWebAppFramework.h"
#import "NSURL+Parameters.h"
#import <WebKit/WebKit.h>
#import "FlutterWebAppAPI.h"

static NSString * const kFlutterWebAppFrameworkProtocolScheme = @"yyapi";

#pragma mark - FlutterWebAppFramework Protected

@interface FlutterWebAppFramework ()

@end

#pragma mark - FlutterWebAppBridge

@interface FlutterWebAppBridge () <UIWebViewDelegate>

- (instancetype)initWithWebView:(UIWebView *)webView
                webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate;

@property (nonatomic, weak) FlutterWebAppFramework *webAppFramework;

@property (nonatomic, weak) id webView;
@property (nonatomic, weak) id<UIWebViewDelegate> webViewDelegate;

@property (nonatomic, assign) NSUInteger numRequestsLoading;

@property (nonatomic, strong, readonly) NSMutableDictionary *moduleAPIs;

- (void)_injectBridgeJavascript:(UIWebView *)webView;

- (id)_invokeWebMethod:(NSString *)name
             parameter:(id)parameter;

- (id)_invokeClientMethod:(NSString *)module
                     name:(NSString *)name
                parameter:(id)parameter
                 callback:(FlutterWACallback)callback;
- (id<FlutterWebAppAPI>)_apiForModule:(NSString *)module;

@end

#pragma mark - FlutterWebAppFramework Implementation

@interface FlutterWebAppFramework ()
@property (nonatomic, assign, readwrite) BOOL isUseWKWebView;
@end

@implementation FlutterWebAppFramework

+ (void)initialize {

    if (self == [FlutterWebAppFramework self]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{

            UIWebView *webView = [[UIWebView alloc] init];
            NSString *originalUA = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
            if ([originalUA rangeOfString:@"moschat_ios"].location == NSNotFound)
             {
                NSString *userAgentWithYYVersion = [originalUA stringByAppendingFormat:@"moschat_ios"];//加太多 payoneer 打不开
                NSDictionary *dictionnary = [[NSDictionary alloc] initWithObjectsAndKeys:userAgentWithYYVersion, @"UserAgent", nil];
                [[NSUserDefaults standardUserDefaults] registerDefaults:dictionnary];
             }
        });
    }
}

+ (instancetype)sharedInstance {

    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (FlutterWebAppBridge *)instantiateBridgeForWebView:(UIWebView *)webView
                                webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate
                                     moduleAPIs:(NSArray *)moduleAPIs
{
    FlutterWebAppBridge *bridge = [[FlutterWebAppBridge alloc] initWithWebView:webView
                                                     webViewDelegate:webViewDelegate];
    for (id<FlutterWebAppAPI> obj in moduleAPIs)
     {
        if ([obj conformsToProtocol:@protocol(FlutterWebAppAPI)])
         {
            if (![bridge registerAPI:obj forModule:obj.module])
             {
                NSLog(@"wkwebview Register api(%@) for module(%@) failed.", obj, obj.module);
             }
         }
     }

    return bridge;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isUseWKWebView = NO;
    }
    return self;
}

-(void)setIsUseWKWebView:(BOOL)isUseWKWebView
{
    //iOS8以下的系统不支持WKWebView
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0) {
        _isUseWKWebView = NO;
    } else {
        _isUseWKWebView = isUseWKWebView;
    }
}

#pragma mark - Internal Properties

@end

#pragma mark - FlutterWebAppBridge Implementation

@implementation FlutterWebAppBridge

@synthesize moduleAPIs = _moduleAPIs;

- (instancetype)initWithWebView:(UIWebView *)webView
                webViewDelegate:(id<UIWebViewDelegate>)webViewDelegate
{
    self = [super init];
    if (self) {
        webView.delegate = self;
        self.webView = webView;
        self.webViewDelegate = webViewDelegate;

        /**
         *  Injecting WAJavascriptBridge_iOS.js
         */
        [self _injectBridgeJavascript:self.webView];

        _moduleAPIs = [NSMutableDictionary dictionary];
    }
    return self;
}

//WKWebView的webAppBridge使用这个初始化方法，不需要设置webViewDelegate属性
-(instancetype)initWithWebView:(id)webView {

    self = [super init];
    if (self) {
        _moduleAPIs = [NSMutableDictionary dictionary];
        _webView = webView;
    }
    return self;
}

- (void)dealloc
{
    [self unregisterAllModuleAPIs];
    self.webView = nil;
}

- (BOOL)registerAPI:(id<FlutterWebAppAPI>)api forModule:(NSString *)module
{
    if (module == nil || api == nil) {
        return NO;
    }

    @synchronized(self.moduleAPIs) {
        self.moduleAPIs[module] = api;
        return YES;
    }
}

- (void)unregisterAPIForModule:(NSString *)module {

    @synchronized(self.moduleAPIs) {
        [self.moduleAPIs removeObjectForKey:module];
    }
}

- (void)unregisterAllModuleAPIs
{
    @synchronized(self.moduleAPIs) {
        [self.moduleAPIs removeAllObjects];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    if (webView != self.webView) {
        return;
    }

    self.numRequestsLoading++;

    __strong typeof(self.webViewDelegate) strongDelegate = self.webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidStartLoad:)]) {
        [strongDelegate webViewDidStartLoad:webView];
    }
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (webView != self.webView) {
        return;
    }
    self.numRequestsLoading--;
    if (self.numRequestsLoading == 0 && ![[webView stringByEvaluatingJavaScriptFromString:@"typeof window.YYApiCore == 'object'"] isEqualToString:@"true"]) {
        [self _injectBridgeJavascript:webView];
    }

    __strong typeof(self.webViewDelegate) strongDelegate = self.webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webViewDidFinishLoad:)]) {
        [strongDelegate webViewDidFinishLoad:webView];
    }

}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    if (webView != self.webView) {
        return;
    }
    self.numRequestsLoading--;
    __strong typeof(self.webViewDelegate) strongDelegate = self.webViewDelegate;
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:didFailLoadWithError:)]) {
        [strongDelegate webView:webView didFailLoadWithError:error];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (webView != self.webView || (navigationType == UIWebViewNavigationTypeOther && [request.URL.absoluteString isEqualToString:@"about:blank"]))
     {
        return YES;
     }

    NSURL *url = request.URL;
    __strong __typeof__(self.webViewDelegate) strongDelegate = self.webViewDelegate;

    if ([url.scheme isEqualToString:kFlutterWebAppFrameworkProtocolScheme]) {
        NSString *requestHost = nil;
        if ([self.webView isKindOfClass:[UIWebView class]]) {
            UIWebView *webView = (UIWebView *)self.webView;
            requestHost = [webView.request.mainDocumentURL host];
        }
        if (![requestHost hasSuffix:@"hamo.tv"]) {

            NSString *host = (NSString *)[self.webView stringByEvaluatingJavaScriptFromString:@"window.location.host"];

            NSString *localHost = (NSString *)[self.webView stringByEvaluatingJavaScriptFromString:@"window.getLocalHost()"];

            if (![localHost isKindOfClass:[NSString class]] || ![localHost hasSuffix:@"hamo.tv"] ) {
                if (![host isKindOfClass:[NSString class]]) {
                    return NO;
                }
//                if (![host hasSuffix:@"yy.com"] && ![host hasSuffix:@"1931.com"]) {
//                    return NO;
//                }
            }
        }

        if ([url.host isEqualToString:@"load"])
         {
            [self _injectBridgeJavascript:self.webView];
            return NO;
         }

        [self webView:webView handleAPIWithURL:url];
        return NO;

    }
    if (strongDelegate && [strongDelegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {

        return [strongDelegate webView:webView shouldStartLoadWithRequest:request navigationType:navigationType];

    }


    return YES;
}

- (void)webView:(id)webView handleAPIWithURL:(NSURL *)url
{
    /**
     *  Example: yyapi://ui/push?p={uri:'xxx'}&cb=callback
     *      - Module: ui
     *      - Name: Push
     *      - Parameter: {uri:'xxx'}
     */
    NSString *module = url.host;
    NSString *json = url[@"p"];
    json = [json stringByRemovingPercentEncoding]; //从URL里面截取参数自动编码了一次
    NSString *callback = url[@"cb"];
    NSArray *pathComponents = url.pathComponents;
    if (pathComponents.count == 2) {

        NSString *name = [pathComponents objectAtIndex:1];

        NSError *parseError;
        NSString *str = [json stringByRemovingPercentEncoding];
        NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
        id jsonObject =[NSJSONSerialization JSONObjectWithData:jsonData
                                                       options:NSJSONReadingAllowFragments
                                                         error:&parseError];

        FlutterWACallback callbackBlock = NULL;
        if (callback) {
            callbackBlock = ^(id returnValue) {

                returnValue = returnValue ? : NSNull.null;
                NSDictionary *result = @{@"result": returnValue};
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
                NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

                NSString *javascript = [NSString stringWithFormat:@"YYApiCore.invokeWebMethod(\"%@\", %@.result);", callback, json];

                //WKWebView与UIWebView调用的方法不同
                if ([webView isKindOfClass:UIWebView.class]) {
                    NSLog(@"uiwebview [+] WKWebView Execute javascript: %@.", javascript);
                    [webView stringByEvaluatingJavaScriptFromString:javascript];
                } else if ([webView isKindOfClass:WKWebView.class]){
                    NSLog(@"wkwebview [+] WKWebView Execute javascript: %@.", javascript);
                    [webView evaluateJavaScript:javascript completionHandler:nil];
                }
            };
        }

        // Call module methods
        id returnValue = [self _invokeClientMethod:module
                                              name:name
                                         parameter:jsonObject
                                          callback:callbackBlock];

        //如果是WKWebView，不支持直接调用JS设置返回值，只能通过上面的callback与H5通信
        if ([webView isKindOfClass:[WKWebView class]]) {
            return;
        }

        returnValue = returnValue ? : NSNull.null;
        NSDictionary *result = @{@"result": returnValue};
        jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        // Set return value synchronously
        NSString *javascript = [NSString stringWithFormat:@"YYApiCore.__RETURN_VALUE__ = %@;", json];
        NSLog(@"wkwebview [+/-] Execute javascript: %@.", javascript);
        [webView stringByEvaluatingJavaScriptFromString:javascript];
    }
    else
     {
        NSLog(@"wkwebview [YYWebAppFramework] Invalid url.");
     }

}


//- (void)webView:(UIWebView *)webView didCreateJavascriptContext:(JSContext *)context
//{
//    context[@"YYApiCore"] = [YYApiCore sharedObject];
//}

- (void)_injectBridgeJavascript:(UIWebView *)webView
{
    NSString *filePath = [[NSBundle mainBundle]
                          pathForResource:@"WAJavascriptBridge_iOS"
                          ofType:@"js"];
    NSString *js = [NSString stringWithContentsOfFile:filePath
                                             encoding:NSUTF8StringEncoding error:nil];
    [webView stringByEvaluatingJavaScriptFromString:js];
}

/**
 *  @Brief 调用一个Web方法(Javascript)
 *  iOS上, 所有Objective-C调用Javascript均采用同步方式, 因此没有callback
 */
- (id)_invokeWebMethod:(NSString *)name
             parameter:(id)parameter
{
    return nil;
}

/**
 *  @Brief 调用一个Native方法
 *  同步调用
 */
- (id)_invokeClientMethod:(NSString *)module
                     name:(NSString *)name
                parameter:(id)parameter
                 callback:(FlutterWACallback)callback
{
    id<FlutterWebAppAPI> api = [self _apiForModule:module];

    // 如果 api 对象有 setWebView 接口，则把当前 webView 设置过去   by zhenby
    if (self.webView && [api respondsToSelector:@selector(setWebView:)]) {
        [api setWebView:self.webView];
    }

    id result = [api invokeClientMethod:name parameter:parameter callback:callback];
    return result;
}

- (id<FlutterWebAppAPI>)_apiForModule:(NSString *)module
{
    id obj = [self.moduleAPIs objectForKey:module];
    return [obj conformsToProtocol:@protocol(FlutterWebAppAPI)] ? obj : nil;
}

@end

