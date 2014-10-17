//
//  LocalyticsUtil.m
//  Copyright (C) 2013 Char Software Inc., DBA Localytics
//
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.
//
// Please visit www.localytics.com for more information.

#import <CommonCrypto/CommonDigest.h>
#import "LocalyticsUtil.h"

#define FILE_HASH_CHUNK_SIZE 4096

static BOOL isLoggingEnabled = NO;
static BOOL isAdvertisingIdentifierEnabled = YES;

@implementation LocalyticsUtil

/*!
 @method logMessage
 @abstract Logs a message with (localytics) prepended to it.
 @param message The message to log
 */
+ (void)logMessage:(NSString *)message
{
	NSLog(@"\n(localytics) %@", message);
}

+ (void)setLoggingEnabled:(BOOL)enabled
{
    isLoggingEnabled = enabled;
}

+ (BOOL)loggingEnabled
{
    return isLoggingEnabled;
}

+ (void)setAdvertisingIdentifierEnabled:(BOOL)enabled
{
	isAdvertisingIdentifierEnabled = enabled;
}

+ (BOOL)advertisingIdentifierEnabled
{
	return isAdvertisingIdentifierEnabled;
}

+ (NSString *)valueFromQueryStringKey:(NSString *)queryStringKey url:(NSURL *)url
{
    if (!queryStringKey.length || !url.query)
        return nil;
	
    NSArray *urlComponents = [url.query componentsSeparatedByString:@"&"];
    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *keyValuePairComponents = [keyValuePair componentsSeparatedByString:@"="];
        if ([[keyValuePairComponents objectAtIndex:0] isEqualToString:queryStringKey])
        {
            if(keyValuePairComponents.count == 2)
                return [[keyValuePairComponents objectAtIndex:1]
                        stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return nil;
}

+ (NSString *)md5HashForFileWithPath:(NSString *)filePath
{
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    
    // Get the file URL
    CFURLRef fileURL = CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                                     (CFStringRef)filePath,
                                                     kCFURLPOSIXPathStyle,
                                                     (Boolean)false);
    bool didSucceed = (bool)fileURL;
    if (didSucceed)
    {
        // Create and open the read stream
        readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                                (CFURLRef)fileURL);
        didSucceed = (bool)readStream;
    }
    if (didSucceed)
    {
        didSucceed = (bool)CFReadStreamOpen(readStream);
    }
    if (didSucceed)
    {
        // Initialize the hash object
        CC_MD5_CTX hashObject;
        CC_MD5_Init(&hashObject);
        
        size_t chunkSizeForReadingData = FILE_HASH_CHUNK_SIZE;
        
        // Feed the data to the hash object
        bool hasMoreData = true;
        while (hasMoreData) {
            uint8_t buffer[chunkSizeForReadingData];
            CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                      (UInt8 *)buffer,
                                                      (CFIndex)sizeof(buffer));
            if (readBytesCount < 0)
            {
                break;
            }
            if (readBytesCount == 0)
            {
                hasMoreData = false; // value used later
                continue;
            }
            CC_MD5_Update(&hashObject,
                          (const void *)buffer,
                          (CC_LONG)readBytesCount);
        }
        
        // Check if the read operation succeeded
        didSucceed = !hasMoreData;
        
        // Compute the hash digest
        CC_MD5_Final(digest, &hashObject);
    }
    if (didSucceed)
    {
        // Compute the string result
        char hash[2 * sizeof(digest) + 1];
        for (size_t i = 0; i < sizeof(digest); ++i) {
            snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
        }
        result = CFStringCreateWithCString(kCFAllocatorDefault,
                                           (const char *)hash,
                                           kCFStringEncodingUTF8);
    }
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    if (result) {
        [(NSString *)result autorelease];
    }
    
    return (NSString *)result;
}

+ (NSInvocation *)invocationForSelector:(SEL)selector target:(id)target
{
	NSMethodSignature *signature = [target methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	[invocation setTarget:target];
	[invocation setSelector:selector];
	
	return invocation;
}

@end
