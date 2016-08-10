//
//  EasyLogger.m
//  EasyRequest
//
//  Created by achen on 16/5/26.
//  Copyright © 2016年 achen. All rights reserved.
//

#import "EasyLogger.h"

#ifdef DEBUG
DDLogLevel const ddLogLevel = DDLogLevelDebug;
#else
DDLogLevel const ddLogLevel = DDLogLevelError;
#endif

@implementation EasyLogger

+ (void)logSetup
{
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    
    EasyLogFormatter *formatter = [[EasyLogFormatter alloc] init];
    [[DDASLLogger sharedInstance] setLogFormatter:formatter];
    [[DDTTYLogger sharedInstance] setLogFormatter:formatter];
    
#ifdef DEBUG
    //苹果系统日志输出启用
    [DDLog addLogger:[DDASLLogger sharedInstance] withLevel:ddLogLevel];
    //终端/xcode输出启用
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];
#endif
    
    //文件输出启用
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 0;
    fileLogger.maximumFileSize = 1000*1000;
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    [fileLogger setLogFormatter:formatter];
    [DDLog addLogger:fileLogger withLevel:ddLogLevel];
}

@end
