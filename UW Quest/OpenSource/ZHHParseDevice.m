//
//  ZHHParseDevice.m
//  ZHH Track Parse Device
//
//  Created by Zhang Honghao on 6/10/14.
//  Copyright (c) 2014 org-honghao. All rights reserved.
//

#import "ZHHParseDevice.h"
#import "UIApplication+AppVersion.h"
#import "UIDevice-Hardware.h"
#import <Parse/Parse.h>

static NSString *deviceName;
static NSString *identifierForVendor;
static NSString *deviceType;

@implementation ZHHParseDevice

+ (void)trackDevice {
    deviceName = [[UIDevice currentDevice] name];
    identifierForVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    deviceType = [NSString stringWithFormat:@"%@ %@(%@)", [[UIDevice currentDevice] platformString], [[UIDevice currentDevice] platform], [[UIDevice currentDevice] hwmodel]];
    PFQuery *queryForId = [PFQuery queryWithClassName:@"Device"];
    [queryForId whereKey:@"Identifier" equalTo:identifierForVendor];
    [queryForId findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // no object for this id, query with device name
            if (objects.count == 0) {
                NSLog(@"ZHHParseDevice: Query identifier, not found");
                [self queryWithDeviceName];
            }
            else {
                // update found device
                for (PFObject *object in objects) {
                    NSLog(@"ZHHParseDevice: Query identifier succeed, update");
                    object[@"Device_Name"] = deviceName;
                    object[@"Device_Type"] = deviceType;
                    object[@"System_Version"] = [[UIDevice currentDevice] systemVersion];
                    object[@"App_Version"] = [UIApplication appVersion];
                    object[@"Opens"] = [NSNumber numberWithInteger:[object[@"Opens"] integerValue] + 1];
                    NSLog(@"ZHHParseDevice: %ld", (long)[object[@"Opens"] integerValue]);
                    [object saveEventually];
                }
            }
        } else {
            //Query error
            NSLog(@"ZHHParseDevice: Query identifier, error");
        }
    }];
}

+ (void)queryWithDeviceName{
    PFQuery *queryForDeviceName = [PFQuery queryWithClassName:@"Device"];
    [queryForDeviceName whereKey:@"Device_Name" equalTo:deviceName];
    [queryForDeviceName findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 0) {
                NSLog(@"ZHHParseDevice: Query device name, not found, create");
                // if device name is default name, create new default name
                if ([deviceName isEqualToString:@"iPhone"] ||
                    [deviceName isEqualToString:@"iPad"] ||
                    [deviceName isEqualToString:@"iPod touch"]) {
                    [self queryDeviceWithDefaultName:deviceName];
                } else {
                    // create object
                    PFObject *object = [PFObject objectWithClassName:@"Device"];
                    object[@"Device_Name"] = deviceName;
                    object[@"Device_Type"] = deviceType;
                    object[@"System_Version"] = [[UIDevice currentDevice] systemVersion];
                    object[@"App_Version"] = [UIApplication appVersion];
                    object[@"Opens"] = @1;
                    object[@"Identifier"] = identifierForVendor;
                    [object saveEventually];
                }
            }
            // Do something with the found objects
            else {
                for (PFObject *object in objects) {
                    NSLog(@"ZHHParseDevice: Query device name succeed, update");
                    object[@"Device_Name"] = deviceName;
                    object[@"Device_Type"] = deviceType;
                    object[@"System_Version"] = [[UIDevice currentDevice] systemVersion];
                    object[@"App_Version"] = [UIApplication appVersion];
                    object[@"Opens"] = [NSNumber numberWithInteger:[object[@"Opens"] integerValue] + 1];
                    NSLog(@"ZHHParseDevice: %ld", (long)[object[@"Opens"] integerValue]);
                    [object saveEventually];
                }
            }
        } else {
            // Query error
            NSLog(@"ZHHParseDevice: Query device name, error");
        }
    }];
}

+ (void)queryDeviceWithDefaultName:(NSString *)defaultName {
    PFQuery *queryForDeviceName = [PFQuery queryWithClassName:@"Device"];
    [queryForDeviceName whereKey:@"Device_Name" hasPrefix:[@"[***]-" stringByAppendingString:defaultName]];
    [queryForDeviceName findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            if (objects.count == 0) {
                NSLog(@"ZHHParseDevice: Query default name: '%@', not found, create", defaultName);
                // create object
                PFObject *object = [PFObject objectWithClassName:@"Device"];
                // first create, +1
                object[@"Device_Name"] = [@"[***]-" stringByAppendingString:[defaultName stringByAppendingString:@"+1"]];
                object[@"Device_Type"] = deviceType;
                object[@"System_Version"] = [[UIDevice currentDevice] systemVersion];
                object[@"App_Version"] = [UIApplication appVersion];
                object[@"Opens"] = @1;
                object[@"Identifier"] = identifierForVendor;
                [object saveEventually];
            }
            // Do something with the found objects
            else {
                // find the largest object
                PFObject *theLastObject = [objects lastObject];
                NSLog(@"ZHHParseDevice: Query default name: '%@' succeed, create new one", defaultName);
                NSString *lastDefaultName = theLastObject[@"Device_Name"];
                NSRange findRange = [lastDefaultName rangeOfString:@"+"];
                NSInteger lastNumber = [[lastDefaultName substringFromIndex:findRange.location + 1] integerValue];
                NSString *newDefaultName = [@"[***]-" stringByAppendingString:[defaultName stringByAppendingString:[NSString stringWithFormat:@"+%ld", (long)lastNumber + 1]]];
                NSLog(@"ZHHParseDevice: %@", theLastObject[@"Device_Name"]);
                NSLog(@"ZHHParseDevice: new: %@", newDefaultName);
                
                // create a new object
                PFObject *object = [PFObject objectWithClassName:@"Device"];
                object[@"Device_Name"] = newDefaultName;
                object[@"Device_Type"] = deviceType;
                object[@"System_Version"] = [[UIDevice currentDevice] systemVersion];
                object[@"App_Version"] = [UIApplication appVersion];
                object[@"Opens"] = @1;
                object[@"Identifier"] = identifierForVendor;
                [object saveEventually];
            }
        } else {
            // Query error
            NSLog(@"ZHHParseDevice: Query device name, error");
        }
    }];
}

@end
