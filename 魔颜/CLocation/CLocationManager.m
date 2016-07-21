//
//  CLocationManager.m
//  MMLocationManager
//
//  Created by WangZeKeJi on 14-12-10.
//  Copyright (c) 2014年 Chen Yaoqiang. All rights reserved.
//

#import "CLocationManager.h"
@interface CLocationManager (){
    CLLocationManager *_manager;

}
@property (nonatomic, strong) LocationBlock locationBlock;
@property (nonatomic, strong) NSStringBlock cityBlock;
@property (nonatomic, strong) NSStringBlock addressBlock;
@property (nonatomic, strong) LocationErrorBlock errorBlock;

@end

@implementation CLocationManager

+ (CLocationManager *)shareLocation{
    
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    
    self = [super init];
    if (self) {
        
//        NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
//        float longitude = [standard floatForKey:LastLongitude];
//        float latitude = [standard floatForKey:LastLatitude];
//        self.longitude = longitude;
//        self.latitude = latitude;
//        self.lastCoordinate = CLLocationCoordinate2DMake(longitude,latitude);
//        self.lastCity = [standard objectForKey:LastCity];
//        self.lastAddress=[standard objectForKey:LastAddress];
    }
    return self;
}

//获取经纬度
- (void) getLocationCoordinate:(LocationBlock) locaiontBlock
{
    self.locationBlock = [locaiontBlock copy];
    [self startLocation];
}

- (void) getLocationCoordinate:(LocationBlock) locaiontBlock  withAddress:(NSStringBlock) addressBlock
{
    self.locationBlock = [locaiontBlock copy];
    self.addressBlock = [addressBlock copy];
    [self startLocation];
}

- (void) getAddress:(NSStringBlock)addressBlock
{
    self.addressBlock = [addressBlock copy];
    [self startLocation];
}

//获取省市
- (void) getCity:(NSStringBlock)cityBlock
{
    self.cityBlock = [cityBlock copy];
    [self startLocation];
}

- (void) getCity:(NSStringBlock)cityBlock error:(LocationErrorBlock) errorBlock
{
    self.cityBlock = [cityBlock copy];
    self.errorBlock = [errorBlock copy];
    [self startLocation];
}

#pragma mark CLLocationManagerDelegate
//iOS6.0以上苹果的推荐方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    
     //获取当前城市经纬度
    _lastCoordinate = CLLocationCoordinate2DMake(currentLocation.coordinate.latitude ,currentLocation.coordinate.longitude);
    
    if (_locationBlock) {
        _locationBlock(_lastCoordinate);
        _locationBlock = nil;
    }
    
    NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
    
    [standard setObject:@(currentLocation.coordinate.latitude) forKey:LastLatitude];
    [standard setObject:@(currentLocation.coordinate.longitude) forKey:LastLongitude];
    [standard synchronize];
    
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks,NSError *error)
     {
         if (placemarks.count > 0) {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             
             // Country(国家)  State(城市)  SubLocality(区)
             NSDictionary *test = [placemark addressDictionary];
             
             //省市地址
             _lastCity = [test objectForKey:@"State"];
             [standard setObject:_lastCity forKey:LastCity];
             
             //详细地址
             _lastAddress = test[@"Name"];
             [standard setObject:_lastAddress forKey:LastAddress];
             
             
         }
         if (_cityBlock) {
             _cityBlock(_lastCity);
             _cityBlock = nil;
         }
         if (_addressBlock) {
             _addressBlock(_lastAddress);
             _addressBlock = nil;
         }
         
         
     }];
    
    //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
    [manager stopUpdatingLocation];

    
}

//更新位置后代理方法,iOS6.0一下的方法
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
}

-(void)startLocation
{
//     if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied)
    if([CLLocationManager locationServicesEnabled])
    {
        _manager = [[CLLocationManager alloc]init];
        _manager.delegate = self;
        _manager.desiredAccuracy = kCLLocationAccuracyBest;
        [_manager requestWhenInUseAuthorization]; //使用中授权
        [_manager requestAlwaysAuthorization]; // 永久授权
        _manager.distanceFilter = 100;
        [_manager startUpdatingLocation];

    }
//    else
//    {
//        UIAlertView *alvertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"如果您需要开启定位服务,请到设置->隐私,打开定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
//        [alvertView show];
//        
//    }
    
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    
    //访问被拒绝
    if ([error code] == kCLErrorDenied)
    {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
    }
    //无法获取位置信息
    if ([error code] == kCLErrorLocationUnknown) {
        
    }
    [self stopUpdatingLocation];

}

- (void)stopUpdatingLocation{

    [_manager stopUpdatingLocation];
    _manager = nil;
}


@end
