#import "FlutterWebviewPlugin.h"
#import "NSURL+Parameters.h"

static NSString *const CHANNEL_NAME = @"flutter_webview_plugin";
static NSString * const kFlutterWebViewAPI = @"YYWKWebViewAPI";

// UIWebViewDelegate
@interface FlutterWebviewPlugin() <WKNavigationDelegate, UIScrollViewDelegate, WKScriptMessageHandler> {
    BOOL _enableAppScheme;
    BOOL _enableZoom;
}

@end

@implementation FlutterWebviewPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    channel = [FlutterMethodChannel
               methodChannelWithName:CHANNEL_NAME
               binaryMessenger:[registrar messenger]];

    UIViewController *viewController = [UIApplication sharedApplication].delegate.window.rootViewController;
    FlutterWebviewPlugin* instance = [[FlutterWebviewPlugin alloc] initWithViewController:viewController];

    [registrar addMethodCallDelegate:instance channel:channel];
}

- (instancetype)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.viewController = viewController;
    }
    return self;
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    if ([@"launch" isEqualToString:call.method]) {
        if (!self.webview)
            [self initWebview:call];
        else
            [self navigate:call];
        result(nil);
    } else if ([@"close" isEqualToString:call.method]) {
        [self closeWebView];
        result(nil);
    } else if ([@"eval" isEqualToString:call.method]) {
        [self evalJavascript:call completionHandler:^(NSString * response) {
            result(response);
        }];
    } else if ([@"resize" isEqualToString:call.method]) {
        [self resize:call];
        result(nil);
    } else if ([@"reloadUrl" isEqualToString:call.method]) {
        [self reloadUrl:call];
        result(nil);
    } else if ([@"show" isEqualToString:call.method]) {
        [self show];
        result(nil);
    } else if ([@"hide" isEqualToString:call.method]) {
        [self hide];
        result(nil);
    } else if ([@"stopLoading" isEqualToString:call.method]) {
        [self stopLoading];
        result(nil);
    } else if ([@"cleanCookies" isEqualToString:call.method]) {
        [self cleanCookies];
    } else if ([@"back" isEqualToString:call.method]) {
        [self back];
        result(nil);
    } else if ([@"forward" isEqualToString:call.method]) {
        [self forward];
        result(nil);
    } else if ([@"reload" isEqualToString:call.method]) {
        [self reload];
        result(nil);
    } else if ([@"invokeJsCallback" isEqualToString:call.method]) {
        [self invokeJsCallback:call];
        result(nil);
    } else {
        result(FlutterMethodNotImplemented);
    }
}

