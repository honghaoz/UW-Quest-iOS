//
//  LocalyticsAppDelegateProxy.h
//  Copyright (C) 2014 Char Software Inc., DBA Localytics
//
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.
//
// Please visit www.localytics.com for more information.

#import <Foundation/Foundation.h>
#import "LocalyticsAppDelegate.h"

@interface LocalyticsAppDelegateProxy : NSProxy<UIApplicationDelegate>

- (id)init;

@property(nonatomic, strong) LocalyticsAppDelegate* localyticsAppDelegate;

@property(nonatomic, strong) NSObject<UIApplicationDelegate>* originalAppDelegate;

@end
