//
//  ViewController.m
//  EasyRequest
//
//  Created by achen on 16/5/24.
//  Copyright © 2016年 achen. All rights reserved.
//

#import "ViewController.h"
#import "EasyRequest.h"
#import "EasyAdapter.h"
#import "CityDistrictInfo.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self startDNSRequest];
    
    [self startBaiduWeatherReq];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startDNSRequest
{
    EasyRequest *req = [[EasyRequest alloc] initWithPath:@"d"];
    
    NSDictionary *params = @{@"dn":@"apis.baidu.com."};
    
    req.completionHandler = ^(__kindof EasyRequest *request)
    {
        NSString *aString = [[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", aString);
    };
    
    [req startGET:params];
}

//180.149.144.74  180.149.145.78
- (void)startBaiduWeatherReq
{
    NSString *weatherUrlString = WEATHER_BASE_URL;
    //查询可用城市列表（这里返回南京和南京的区县等信息）
    EasyRequest *weatherApi = [[EasyRequest alloc] initWithBaseURLString:weatherUrlString path:@"citylist"];
    NSDictionary *infoDic = @{@"cityname":@"南京", @"host":@"apis.baidu.com"};
    weatherApi.modelClass = [CityDistrictInfo class];
    // model class?  sub request class  TODO:
    weatherApi.completionHandler = ^(EasyRequest *request)
    {
        NSArray *districts = request.responseModel;
        NSLog(@"do nothing");
    };

    [weatherApi startGET:infoDic];
}

@end
