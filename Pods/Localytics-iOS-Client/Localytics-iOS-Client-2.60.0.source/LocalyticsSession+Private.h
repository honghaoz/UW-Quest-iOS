//  LocalyticsSession+Private.h
//  Copyright (C) 2013 Char Software Inc., DBA Localytics
//
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.
//
// Please visit www.localytics.com for more information.

#import "LocalyticsSession.h"
#import "LocalyticsUploader.h"
#import "LocalyticsDatabase.h"

@class CustomerIdTuple;

#define CLIENT_VERSION_PREFIX       @"iOS"

typedef enum {
    LocalyticsUploadEventType,
    LocalyticsUploadProfileType
} LocalyticsUploadType;

@interface LocalyticsSession()
{
    BOOL _hasInitialized;               // Whether or not the session object has been initialized.
	BOOL _isSessionOpen;                // Whether or not this session has been opened.
    float _sessionTimeoutInterval;    // If an App stays in the background for more
										// than this many seconds, start a new session
										// when it returns to foreground.
@private
#pragma mark Member Variables
	dispatch_queue_t _queue;                // Queue of Localytics block objects.
	dispatch_group_t _criticalGroup;        // Group of blocks the must complete before backgrounding.
	NSString *_sessionUUID;                 // Unique identifier for this session.
	NSString *_applicationKey;					// Unique identifier for the instrumented application
	NSTimeInterval _lastSessionStartTimestamp;  // The start time of the most recent session.
	NSDate *_sessionResumeTime;                 // Time session was started or resumed.
	NSDate *_sessionCloseTime;					// Time session was closed.
	NSMutableString *_unstagedFlowEvents;       // Comma-delimited list of app screens and events tagged during this
												// session that have NOT been staged for upload.
	NSMutableString *_stagedFlowEvents;			// App screens and events tagged during this session that HAVE been staged
												// for upload.
	NSMutableString *_screens;              // Comma-delimited list of screens tagged during this session.
	NSTimeInterval _sessionActiveDuration;  // Duration that session open.
	BOOL _sessionHasBeenOpen;               // Whether or not this session has ever been open.
	LocalyticsDatabase *_db;                // Localytics database reference
	LocalyticsUploader *_uploader;          // Localytics uploader reference
}

@property (nonatomic, retain) NSString *applicationKey;
@property (nonatomic,readonly) dispatch_queue_t queue;
@property (nonatomic,readonly) dispatch_group_t criticalGroup;
@property (atomic) BOOL isSessionOpen;
@property (atomic) BOOL hasInitialized;
@property (nonatomic, retain) NSString *sessionUUID;
@property (nonatomic, assign) NSTimeInterval lastSessionStartTimestamp;
@property (nonatomic, retain) NSDate *sessionResumeTime;
@property (nonatomic, retain) NSDate *sessionCloseTime;
@property (nonatomic, retain) NSMutableString *unstagedFlowEvents;
@property (nonatomic, retain) NSMutableString *stagedFlowEvents;
@property (nonatomic, retain) NSMutableString *screens;
@property (nonatomic, assign) NSTimeInterval sessionActiveDuration;
@property (nonatomic, assign) BOOL sessionHasBeenOpen;
@property (nonatomic, assign) NSInteger sessionNumber;
@property (nonatomic, assign) BOOL needsSessionStartActions;
@property (nonatomic, assign) BOOL needsFirstRunActions;
@property (nonatomic, assign) BOOL needsUpgradeActions;
@property (nonatomic, retain) NSString *analyticsHost;
@property (nonatomic, retain) NSString *profilesHost;

// Private methods.
- (void)reopenPreviousSession;
- (void)addFlowEventWithName:(NSString *)name type:(NSString *)eventType;
- (void)addScreenWithName:(NSString *)name;
- (NSString *)blobHeaderStringWithSequenceNumber:(int)nextSequenceNumber;
- (BOOL)ll_isOptedIn;
- (BOOL)createOptEvent:(BOOL)optState;
- (BOOL)saveApplicationFlowAndRemoveOnResume:(BOOL)removeOnResume;
- (NSString *)formatAttributeWithName:(NSString *)paramName value:(NSString *)paramValue;
- (NSString *)formatAttributeWithName:(NSString *)paramName value:(NSString *)paramValue first:(BOOL)firstAttribute;
- (void)uploadCallback:(NSDictionary*)info;
+ (BOOL)appKeyIsValid:(NSString *)appKey;
- (void)ll_open;
- (LocalyticsDatabase *)db;
- (LocalyticsUploader *)uploader;
- (BOOL)uploadIsNeeded:(LocalyticsUploadType)uploadType;
- (void)onStartSession;
- (void)onFirstRun;
- (void)onUpgrade;
- (void)updateFirstAdidIfNeeded;

- (NSString*)libraryVersion;

- (CustomerIdTuple *)customerIdTuple;

// Datapoint methods.
- (NSString *)customDimensions;
- (NSString *)locationDimensions;
- (NSString *)hashString:(NSString *)input;
- (NSString *)randomUUID;
- (NSString *)escapeString:(NSString *)input;
- (NSString *)installationId;
- (NSTimeInterval)currentTimestamp;


// Profile services
@property (nonatomic, assign) BOOL isUploadingProfileEvents;

@property (nonatomic, assign) BOOL useSandbox;

@end

