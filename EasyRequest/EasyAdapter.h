//
//  EasyAdapter.h
//  EasyRequest
//
//  Created by achen on 16/5/27.
//  Copyright © 2016年 achen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EasyClients.h"

#define WEATHER_BASE_URL @"http://180.149.145.78/apistore/weatherservice/"
#define WEATHER_API_KEY @"9b4a61a957231efe64dbb3a353f518a2"

@interface EasyAdapter : NSObject <EasyConfigsDelegate>

+ (instancetype)sharedInstance;

@end
