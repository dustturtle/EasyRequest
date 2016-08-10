//
//  EasyRequest.m
//  EasyRequest
//
//  Created by Dustturtle on 16/5/26.
//  Copyright © 2016年 Dustturtle. All rights reserved.
//

#import "EasyRequest.h"
#import "AFHTTPSessionManager.h"
#import "EasyLogger.h"
#import <Foundation/Foundation.h>

// 这里设置请求结果key和请求结果状态码key的默认值；当EasyConfigsDelegate的代理中已经配置时，以代理的为准。
#define REQUEST_RESULT_KEY @"result"
#define REQUEST_RESULT_CODE_KEY @"code"

@interface EasyRequest ()

@property (nonatomic, strong) NSURL *baseURL;
@property (nonatomic, copy) NSString *resourcePath;
@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

/***************Properties designed for access in Request handler only, begin*********/
@property (nonatomic, assign) BOOL isSuccess;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) EasyResponseStatus status;
@property (nonatomic, strong) id responseModel;
@property (nonatomic, assign) NSInteger businessCode;
@property (nonatomic, strong) NSDictionary *responseDic;
@property (nonatomic, strong) NSData *responseData;
/***************Properties designed for access in Request handler only, end***********/
@end

@implementation EasyRequest

#pragma mark Life cycle
- (instancetype)initWithBaseURLString:(NSString *)urlString path:(NSString *)path
{
    //DDLogDebug(@"EasyRequest created");
    if ([urlString length] <= 0 || [path length] <= 0)
    {
        // param nil
        return nil;
    }
    
    self = [super init];
    if (self)
    {
        NSURL *baseUrl = [NSURL URLWithString:urlString];
        self.baseURL = baseUrl;
        self.resourcePath = path;
        self.error = nil;
        self.completionHandler = nil;
    }
    
    return self;
}

- (instancetype)initWithPath:(NSString *)path
{
    NSString *urlString = [EasyClients sharedClients].defaultUrlString;
    return [self initWithBaseURLString:urlString path:path];
}

- (void)dealloc
{
    self.completionHandler = nil;
    [self.dataTask cancel];
    self.dataTask = nil;
    
    //DDLogDebug(@"zkRequest released");
}

#pragma mark Public Methods

- (void)startGET:(id)parameters
{
    DDLogDebug(@"URL:%@%@ Parameters: %@", self.baseURL, self.resourcePath, parameters);
    
    AFHTTPSessionManager *client = [self fetchPreparedClient];
    
    self.dataTask = [client GET:self.resourcePath
                     parameters:parameters
                       progress:nil
                        success:^(NSURLSessionDataTask *task, id responseObject)
                     {
                         // 这里不需要weak,而是通过block间接短暂持有request，保证临时request的block也会被执行。
                         [self requestSuccessWithResponse:responseObject task:task];
                     }
                        failure:^(NSURLSessionDataTask *__unused task, NSError *error)
                     {
                         // 这里不需要weak,而是通过block间接短暂持有request，保证临时request的block也会被执行。
                         [self requestFailWithError:error];
                     }];
}

- (void)startPOST:(id)parameters
{
    DDLogDebug(@"URL:%@%@ Parameters: %@", self.baseURL, self.resourcePath, parameters);
    
    AFHTTPSessionManager *client = [self fetchPreparedClient];
    
    self.dataTask = [client
                     POST:self.resourcePath
                     parameters:parameters
                     progress:nil
                     success:^(NSURLSessionDataTask *task, id responseObject)
                     {
                         // 这里不需要weak,而是通过block间接短暂持有request，保证临时request的block也会被执行。
                         [self requestSuccessWithResponse:responseObject task:task];
                     }
                     failure:^(NSURLSessionDataTask *__unused task, NSError *error)
                     {
                         // 这里不需要weak,而是通过block间接短暂持有request，保证临时request的block也会被执行。
                         [self requestFailWithError:error];
                     }];
}

- (void)uploadFile:(NSString *)fullPath fileName:(NSString *)fileName
{
    DDLogDebug(@"URL:%@%@ fileName: %@", self.baseURL, self.resourcePath, fileName);
    NSString *mimeType = [self mimeTypeWithFilePath:fullPath];
    NSData *fileData  = [NSData dataWithContentsOfFile:fullPath];
    [self uploadData:fileData fileName:fileName mimeType:mimeType];
}

- (void)uploadData:(NSData *)data fileName:(NSString *)fileName;
{
    DDLogDebug(@"URL:%@%@ fileName: %@", self.baseURL, self.resourcePath, fileName);
    NSString *mimeType = [self mimeTypeFromData:data];
    [self uploadData:data fileName:fileName mimeType:mimeType];
}

- (void)uploadImage:(UIImage *)image withName:(NSString *)fileName
{
    DDLogDebug(@"URL:%@%@ fileName: %@", self.baseURL, self.resourcePath, fileName);
    NSData* imageData = UIImageJPEGRepresentation((UIImage *)image, 1.0f);
    NSString *mimeType = [self mimeTypeFromData:imageData];
    [self uploadData:imageData fileName:fileName mimeType:mimeType];
}

- (void)startWithRequestMethodType:(HttpRequestMethodType)methodType
                        parameters:(id)parameters
{
    if (methodType == kHttpRequestMethodTypeGet)
    {
        [self startGET:parameters];
    }
    else if (methodType == kHttpRequestMethodTypePost)
    {
        [self startPOST:parameters];
    }
    else if (methodType == kHttpRequestMethodTypeMIMEUpload)
    {
        // currently no handler with MIME request. TODO: need to be implemented.
    }
}

