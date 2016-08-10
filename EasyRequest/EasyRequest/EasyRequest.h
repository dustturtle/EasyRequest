//
//  EasyRequest.h
//  EasyRequest
//
//  Created by Dustturtle on 16/5/26.
//  Copyright © 2016年 Dustturtle. All rights reserved.
//

#import "EasyClients.h"
#import "EasyRequestDefines.h"
#import "YYModel.h"

@class EasyRequest;

typedef void(^EasyRequestHandler)(__kindof EasyRequest *request);

@interface EasyRequest : NSObject

// 请求的URL基础路径
@property (nonatomic, strong, readonly) NSURL *baseURL;
// 请求的URL相对路径字符串；对于1个对象而言，有且只有1个resourcePath，初始化后应不会变化;外部可随时访问。
@property (nonatomic, copy, readonly) NSString *resourcePath;

/***************Properties designed for access in Request handler only, begin*********/
//这里的值若单个request对象多次请求时，会被重新赋值，所以若外部访问时只能得到最近一次请求的结果。建议仅在回调中使用。
//单个request对象多次请求时，外部需尽量保证其时序上的串行（避免前次回调未回来前重复发起请求），
//如果适用方无法保证上述条件，则不能用单个request对象多次请求，而需用多个request对应多个请求。
//原因:EasyRequest中存储的对象可能被下次请求的数据刷新。

@property (nonatomic, assign, readonly) BOOL isSuccess;              //标识请求是否成功，用于逻辑处理
@property (nonatomic, strong, readonly) NSError *error;              //网络错误的error对象
@property (nonatomic, assign, readonly) EasyResponseStatus status;   //返回状态码,建议仅用于分析
@property (nonatomic, strong, readonly) id responseModel;            //自动解析到的model对象
@property (nonatomic, assign, readonly) NSInteger businessCode;      //业务返回码
@property (nonatomic, strong, readonly) NSDictionary *responseDic;   //响应的字典表示
@property (nonatomic, strong, readonly) NSData *responseData;        //响应的data表示

/***************Properties designed for access in Request handler only, end*********/

/// TODO:此处再额外提供一些属性（非只读）给外部进行一些配置的设置，便利扩展使用。
@property (nonatomic, strong) Class modelClass;

/// You may set this anytime you like; but we suggest you set this once before start method called.
/// All request responses after the set time of this property will use this handler.
@property (nonatomic, copy) EasyRequestHandler completionHandler;

/// req Type for custom modules. e.g: CHEXIAO_REQ_CHEZAIKUCUN in chexiao module.
@property (nonatomic, assign) NSInteger reqType;

/// req transparent info dic, for extend.
@property (nonatomic, strong) NSDictionary *extendInfo;

/**
 *  提供的默认初始化方法；子类可在init方法中调用此方法，从而实现定制化子类的目的。
 *
 *  @param url  urlString:例如 www.xxx.com的url字符串。
 *  @param path 相对于baseURL的相对路径字符串,例如/xxx.action
 *
 *  @return  EasyRequest对象
 */
- (instancetype)initWithBaseURLString:(NSString *)urlString path:(NSString *)path;

/**
 *  便利的初始化方法；使用easyClients中设置的defaultUrl作为请求对象的url，若无url则返回nil。
 *
 *  @param path 相对于baseURL的相对路径字符串,例如/xxx.action
 *
 *  @return  EasyRequest对象
 */
- (instancetype)initWithPath:(NSString *)path;

#pragma mark 网络请求的start方法
- (void)startPOST:(id)parameters;

- (void)startGET:(id)parameters;

// we suggest this, super easy! awesome, right?
- (void)uploadFile:(NSString *)fullPath fileName:(NSString *)fileName;

- (void)uploadData:(NSData *)data fileName:(NSString *)fileName;

- (void)uploadImage:(UIImage *)image withName:(NSString *)fileName;


// download? TODO next.

/**
 *  Request对象的基础start方法，上面3个start方法是固化参数的便捷调用。
 *
 *  注意：start方法调用前需要设置completionHandler，
 *  否则响应无法正常处理（不影响请求的送达，但无法监控结果）。
 *
 *  @param methodType GET/POST等，http请求类型;为了使用上的方便，这里将
 *  上传下载等特殊业务需求也和get/post等并列了（实际并不能归类为http操作类型）。
 *
 *  @param parameters 参数列表（一般为字典）
 */
- (void)startWithRequestMethodType:(HttpRequestMethodType)methodType
                        parameters:(id)parameters;


/// If you want to cancel previous request made by this request object,
/// invoke this method before start.  Optional
- (void)clearPreviousRequest;

@end
