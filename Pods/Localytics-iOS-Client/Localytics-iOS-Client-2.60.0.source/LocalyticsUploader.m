//  LocalyticsUploader.m
//  Copyright (C) 2013 Char Software Inc., DBA Localytics
//
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.
//
// Please visit www.localytics.com for more information.

#import "LocalyticsUploader.h"
#import "LocalyticsSession.h"
#import "LocalyticsSession+Private.h"
#import "LocalyticsDatabase.h"
#import "LocalyticsDatapointHelper.h"
#import "LocalyticsConstants.h"
#import "LocalyticsUtil.h"
#import "CustomerIdTuple.h"
#import <zlib.h>

#ifndef LOCALYTICS_DEFAULT_HOST
#define LOCALYTICS_DEFAULT_HOST             @"analytics.localytics.com"
#endif

#ifndef LOCALYTICS_PATH
#define LOCALYTICS_PATH                     @"/api/v2/applications/%@/uploads"
#endif

NSString * const kLocalyticsKeyResponseBody = @"localytics.key.responseBody";

@interface LocalyticsUploader ()
- (void)finishUpload;
- (NSData *)gzipDeflatedDataWithData:(NSData *)data;

@property (readwrite) BOOL isUploading;

@end

@implementation LocalyticsUploader
@synthesize isUploading = _isUploading;
@synthesize analyticsHost = _analyticsHost;

- (id)init {
    if (self = [super init]) {
        _analyticsHost = LOCALYTICS_DEFAULT_HOST;
    }
    
    return self;
}

#pragma mark - Class Methods

- (void)uploaderWithApplicationKey:(NSString *)localyticsApplicationKey useHTTPS:(BOOL)useHTTPS installId:(NSString *)installId libraryVersion:(NSString *)libraryVersion
{
	[self uploaderWithApplicationKey:localyticsApplicationKey useHTTPS:useHTTPS installId:installId libraryVersion:libraryVersion completionTarget:nil completionCallback:NULL];
}

- (void)uploaderWithApplicationKey:(NSString *)localyticsApplicationKey useHTTPS:(BOOL)useHTTPS installId:(NSString *)installId libraryVersion:(NSString *)libraryVersion completionTarget:(id)completionTarget completionCallback:(SEL)completionCallback
{
	[self uploaderWithApplicationKey:localyticsApplicationKey useHTTPS:useHTTPS installId:installId libraryVersion:libraryVersion completionTarget:nil completionCallback:NULL prepareUploadTarget:nil prepareUploadCallback:NULL];
}

