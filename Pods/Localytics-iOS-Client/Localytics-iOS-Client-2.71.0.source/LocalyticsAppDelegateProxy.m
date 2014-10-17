//
//  LocalyticsAppDelegateProxy.m
//  Copyright (C) 2014 Char Software Inc., DBA Localytics
//
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.
//
// Please visit www.localytics.com for more information.

#import "LocalyticsAppDelegateProxy.h"

@interface LocalyticsAppDelegateProxy ()

- (BOOL)localyticsDelegateRespondsToSelector:(SEL)selector;

@end

@implementation LocalyticsAppDelegateProxy

- (id)init
{
    return self;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = [invocation selector];
    
    if (!self.originalAppDelegate)
    {
        NSException *exception = [NSException exceptionWithName:@"LocalyticsMissingOriginalDelegate"
                                                         reason:@"LocalyticsAppDelegateProxy originalAppDelegate was nil while forwarding an invocation"
                                                       userInfo:nil];
        [exception raise];
    }
    
    if ((selector == @selector(application:openURL:sourceApplication:annotation:)) && [self.originalAppDelegate respondsToSelector:@selector(application:handleOpenURL:)])
    {
        void* application;
        void* url;
        [invocation getArgument:&application atIndex:2];
        [invocation getArgument:&url atIndex:3];
        
        NSMethodSignature* sig = [[self.originalAppDelegate class] instanceMethodSignatureForSelector:@selector(application:handleOpenURL:)];
        NSInvocation* modifiedInvocation = [NSInvocation invocationWithMethodSignature:sig];
        [modifiedInvocation setSelector:@selector(application:handleOpenURL:)];
        [modifiedInvocation setArgument:&application atIndex:2];
        [modifiedInvocation setArgument:&url atIndex:3];
        [modifiedInvocation invokeWithTarget:self.originalAppDelegate];
    }
    else if ([self.originalAppDelegate respondsToSelector:selector])
    {
        [invocation invokeWithTarget:self.originalAppDelegate];
    }
    
    if ([self localyticsDelegateRespondsToSelector:selector])
    {
        [invocation invokeWithTarget:self.localyticsAppDelegate];
    }
}

- (BOOL)localyticsDelegateRespondsToSelector:(SEL)selector
{
    return [self.localyticsAppDelegate respondsToSelector:selector] && ![[UIResponder class] instancesRespondToSelector:selector];
}

- (BOOL)respondsToSelector:(SEL)selector
{
    return [self.originalAppDelegate respondsToSelector:selector] || [self localyticsDelegateRespondsToSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    NSMethodSignature* signature = nil;
    
    signature = [self.originalAppDelegate methodSignatureForSelector:selector];
    if (signature) return signature;
    
    signature = [self.localyticsAppDelegate methodSignatureForSelector:selector];
    if (signature) return signature;
    
    return nil;
}

@end
