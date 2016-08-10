//
//  CityDistrictInfo.h
//  EasyRequest
//
//  Created by achen on 16/6/7.
//  Copyright © 2016年 achen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CityDistrictInfo : NSObject

@property (nonatomic, copy) NSString *name_cn;

@property (nonatomic, copy) NSString *name_en;

@property (nonatomic, copy) NSString *province_cn;

@property (nonatomic, copy) NSString *district_cn;

@property (nonatomic, assign) NSInteger area_id;

@end