- (void)uploaderWithApplicationKey:(NSString *)localyticsApplicationKey useHTTPS:(BOOL)useHTTPS installId:(NSString *)installId libraryVersion:(NSString *)libraryVersion completionTarget:(id)completionTarget completionCallback:(SEL)completionCallback prepareUploadTarget:(id)prepareUploadTarget prepareUploadCallback:(SEL)prepareUploadCallback
{
	
	// Do nothing if already uploading.
	if (self.isUploading == true)
	{
		LocalyticsLog("Upload already in progress.  Aborting.");
		return;
	}
	
	if (localyticsApplicationKey == nil)
	{
		LocalyticsLog(@"Unable to upload session. Session never initialized?");
		return;
	}
	
	LocalyticsLog("Beginning upload process");
	self.isUploading = true;
	
	// Prepare the data for upload.  The upload could take a long time, so some effort has to be made to be sure that events
	// which get written while the upload is taking place don't get lost or duplicated.  To achieve this, the logic is:
	// 1) Append every header row blob string and and those of its associated events to the upload string.
	// 2) Deflate and upload the data.
	// 3) On success, delete all blob headers and staged events. Events added while an upload is in process are not
	//    deleted because they are not associated a header (and cannot be until the upload completes).
	
	// Step 1
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	LocalyticsDatabase *db = [[LocalyticsSession shared] db];
	NSString *blobString = [db uploadBlobString];
	
	if ([blobString length] == 0) {
		// There is nothing outstanding to upload.
		LocalyticsLog("Abandoning upload. There are no new events.");
		[pool drain];
		[self finishUpload];
		
		return;
	}
	
    // Allow modifications to the upload body before we send it
    NSString *requestString = nil;
    if (prepareUploadTarget && [prepareUploadTarget respondsToSelector:prepareUploadCallback]) {
        requestString = [[[prepareUploadTarget performSelector:prepareUploadCallback withObject:blobString] copy] autorelease];
        if (!requestString || [requestString length] == 0) {
            LocalyticsLog("Abandoning upload. Prepare upload callback returned empty data.");
            [pool drain];
            [self finishUpload];
            return;
        }
    } else {
        requestString = blobString;
    }
    
	NSData *requestData = [requestString dataUsingEncoding:NSUTF8StringEncoding];
	if(LOCALYTICS_LOGGING_ENABLED) {
		NSString *logString = [[[NSString alloc] initWithData:requestData
													 encoding:NSUTF8StringEncoding] autorelease];
		NSUInteger stringLength = [logString length];
		
		logString = [logString stringByReplacingOccurrencesOfString:@"{"
														 withString:@"\n\t{"];
		logString = [logString stringByReplacingOccurrencesOfString:@",\""
														 withString:@",\n\t\""];
		
		LocalyticsLog("Uploading data (length: %lu)\n%@",
					  (unsigned long)stringLength,
					  logString);
	}
	
	// Step 2
	NSData *deflatedRequestData = [[self gzipDeflatedDataWithData:requestData] retain];
	
	[pool drain];
	
	NSString *urlStringFormat;
    
    /// ### ANALYTICS ENDPOINT ###
    if ([[LocalyticsSession shared]useSandbox]){
        urlStringFormat = @"http://queuer.sandbox53.localytics.com:8080/api/v2/applications/%@/uploads";
    } else {
        if (useHTTPS) {
            urlStringFormat = [NSString stringWithFormat:@"https://%@%@", self.analyticsHost, LOCALYTICS_PATH];
        } else {
            urlStringFormat = [NSString stringWithFormat:@"http://%@%@", self.analyticsHost, LOCALYTICS_PATH];
        }
    }
    
	NSURL *apiUrl = [NSURL URLWithString:[NSString stringWithFormat:urlStringFormat,[localyticsApplicationKey stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
	NSMutableURLRequest *submitRequest = [self createPostRequestWithURL:apiUrl
														  installId:installId
													 libraryVersion:libraryVersion
														requestData:deflatedRequestData];
	
	[deflatedRequestData release];
	
	// Perform synchronous upload in an async dispatch. This is necessary because the calling block will not persist to
	// receive the response data.
	dispatch_group_async([[LocalyticsSession shared] criticalGroup], [[LocalyticsSession shared] queue], ^{
		@try  {
			NSURLResponse *response = nil;
			NSError *responseError = nil;
			NSData  *responseData = [NSURLConnection sendSynchronousRequest:submitRequest returningResponse:&response error:&responseError];
			NSInteger responseStatusCode = [(NSHTTPURLResponse *)response statusCode];
			
			if (responseError) {
				// On error, simply print the error and close the uploader.  We have to assume the data was not transmited
				// so it is not deleted.  In the event that we accidently store data which was succesfully uploaded, the
				// duplicate data will be ignored by the server when it is next uploaded.
				LocalyticsLog("Error Uploading.  Code: %ldd,  Description: %@",
							  (long)[responseError code],
							  [responseError localizedDescription]);
			} else {
				// Step 3
				// While response status codes in the 5xx range leave upload rows intact, the default case is to delete.
				if (responseStatusCode >= 500 && responseStatusCode < 600) {
					LocalyticsLog("Upload failed with response status code %ld", (long)responseStatusCode);
				} else {
					// Because only one instance of the uploader can be running at a time it should not be possible for
					// new upload rows to appear so there is no fear of deleting data which has not yet been uploaded.
					LocalyticsLog("Upload completed successfully. Response code %ld", (long)responseStatusCode);
					[[[LocalyticsSession shared] db] deleteUploadedData];
				}
			}
			
            NSDictionary *userInfo = nil;
			if ([responseData length] > 0) {
				if (LOCALYTICS_LOGGING_ENABLED) {
					NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
					LocalyticsLog("Response body: %@", responseString);
					[responseString release];
				}
                userInfo = [NSDictionary dictionaryWithObject:responseData forKey:kLocalyticsKeyResponseBody];
			}
            if (completionTarget) {
                [completionTarget performSelector:completionCallback withObject:userInfo];
            }
            
			
			[self finishUpload];
		}
		@catch (NSException * e) {}
	});
}

/*
 * Creates a base NSMutableURLRequest with header fields common to all requests
 */
- (NSMutableURLRequest *)createRequestWithURL:(NSURL *)URL installId:(NSString *)installId libraryVersion:(NSString *)libraryVersion
{
    NSMutableURLRequest *submitRequest = [NSMutableURLRequest requestWithURL:URL
																 cachePolicy:NSURLRequestReloadIgnoringCacheData
															 timeoutInterval:60.0];
    
    [submitRequest setValue:[self uploadTimeStamp] forHTTPHeaderField:HEADER_CLIENT_TIME];
	[submitRequest setValue:installId forHTTPHeaderField:HEADER_INSTALL_ID];
	[submitRequest setValue:libraryVersion forHTTPHeaderField:HEADER_CLIENT_VERSION];
    [submitRequest setValue:[LocalyticsDatapointHelper appVersion] forHTTPHeaderField:HEADER_APP_VERSION];
	[submitRequest setValue:@"application/x-gzip" forHTTPHeaderField:@"Content-Type"];
	[submitRequest setValue:@"gzip" forHTTPHeaderField:@"Content-Encoding"];
    [submitRequest setValue:[[LocalyticsSession shared] customerIdTuple].customerId forHTTPHeaderField:HEADER_CUSTOMER_ID];
    
    return submitRequest;
}

/*
 * Creates a post url request
 */
- (NSMutableURLRequest *)createPostRequestWithURL:(NSURL *)URL installId:(NSString *)installId libraryVersion:(NSString *)libraryVersion requestData:(NSData *)requestData
{
    // obtain base url request
	NSMutableURLRequest *submitRequest = [self createRequestWithURL:URL
                                                          installId:installId
                                                     libraryVersion:libraryVersion];
    
    // set http method and body
	[submitRequest setHTTPMethod:@"POST"];
	[submitRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)requestData.length] forHTTPHeaderField:@"Content-Length"];
	[submitRequest setHTTPBody:requestData];
	
	return submitRequest;
}

- (void)finishUpload
{
	self.isUploading = false;
	
	// Upload data has been deleted. Recover the disk space if necessary.
	[[[LocalyticsSession shared] db] vacuumIfRequired];
}

/*!
 @method gzipDeflatedDataWithData
 @abstract Deflates the provided data using gzip at the default compression level (6).
 @return the deflated data
 */
- (NSData *)gzipDeflatedDataWithData:(NSData *)data
{
	if ([data length] == 0) return data;
	
	z_stream strm;
	
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.total_out = 0;
	strm.next_in=(Bytef *)[data bytes];
	strm.avail_in = (unsigned int)[data length];
	
	// Compresssion Levels:
	//   Z_NO_COMPRESSION
	//   Z_BEST_SPEED
	//   Z_BEST_COMPRESSION
	//   Z_DEFAULT_COMPRESSION
	
	if (deflateInit2(&strm, Z_DEFAULT_COMPRESSION, Z_DEFLATED, (15+16), 8, Z_DEFAULT_STRATEGY) != Z_OK) return nil;
	
	NSMutableData *compressed = [NSMutableData dataWithLength:16384];  // 16K chunks for expansion
	
	do {
		
		if (strm.total_out >= [compressed length])
			[compressed increaseLengthBy: 16384];
		
		strm.next_out = [compressed mutableBytes] + strm.total_out;
		strm.avail_out = (unsigned int)([compressed length] - strm.total_out);
		
		deflate(&strm, Z_FINISH);
		
	} while (strm.avail_out == 0);
	
	deflateEnd(&strm);
	
	[compressed setLength: strm.total_out];
	return [NSData dataWithData:compressed];
}

/*!
 @method uploadTimeStamp
 @abstract Gets the current time, along with local timezone, formatted as a DateTime for the webservice.
 @return a DateTime of the current local time and timezone.
 */
- (NSString *)uploadTimeStamp {
	return [ NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970] ];
}

#pragma mark - System Functions

- (id)copyWithZone:(NSZone *)zone {
#pragma unused(zone)
	return self;
}

- (id)retain {
	return self;
}

- (NSUInteger)retainCount {
	// maximum value of an unsigned int - prevents additional retains for the class
	return UINT_MAX;
}

- (oneway void)release {
	// ignore release commands
}

- (id)autorelease {
	return self;
}

@end
