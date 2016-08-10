//
//  EasyRequestDefines.h
//  EasyRequest
//
//  Created by achen on 16/6/8.
//  Copyright © 2016年 achen. All rights reserved.
//

#ifndef EasyRequestDefines_h
#define EasyRequestDefines_h

typedef NS_ENUM(NSInteger, HttpRequestMethodType)
{
    kHttpRequestMethodTypeGet = 0,
    kHttpRequestMethodTypePatch,
    kHttpRequestMethodTypePost,
    kHttpRequestMethodTypePut,
    kHttpRequestMethodTypeDelete,
    kHttpRequestMethodTypeMIMEUpload,
    kHttpRequestMethodTypeDownload
};

typedef NS_ENUM(NSInteger, EasyResponseStatus)
{
    EasyStatusLocalFailed = 0, // request local failed from failure block
    EasyStatusSuccess = 1,// success
    EasyStatusUseralreadyExist = 3, // user already exist
    EasyStatusInvalidMailAddress = 4, // invalid mail address
    EasyStatusUserAvailable = 5, // user available
    EasyStatusUserNoUpdate = 6, // user no update!
    EasyStatusInvalidVerifyCode = 7, // invalid verify code
    EasyStatusInvalidUser = 8,// invalid user
    EasyStatusInvalidPassword = 9, // invalid password
    
    EasyStatusNoSuchPost = 10, // no such post
    EasyStatusNoUnique = 11, // no unique
    EasyStatusNonParentPost = 12, // non parent post
    EasyStatusNopermission = 13, // nopermission
    EasyStatusMissingArgument = 14, // missing argument
    
    EasyStatusFailToUpload = 21, // fail to upload
    EasyStatusFailToSendSms = 22, // fail to send sms
    EasyStatusNicknameNoUnique = 23, // nickname no unique
    EasyStatusEmailNoUnique = 24, // email no unique
    EasyStatusPhoneNoUnique = 25, // phone no unique
    EasyStatusInvalidChannelType = 26, // invalid channel type
    EasyStatusInvalidToken = 27, // invalid token
    EasyStatusNoToken = 28, // no token
    EasyStatusTokenExpired = 29, // token expired
};



#endif /* EasyRequestDefines_h */
