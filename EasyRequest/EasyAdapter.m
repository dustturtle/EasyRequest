//
//  EasyAdapter.m
//  EasyRequest
//
//  Created by achen on 16/5/27.
//  Copyright © 2016年 achen. All rights reserved.
//

#import "EasyAdapter.h"

@implementation EasyAdapter

+ (instancetype)sharedInstance
{
    static EasyAdapter *_sharedAdapter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAdapter = [[EasyAdapter alloc] init];
    });
    
    return _sharedAdapter;
}

- (double)timeoutSeconds
{
    return 60.0f;
}

- (NSDictionary *)tokenForUrl:(NSString *)baseUrlString
{
    return nil;
}

- (NSDictionary *)requestHeadConfigsForUrl:(NSString *)baseUrlString
{
    if ([baseUrlString isEqualToString:WEATHER_BASE_URL])
    {
        NSDictionary *dic = @{@"apikey":WEATHER_API_KEY};
        
        return dic;
    }
    
    return nil;
}

- (BOOL)isAllowInvalidCertificatesForUrl:(NSString *)baseUrlString
{
    return YES;
}

- (BOOL)isAcceptGzip:(NSString *)baseUrlString
{
    return YES;
}

- (AFSSLPinningMode)securityModeForUrl:(NSString *)baseUrlString
{
    return AFSSLPinningModeNone;
}

- (NSString *)resultKeyForUrl:(NSString *)baseUrlString
{
    if ([baseUrlString isEqualToString:WEATHER_BASE_URL])
    {
        return @"retData";
    }
    
    return nil;
}

- (NSString *)resultCodeKeyForUrl:(NSString *)baseUrlString
{
    
    if ([baseUrlString isEqualToString:WEATHER_BASE_URL])
    {
        return @"errNum";
    }
    
    return nil;
}

@end
