//
//  EasyLogFormatter.m
//  EasyRequest
//
//  Created by Dustturtle on 16/5/26.
//  Copyright © 2016年 Dustturtle. All rights reserved.
//

#import "EasyLogFormatter.h"
#include <sys/time.h>

#define EASY_DATE_TIME_FMT "%04d-%02d-%02d %02d:%02d:%02d"

@implementation EasyLogFormatter

- (NSString *)formatLogMessage:(DDLogMessage *)logMessage
{
    static char const *const level_strings[] = {"LogError", "LogWarning", "LogInfo", "LogDebug", "LogVerbose"};
    NSString * levelStr;
    switch (logMessage.flag)
    {
        case DDLogFlagError:
        {
            levelStr = @(level_strings[0]);
            break;
        }
        case DDLogFlagWarning:
        {
            levelStr = @(level_strings[1]);
            break;
        }
        case DDLogFlagInfo:
        {
            levelStr = @(level_strings[2]);
            break;
        }
        case DDLogFlagDebug:
        {
            levelStr = @(level_strings[3]);
            break;
        }
        case DDLogFlagVerbose:
        {
            levelStr = @(level_strings[4]);
            break;
        }
            
        default:
        {
            levelStr = @(level_strings[4]);
            break;
        }
    }
    NSString * dateTime = getCurrentDateTimeForContent();
    return [NSString stringWithFormat:@"[%@] %@ \nFile:%@ Line:%@\nFunction:%@ \n%@", levelStr, dateTime,
            logMessage.fileName, @(logMessage->_line), logMessage->_function, logMessage->_message];
}

void generateTmBuff(time_t currTm, const char * tmFmt, char * tmBuff, int buffSize)
{
    struct tm date;
    localtime_r(&currTm, &date);
    snprintf(tmBuff, buffSize, tmFmt,
             (date.tm_year + 1900)
             ,date.tm_mon+1
             ,date.tm_mday
             ,date.tm_hour
             ,date.tm_min
             ,date.tm_sec);
}

NSString * getCurrentDateTimeForContent()
{
    struct timeval timeNow;
    gettimeofday(&timeNow, NULL);
    char timestampBuff[sizeof(EASY_DATE_TIME_FMT) + 1] = "";
    generateTmBuff(timeNow.tv_sec, EASY_DATE_TIME_FMT,
                   timestampBuff, sizeof(EASY_DATE_TIME_FMT) + 1);
    
    return [NSString stringWithFormat:@"%s.%03d",
            timestampBuff, timeNow.tv_usec/1000];
}

@end

