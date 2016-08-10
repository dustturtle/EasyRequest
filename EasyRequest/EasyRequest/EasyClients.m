//
//
//  EasyClients.m
//  EasyRequest
//
//
//  Created by Dustturtle on 16/5/26.
//  Copyright © 2016年 Dustturtle. All rights reserved.
//

#import "EasyClients.h"
#import "AFHTTPSessionManager.h"
#import "AFURLRequestSerialization.h"
#import "EasyLogger.h"

#define ZK_CUSTOM_COOKIE @"Set-Cookie"

@interface EasyClients ()

@property (nonatomic, strong) NSMutableDictionary *clients;

@property (nonatomic, copy) NSString *defaultUrlString;

// 备选方案，如果确实需要有和无的两种情况再考虑添加。
// @property (nonatomic, strong) NSMutableDictionary *clientsWithToken;

@end

@implementation EasyClients

#pragma mark Life cycle

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.clients = [NSMutableDictionary dictionary];
    }
    
    return self;
}

+ (instancetype)sharedClients
{
    static EasyClients *_sharedClients = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClients = [[EasyClients alloc] init];
    });
    
    return _sharedClients;
}

- (void)setupDefaultUrlString:(NSString *)urlString
{
    self.defaultUrlString = urlString;
}

- (AFHTTPSessionManager *)clientForBaseURL:(NSURL *)baseURL
{
    NSParameterAssert(baseURL);
    
    // setup client for url(if not found in clients dic)
    if (![self.clients objectForKey:[baseURL absoluteString]])
    {
        AFHTTPSessionManager *client = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
        
        client.requestSerializer = [AFHTTPRequestSerializer serializer];
        client.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        [self.clients setValue:client forKey:[baseURL absoluteString]];
    }
    
    // fetch client from dic
    AFHTTPSessionManager *client = [self.clients objectForKey:[baseURL absoluteString]];
    
    [self setupHeadersForClient:client withUrlString:[baseURL absoluteString]];
    
    return client;
}

- (NSString *)resultCodeKeyForURL:(NSURL *)baseURL
{
    NSString *urlString = [baseURL absoluteString];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(resultCodeKeyForUrl:)])
    {
        return [self.delegate resultCodeKeyForUrl:urlString];
    }
    else
    {
        return nil;
    }
}

- (NSString *)resultKeyForURL:(NSURL *)baseURL
{
    NSString *urlString = [baseURL absoluteString];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(resultKeyForUrl:)])
    {
        return [self.delegate resultKeyForUrl:urlString];
    }
    else
    {
        return nil;
    }
}

#pragma mark inner methods

- (void)configHTTPHeadForClient:(AFHTTPSessionManager *)client withSelector:(SEL)selector andUrlString:(NSString *)urlString
{
    if (self.delegate && [self.delegate respondsToSelector:selector])
    {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        NSDictionary *infoDic = [self.delegate performSelector:selector withObject:urlString];
        #pragma clang diagnostic pop

        if (infoDic)
        {
            for (NSString *infoKey in infoDic)
            {
                NSString *infoValue = infoDic[infoKey];
                
                if ([infoValue isEqualToString:CLEAR_HEAD_VALUE])
                {
                    //清除该HeaderField的值
                    [client.requestSerializer setValue:nil forHTTPHeaderField:infoKey];
                }
                else
                {
                    [client.requestSerializer setValue:infoValue forHTTPHeaderField:infoKey];
                }
            }
        }
    }
}

- (void)setupHeadersForClient:(AFHTTPSessionManager *)client withUrlString:(NSString *)urlString
{
    // add default Content-Type header
    [client.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    if (self.delegate && [self.delegate respondsToSelector:@selector(timeoutSeconds)])
    {
        client.requestSerializer.timeoutInterval = [_delegate timeoutSeconds];
    }
    else
    {
        client.requestSerializer.timeoutInterval = 30.0f;
    }
    
    [self configHTTPHeadForClient:client withSelector:@selector(tokenForUrl:) andUrlString:urlString];
    [self configHTTPHeadForClient:client withSelector:@selector(requestHeadConfigsForUrl:) andUrlString:urlString];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(isAcceptGzip:)])
    {
        if ([self.delegate isAcceptGzip:urlString])
        {
            [client.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
        }
    }
    else
    {
        [client.requestSerializer setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(isAllowInvalidCertificatesForUrl:)])
    {
        if ([self.delegate isAllowInvalidCertificatesForUrl:urlString])
        {
            client.securityPolicy.allowInvalidCertificates = YES;
        }
        else
        {
            client.securityPolicy.allowInvalidCertificates = NO;
        }
    }
    else
    {
        client.securityPolicy.allowInvalidCertificates = YES;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(securityModeForUrl:)])
    {
        AFSSLPinningMode mode = [self.delegate securityModeForUrl:urlString];
        client.securityPolicy = [AFSecurityPolicy policyWithPinningMode:mode];
    }
    else
    {
        client.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    }
}

@end
