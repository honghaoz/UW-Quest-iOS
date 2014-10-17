//
//  ProfileEventTuple.h
//  Copyright (C) 2014 Char Software Inc., DBA Localytics
//
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.
//
// Please visit www.localytics.com for more information.
//

#import <Foundation/Foundation.h>

@interface ProfileEventTuple : NSObject
@property (nonatomic, assign) int elementId;
@property (nonatomic, copy) NSString *jsonBlob;
@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *action;
@end