- (void)clearPreviousRequest
{
    [self.dataTask cancel];
    self.dataTask = nil;
}

#pragma mark Private Methods
// TODO: something with MIME request.

- (AFHTTPSessionManager *)fetchPreparedClient
{
    AFHTTPSessionManager *client = [[EasyClients sharedClients] clientForBaseURL:self.baseURL];
    return client;
}

- (void)requestSuccessWithResponse:(id)responseObj task:(NSURLSessionDataTask *)task
{
    // clear previous error; no error when success response.
    self.error = nil;
    self.responseData = (NSData *)responseObj;
    NSDictionary *rspDic = [NSJSONSerialization JSONObjectWithData:responseObj
                                                           options:NSJSONReadingMutableContainers
                                                             error:nil];
    self.responseDic = rspDic;
    
    // parse the status code, do the logging; setup properties for invoker to read in handler
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
    NSInteger statusCode = response.statusCode;
    if (statusCode == 200)
    {
        DDLogDebug(@"URL:%@ reqType=%@ responseObject:%@", self.resourcePath, @(self.reqType), responseObj);
        self.isSuccess = YES;
        self.status = EasyStatusSuccess;
    
        if (self.modelClass)
        {
            if (rspDic)
            {
                id modelInfo;
                NSString * resultKey = [[EasyClients sharedClients] resultKeyForURL:self.baseURL];
                if ([resultKey length] > 0)
                {
                    modelInfo = rspDic[resultKey];
                }
                else
                {
                    modelInfo = rspDic[REQUEST_RESULT_KEY];
                }
                
                if ([modelInfo isKindOfClass:[NSDictionary class]])
                {
                    self.responseModel = [self.modelClass yy_modelWithDictionary:modelInfo];
                }
                else if ([modelInfo isKindOfClass:[NSArray class]])
                {
                    self.responseModel = [NSArray yy_modelArrayWithClass:self.modelClass json:modelInfo];
                }
                else
                {
                    self.responseModel = nil; // 无法生成model，将其置空，防止复用场景下的脏数据。
                }
            }
        }
        else
        {
            // we need to clear the previous request data model anyway~
            self.responseModel = nil;
        }
        
        NSString * resultCodeKey = [[EasyClients sharedClients] resultCodeKeyForURL:self.baseURL];
        if ([resultCodeKey length] > 0)
        {
            self.businessCode = [self.responseDic[resultCodeKey] integerValue];
        }
        else
        {
            self.businessCode = [self.responseDic[REQUEST_RESULT_CODE_KEY] integerValue];
        }
    }
    else
    {
        self.isSuccess = NO;
        self.status = statusCode;
        self.responseModel = nil;
        self.businessCode = 0;
        DDLogError(@"baseUrl:%@ URL:%@ responseObject:%@ statusCode=%@ reqType=%@",
                   self.baseURL, self.resourcePath, responseObj, @(statusCode), @(self.reqType));
    }
    
    if (self.completionHandler)
    {
        self.completionHandler(self);
    }
}

- (void)requestFailWithError:(NSError *)error
{
    // step1: do the logging
    DDLogError(@"baseUrl:%@ Path:%@ Error:%@", self.baseURL, self.resourcePath, error);
    
    // step2: setup properties for invoker to read in handler
    self.error = error;
    self.isSuccess = NO;
    self.status = EasyStatusLocalFailed;
    self.businessCode = 0;
    self.responseDic = nil;
    self.responseData = nil;
    
    // step3: call the handler
    if (self.completionHandler)
    {
        self.completionHandler(self);
    }
}

-(NSString *)mimeTypeWithFilePath:(NSString *)path
{
    if (![[[NSFileManager alloc] init] fileExistsAtPath:path])
    {
        return nil;
    }
    
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, (__bridge CFStringRef)[path pathExtension], NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    if (!MIMEType)
    {
        return @"application/octet-stream";
    }
    
    return (__bridge NSString *)(MIMEType);
}

- (NSString *)mimeTypeFromData:(NSData *)data
{
    uint8_t typeHead;
    [data getBytes:&typeHead length:1];
    
    NSString *mimeType = nil;
    switch (typeHead)
    {
        case 0xFF:
            mimeType = @"image/jpeg";
            break;
        case 0x89:
            mimeType = @"image/png";
            break;
        case 0x47:
            mimeType = @"image/gif";
            break;
        case 0x49:
        case 0x4D:
            mimeType = @"image/tiff";
            break;
    }
    
    if ([mimeType length] <= 0)
    {
        // default
        mimeType = @"application/octet-stream";
    }
    return mimeType;
}

- (void)uploadData:(NSData *)data fileName:(NSString *)fileName mimeType:(NSString *)mimeType
{
    DDLogDebug(@"URL:%@%@ fileName: %@ mimeType: %@", self.baseURL, self.resourcePath, fileName, mimeType);

    AFHTTPSessionManager *client = [self fetchPreparedClient];
    
    self.dataTask = [client
                     POST:self.resourcePath
                     parameters:nil
                     constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
                     {
                         // TODO: config what name means.
                         [formData appendPartWithFileData:data name:@"filename" fileName:fileName mimeType:mimeType];
                     }
                     progress:nil
                     success:^(NSURLSessionDataTask * __unused task, id responseObject)
                     {
                         // 这里不需要weak,而是通过block间接短暂持有request，保证临时request的block也会被执行。
                         [self requestSuccessWithResponse:responseObject task:task];
                     } failure:^(NSURLSessionDataTask *__unused task, NSError *error)
                     {
                         // 这里不需要weak,而是通过block间接短暂持有request，保证临时request的block也会被执行。
                         [self requestFailWithError:error];
                     }];
}

@end