- (WKWebViewConfiguration *)wkConfiguration {
    
    NSBundle *bundle = [NSBundle bundleForClass:FlutterWebviewPlugin.class];
    NSString *path = [bundle pathForResource:@"flutter_webview_plugin" ofType:@"bundle"];
    NSBundle *jsBundle = [NSBundle bundleWithPath:path];
    
    NSString *jsFilePath = [jsBundle pathForResource:@"FlutterWebViewAPI" ofType:@"js"];
    NSString *jsCode = [NSString stringWithContentsOfFile:jsFilePath encoding:NSUTF8StringEncoding error:nil];
    
    WKUserScript *userScript = [[WKUserScript alloc] initWithSource:jsCode injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
    WKUserContentController *controller = [[WKUserContentController alloc] init];
    [controller addUserScript:userScript]; // iOS端往js端注入代码
    
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = controller;
    
    return configuration;
}

- (void)initWebview:(FlutterMethodCall*)call {
    NSNumber *clearCache = call.arguments[@"clearCache"];
    NSNumber *clearCookies = call.arguments[@"clearCookies"];
    NSNumber *hidden = call.arguments[@"hidden"];
    NSDictionary *rect = call.arguments[@"rect"];
    _enableAppScheme = call.arguments[@"enableAppScheme"];
    NSString *userAgent = call.arguments[@"userAgent"];
    NSNumber *withZoom = call.arguments[@"withZoom"];
    NSNumber *scrollBar = call.arguments[@"scrollBar"];

    if (clearCache != (id)[NSNull null] && [clearCache boolValue]) {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
    }

    if (clearCookies != (id)[NSNull null] && [clearCookies boolValue]) {
        [[NSURLSession sharedSession] resetWithCompletionHandler:^{
        }];
    }

    if (userAgent != (id)[NSNull null]) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": userAgent}];
    }
    else{
        UIWebView *webView = [[UIWebView alloc] init];
        NSString *originalUA = [webView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        if ([originalUA rangeOfString:@"moschat_ios"].location == NSNotFound)
        {
            NSString *userAgentWithFlutter = [originalUA stringByAppendingFormat:@"moschat_ios"];
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent": userAgentWithFlutter}];
        }
    }

    CGRect rc;
    if (rect != (id)[NSNull null]) {
        rc = [self parseRect:rect];
    } else {
        rc = self.viewController.view.bounds;
    }

    self.webview = [[WKWebView alloc] initWithFrame:rc configuration:[self wkConfiguration]];
    self.webview.navigationDelegate = self;
    self.webview.scrollView.delegate = self;
    self.webview.hidden = [hidden boolValue];
    self.webview.scrollView.showsHorizontalScrollIndicator = [scrollBar boolValue];
    self.webview.scrollView.showsVerticalScrollIndicator = [scrollBar boolValue];
    [self.webview.configuration.userContentController addScriptMessageHandler:self name:kFlutterWebViewAPI];//处理YYApi，与H5交互

    _enableZoom = [withZoom boolValue];

    [self.viewController.view addSubview:self.webview];

    [self navigate:call];
}

- (CGRect)parseRect:(NSDictionary *)rect {
    return CGRectMake([[rect valueForKey:@"left"] doubleValue],
                      [[rect valueForKey:@"top"] doubleValue],
                      [[rect valueForKey:@"width"] doubleValue],
                      [[rect valueForKey:@"height"] doubleValue]);
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    id xDirection = @{@"xDirection": @(scrollView.contentOffset.x) };
    [channel invokeMethod:@"onScrollXChanged" arguments:xDirection];

    id yDirection = @{@"yDirection": @(scrollView.contentOffset.y) };
    [channel invokeMethod:@"onScrollYChanged" arguments:yDirection];
}

- (void)navigate:(FlutterMethodCall*)call {
    if (self.webview != nil) {
            NSString *url = call.arguments[@"url"];
            NSNumber *withLocalUrl = call.arguments[@"withLocalUrl"];
            if ( [withLocalUrl boolValue]) {
                NSURL *htmlUrl = [NSURL fileURLWithPath:url isDirectory:false];
                if (@available(iOS 9.0, *)) {
                    [self.webview loadFileURL:htmlUrl allowingReadAccessToURL:htmlUrl];
                } else {
                    @throw @"not available on version earlier than ios 9.0";
                }
            } else {
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
                NSDictionary *headers = call.arguments[@"headers"];

                if (headers != nil) {
                    [request setAllHTTPHeaderFields:headers];
                }

                [self.webview loadRequest:request];
            }
        }
}

- (void)evalJavascript:(FlutterMethodCall*)call
     completionHandler:(void (^_Nullable)(NSString * response))completionHandler {
    if (self.webview != nil) {
        NSString *code = call.arguments[@"code"];
        [self.webview evaluateJavaScript:code
                       completionHandler:^(id _Nullable response, NSError * _Nullable error) {
            completionHandler([NSString stringWithFormat:@"%@", response]);
        }];
    } else {
        completionHandler(nil);
    }
}

- (void)resize:(FlutterMethodCall*)call {
    if (self.webview != nil) {
        NSDictionary *rect = call.arguments[@"rect"];
        CGRect rc = [self parseRect:rect];
        self.webview.frame = rc;
    }
}

- (void)closeWebView {
    if (self.webview != nil) {
        [self.webview stopLoading];
        [self.webview removeFromSuperview];
        self.webview.navigationDelegate = nil;
        [self.webview.configuration.userContentController removeScriptMessageHandlerForName:kFlutterWebViewAPI];
        self.webview = nil;

        // manually trigger onDestroy
        [channel invokeMethod:@"onDestroy" arguments:nil];
    }
}

- (void)reloadUrl:(FlutterMethodCall*)call {
    if (self.webview != nil) {
		NSString *url = call.arguments[@"url"];
		NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        [self.webview loadRequest:request];
    }
}
- (void)show {
    if (self.webview != nil) {
        self.webview.hidden = false;
    }
}

- (void)hide {
    if (self.webview != nil) {
        self.webview.hidden = true;
    }
}
- (void)stopLoading {
    if (self.webview != nil) {
        [self.webview stopLoading];
    }
}
- (void)back {
    if (self.webview != nil) {
        [self.webview goBack];
    }
}
- (void)forward {
    if (self.webview != nil) {
        [self.webview goForward];
    }
}
- (void)reload {
    if (self.webview != nil) {
        [self.webview reload];
    }
}

- (void)cleanCookies {
    [[NSURLSession sharedSession] resetWithCompletionHandler:^{
        }];
}

- (void)invokeJsCallback:(FlutterMethodCall*)call {
    if (self.webview != nil) {
        NSString *callback = call.arguments[@"callbackName"];
        id param = call.arguments[@"param"];
        id returnValue = param ? : NSNull.null;
        NSDictionary *result = @{@"result": returnValue};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:result options:0 error:nil];
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *javascript = [NSString stringWithFormat:@"YYApiCore.invokeWebMethod(\"%@\", %@.result);", callback, json];
        
        NSLog(@"wkwebview [+] WKWebView Execute javascript: %@.", javascript);
        [self.webview evaluateJavaScript:javascript completionHandler:nil];
    }
}

