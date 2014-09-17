//
//  CustomerIdTuple.h
//  dev_profile
//
//  Created by aspitz on 6/12/14.
//
//

#import <Foundation/Foundation.h>

@interface CustomerIdTuple : NSObject
@property (nonatomic, copy) NSString *customerId;
@property (nonatomic, copy) NSString *userType;

+ (id)tuple;
@end
