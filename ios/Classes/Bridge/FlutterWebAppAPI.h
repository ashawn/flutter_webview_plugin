//
//  FlutterWebAppAPI.h
//
//  Created by AShawn on 19/1/1.
//  Copyright © 2018年 YY.inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^FlutterWACallback)(id parameter);

@protocol FlutterWebAppAPI <NSObject>

@property (nonatomic, readonly, strong) NSString *module;

- (id)invokeClientMethod:(NSString *)name parameter:(id)parameter callback:(FlutterWACallback)callback;
- (void)setWebView:(id)webView;

@end