- (void)handleAPIWithURL:(NSURL *)url
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
        
        id data = @{@"module": module,
                    @"name": name,
                    @"parameters": jsonObject,
                    @"callback": callback,
                    };
        [channel invokeMethod:@"onJsApiCalled" arguments:data];
    }
    else
    {
        NSLog(@"wkwebview [YYWebAppFramework] Invalid url.");
    }
    
}

#pragma mark -- WkWebView Delegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
    decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {

    id data = @{@"url": navigationAction.request.URL.absoluteString,
                @"type": @"shouldStart",
                @"navigationType": [NSNumber numberWithInt:navigationAction.navigationType]};
    [channel invokeMethod:@"onState" arguments:data];

    if (navigationAction.navigationType == WKNavigationTypeBackForward) {
        [channel invokeMethod:@"onBackPressed" arguments:nil];
    } else {
        id data = @{@"url": navigationAction.request.URL.absoluteString};
        [channel invokeMethod:@"onUrlChanged" arguments:data];
    }

    if (_enableAppScheme ||
        ([webView.URL.scheme isEqualToString:@"http"] ||
         [webView.URL.scheme isEqualToString:@"https"] ||
         [webView.URL.scheme isEqualToString:@"about"])) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}


- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [channel invokeMethod:@"onState" arguments:@{@"type": @"startLoad", @"url": webView.URL.absoluteString}];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [channel invokeMethod:@"onState" arguments:@{@"type": @"finishLoad", @"url": webView.URL.absoluteString}];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [channel invokeMethod:@"onError" arguments:@{@"code": [NSString stringWithFormat:@"%ld", error.code], @"error": error.localizedDescription}];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if ([navigationResponse.response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse * response = (NSHTTPURLResponse *)navigationResponse.response;

        [channel invokeMethod:@"onHttpError" arguments:@{@"code": [NSString stringWithFormat:@"%ld", response.statusCode], @"url": webView.URL.absoluteString}];
    }
    decisionHandler(WKNavigationResponsePolicyAllow);
}

#pragma mark -- UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (scrollView.pinchGestureRecognizer.isEnabled != _enableZoom) {
        scrollView.pinchGestureRecognizer.enabled = _enableZoom;
    }
}

#pragma mark - WKScriptMessageHandler
//处理H5调用的API
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:kFlutterWebViewAPI]) {
        id msg = message.body;
        if ([msg isKindOfClass:NSString.class]) {
            [self handleAPIWithURL:[NSURL URLWithString:msg]];
        }
    }
}

@end
