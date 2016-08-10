//
//  EasyClients.h
//  EasyRequest
//
// 针对每个baseUrl生成并存储一个AFHTTPSessionManager，在此处统一管理。
// AFnetworking此设计的目的应该是为了连接复用，提高效率（以及后续对http2.0新特性的的支持）
// 对每个baseUrl对应的sessionManager分别进行所需要的定制化设置:
// 可能包括请求头加入token等需求相关的配置，一般只设置1次，应用运行过程中不更改。
//
//  Created by Dustturtle on 16/5/26.
//  Copyright © 2016年 Dustturtle. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

#define CLEAR_HEAD_VALUE @"CLEAR_HEAD_VALUE"

// 专用于网络层的全部配置.建议搞一个EasyAdapter，请参考demo；可以考虑adapter从plist里面读取配置（从安全考虑，非全部）的方案。
@protocol EasyConfigsDelegate <NSObject>
@optional

// Usage:now you config by network type or status, 2g/3g/4g/wifi; default 30 seconds.
- (double)timeoutSeconds;

/**
 *  用于配置请求使用的token
 *
 *  @param baseUrlString 需要应用该token的请求对应的baseUrlstring
 *
 *  @return token信息，是一个键值对。 key是需要填充到头部的key,value则是token本身的值。
  *  其中的value为CLEAR_HEAD_VALUE表示将其值清空。
 */
- (NSDictionary *)tokenForUrl:(NSString *)baseUrlString;

/**
 *  用于配置请求使用的请求头部项,比如user-agent、cookie等。
 *
 *  @param baseUrlString 需要应用该请求头部项的请求所对应的baseUrlstring
 *
 *  @return 可以包含多个键值对（对应于指定的url上发生的request请求做设置）;
 *  其中的value为CLEAR_HEAD_VALUE表示将其值清空。
 */
- (NSDictionary *)requestHeadConfigsForUrl:(NSString *)baseUrlString;

// url based setting; isAllowInvalidCertificates
- (BOOL)isAllowInvalidCertificatesForUrl:(NSString *)baseUrlString;

// url based setting; gzip Accept-Encoding
- (BOOL)isAcceptGzip:(NSString *)baseUrlString;

// url based setting; securityMode
- (AFSSLPinningMode)securityModeForUrl:(NSString *)baseUrlString;

// 下面两个方法是用于应对多源头的url请求对应的resultkey和resultCodekey需要分别设置的情况。
// 若不设置则以EasyRequest.m中的宏定义为准。
- (NSString *)resultKeyForUrl:(NSString *)baseUrlString;

- (NSString *)resultCodeKeyForUrl:(NSString *)baseUrlString;

@end


@interface EasyClients : NSObject
@property (nonatomic, copy, readonly) NSString *defaultUrlString;

@property (nonatomic, weak) id<EasyConfigsDelegate> delegate;

+ (instancetype)sharedClients;

- (void)setupDefaultUrlString:(NSString *)urlString;

/**
 Creates and return an `AFHTTPSessionManager`
 */
- (AFHTTPSessionManager *)clientForBaseURL:(NSURL *)baseURL;

- (NSString *)resultCodeKeyForURL:(NSURL *)baseURL;

- (NSString *)resultKeyForURL:(NSURL *)baseURL;


@end
