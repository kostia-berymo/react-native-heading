#import "Heading.h"

#import <React/RCTBridge.h>
#import <React/RCTConvert.h>
#import <React/RCTEventEmitter.h>
#import <CoreLocation/CoreLocation.h>

@interface Heading() <CLLocationManagerDelegate>
@property (strong, nonatomic) CLLocationManager *locManager;
@property (nonatomic) CLLocationDirection currentHeading;
@end

@implementation Heading

RCT_EXPORT_MODULE();
@synthesize bridge = _bridge;

#pragma mark Initialization

- (instancetype)init
{
    if (self = [super init]) {
        self.locManager = [[CLLocationManager alloc] init];
        self.locManager.delegate = self;
    }
    
    return self;
}

RCT_REMAP_METHOD(start, start:(int)headingFilter resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
    // Start heading updates.
    if ([CLLocationManager headingAvailable]) {
        if (!headingFilter)
            headingFilter = 5;
        
        self.locManager.headingFilter = headingFilter;
        [self.locManager startUpdatingHeading];
        resolve(@YES);
    } else {
        resolve(@NO);
    }
}

RCT_EXPORT_METHOD(stop) {
    [self.locManager stopUpdatingHeading];
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"headingUpdated"];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    if (newHeading.headingAccuracy < 0)
        return;
    
    // Use the true heading if it is valid.
    CLLocationDirection heading = ((newHeading.trueHeading > 0) ?
                                   newHeading.trueHeading : newHeading.magneticHeading);
    
    [self sendEventWithName:@"headingUpdated" body:@(heading)];
}

+ (BOOL)requiresMainQueueSetup {
    return YES;
}

@end
