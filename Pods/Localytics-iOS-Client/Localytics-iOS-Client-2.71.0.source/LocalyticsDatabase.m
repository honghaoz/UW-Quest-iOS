//
//  LocalyticsDatabase.m
//  Copyright (C) 2013 Char Software Inc., DBA Localytics
//
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.
//
// Please visit www.localytics.com for more information.

#import "LocalyticsDatabase.h"
#import "LocalyticsSession+Private.h"
#import "LocalyticsConstants.h"
#import "LocalyticsDatapointHelper.h"
#import "LocalyticsUtil.h"
#import "ProfileEventTuple.h"

#define LOCALYTICS_DB               @"localytics"	// File name for the database (without extension)
#define BUSY_TIMEOUT                30              // Maximum time SQlite will busy-wait for the database to unlock before returning SQLITE_BUSY

@interface LocalyticsDatabase ()
- (int)schemaVersion;
- (void)createSchema;
- (void)upgradeToSchemaV2;
- (void)upgradeToSchemaV3;
- (void)upgradeToSchemaV4;
- (void)upgradeToSchemaV5;
- (void)upgradeToSchemaV6;
- (void)upgradeToSchemaV7;
- (void)upgradeToSchemaV8;
- (void)upgradeToSchemaV9;
- (void)upgradeToSchemaV10;
- (void)upgradeToSchemaV11;
- (void)upgradeToSchemaV12;
- (void)upgradeToSchemaV13;
- (void)upgradeToSchemaV14;
- (void)upgradeToSchemaV15;
- (void)upgradeToSchemaV16;
- (void)upgradeToSchemaV17;
- (void)upgradeToSchemaV18;
- (void)upgradeToSchemaV19;
- (void)moveDbToDocuments;
- (void)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
- (NSString *)randomUUID;
@end

@implementation LocalyticsDatabase

@synthesize firstRun = _firstRun;

+ (NSString *)localyticsDirectoryPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return  [[paths objectAtIndex:0] stringByAppendingPathComponent:LOCALYTICS_DIR];
}

+ (NSString *)localyticsDatabasePath {
	NSString *path = [[LocalyticsDatabase localyticsDirectoryPath] stringByAppendingPathComponent:[LocalyticsDatabase localyticsDatabaseFileName]];
	return path;
}

+ (NSString *)localyticsDatabaseFileName {
    return [NSString stringWithFormat:@"%@.sqlite", LOCALYTICS_DB];
}

- (LocalyticsDatabase *)init {
	if((self = [super init])) {
        // if there is an ampData folder left in Documents from really old SDK, remove it
        NSString *outdatedAmpDataPath = [[LocalyticsDatabase localyticsDirectoryPath] stringByAppendingPathComponent:@"ampData"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:outdatedAmpDataPath]) {
            [[NSFileManager defaultManager] removeItemAtPath:outdatedAmpDataPath
                                                       error:nil];
        }
		
		// Create directory structure for Localytics.
		NSString *directoryPath = [LocalyticsDatabase localyticsDirectoryPath];
		if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
		}
        
        // Move any data that a previous library may have left in the caches directory.
        // !!Must be done after directory structure created or copy will fail.
		[self moveDbToDocuments];
		
		// Attempt to open database. It will be created if it does not exist, already.
		NSURL *dbURL = [NSURL fileURLWithPath:[LocalyticsDatabase localyticsDatabasePath]];
		int code =  sqlite3_open([[dbURL path] UTF8String], &_databaseConnection);
		
        // If we were unable to open the database, it is likely corrupted. Clobber it and move on.
		if (code != SQLITE_OK) {
			[[NSFileManager defaultManager] removeItemAtURL:dbURL error:nil];
			code =  sqlite3_open([[dbURL path] UTF8String], &_databaseConnection);
		}
        
        // add the skip backup attribute if it's not currently on the database file. This will handle new databases
        // and existing databases from previous versions.
        if (code == SQLITE_OK) {
            [self addSkipBackupAttributeToItemAtURL:dbURL];
        }
		
		// Enable foreign key constraints.
		if (code == SQLITE_OK) {
			const char *sql = [@"PRAGMA foreign_keys = ON;" cStringUsingEncoding:NSUTF8StringEncoding];
			code = sqlite3_exec(_databaseConnection, sql, NULL, NULL, NULL);
		}
		
		// Check db connection, creating schema if necessary.
        _firstRun = NO;
		if (code == SQLITE_OK) {
			sqlite3_busy_timeout(_databaseConnection, BUSY_TIMEOUT); // Defaults to 0, otherwise.
			if ([self schemaVersion] == 0) {
				[self createSchema];
				_firstRun = YES;
			}
		}
        
		// Perform any Migrations if necessary
		if ([self schemaVersion] < 2) {
			[self upgradeToSchemaV2];
		}
		if ([self schemaVersion] < 3) {
			[self upgradeToSchemaV3];
		}
		if ([self schemaVersion] < 4) {
			[self upgradeToSchemaV4];
		}
		if ([self schemaVersion] < 5) {
			[self upgradeToSchemaV5];
		}
		if ([self schemaVersion] < 6) {
			[self upgradeToSchemaV6];
		}
		if ([self schemaVersion] < 7) {
			[self upgradeToSchemaV7];
		}
		if ([self schemaVersion] < 8) {
			[self upgradeToSchemaV8];
		}
		if ([self schemaVersion] < 9) {
			[self upgradeToSchemaV9];
		}
		if ([self schemaVersion] < 10) {
			[self upgradeToSchemaV10];
		}
		if ([self schemaVersion] < 11) {
			[self upgradeToSchemaV11];
		}
		if ([self schemaVersion] < 12) {
			[self upgradeToSchemaV12];
		}
		if ([self schemaVersion] < 13) {
			[self upgradeToSchemaV13];
		}
		if ([self schemaVersion] < 14) {
			[self upgradeToSchemaV14];
		}
		if ([self schemaVersion] < 15) {
			[self upgradeToSchemaV15];
		}
		if ([self schemaVersion] < 16) {
			[self upgradeToSchemaV16];
		}
		if ([self schemaVersion] < 17) {
			[self upgradeToSchemaV17];
        }
		if ([self schemaVersion] < 18) {
			[self upgradeToSchemaV18];
        }
		if ([self schemaVersion] < 19) {
			[self upgradeToSchemaV19];
        }
	}
	
	return self;
}

#pragma mark - Database

- (BOOL)beginTransaction:(NSString *)name {
	const char *sql = [[NSString stringWithFormat:@"SAVEPOINT %@", name] cStringUsingEncoding:NSUTF8StringEncoding];
	int code = sqlite3_exec(_databaseConnection, sql, NULL, NULL, NULL);
	return code == SQLITE_OK;
}

- (BOOL)releaseTransaction:(NSString *)name {
	const char *sql = [[NSString stringWithFormat:@"RELEASE SAVEPOINT %@", name] cStringUsingEncoding:NSUTF8StringEncoding];
	int code = sqlite3_exec(_databaseConnection, sql, NULL, NULL, NULL);
	return code == SQLITE_OK;
}

- (BOOL)rollbackTransaction:(NSString *)name {
	const char *sql = [[NSString stringWithFormat:@"ROLLBACK SAVEPOINT %@", name] cStringUsingEncoding:NSUTF8StringEncoding];
	int code = sqlite3_exec(_databaseConnection, sql, NULL, NULL, NULL);
	return code == SQLITE_OK;
}

- (int)schemaVersion {
	int version = 0;
	const char *sql = "SELECT MAX(schema_version) FROM localytics_info";
	sqlite3_stmt *selectSchemaVersion;
	if(sqlite3_prepare_v2(_databaseConnection, sql, -1, &selectSchemaVersion, NULL) == SQLITE_OK) {
		if(sqlite3_step(selectSchemaVersion) == SQLITE_ROW) {
			version = sqlite3_column_int(selectSchemaVersion, 0);
		}
	}
	sqlite3_finalize(selectSchemaVersion);
	return version;
}

- (NSString *)installId {
	NSString *installId = nil;
	
	sqlite3_stmt *selectInstallId;
	sqlite3_prepare_v2(_databaseConnection, "SELECT install_id FROM localytics_info", -1, &selectInstallId, NULL);
	int code = sqlite3_step(selectInstallId);
	if (code == SQLITE_ROW && sqlite3_column_text(selectInstallId, 0)) {
		installId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectInstallId, 0)];
	}
	sqlite3_finalize(selectInstallId);
	
	return installId;
}

- (NSString *)appKey {
	NSString *appKey = nil;
	
	sqlite3_stmt *selectAppKey;
	sqlite3_prepare_v2(_databaseConnection, "SELECT app_key FROM localytics_info", -1, &selectAppKey, NULL);
	int code = sqlite3_step(selectAppKey);
	if (code == SQLITE_ROW && sqlite3_column_text(selectAppKey, 0)) {
		appKey = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectAppKey, 0)];
	}
	sqlite3_finalize(selectAppKey);
	
	return appKey;
}

// If the database is in the Caches folder, move it to the Documents folder and mark do not upload
- (void)moveDbToDocuments {
	NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *localyticsDocumentDatabasePath = [[[documentPaths objectAtIndex:0]
                                                 stringByAppendingPathComponent:LOCALYTICS_DIR]
                                                stringByAppendingPathComponent:[LocalyticsDatabase localyticsDatabaseFileName]];
    
	NSArray *cachesPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *localyticsCachesDatabasePath = [[[cachesPaths objectAtIndex:0]
                                               stringByAppendingPathComponent:LOCALYTICS_DIR]
                                              stringByAppendingPathComponent:[LocalyticsDatabase localyticsDatabaseFileName]];
	
	// If the old directory doesn't exist, there is nothing else to do here
	if([[NSFileManager defaultManager] fileExistsAtPath:localyticsCachesDatabasePath] == NO)
	{
		return;
	}
    
    // add attribute before copying so that copied file also has it.
    [self addSkipBackupAttributeToItemAtURL:[NSURL fileURLWithPath:localyticsCachesDatabasePath]];
    
	// Try to move the directory
	if([[NSFileManager defaultManager] copyItemAtPath:localyticsCachesDatabasePath
                                                toPath:localyticsDocumentDatabasePath
                                                 error:nil])
	{
        // on a successful copy, check validity of new database
        NSString *originalFileHash = [LocalyticsUtil md5HashForFileWithPath:localyticsCachesDatabasePath];
        NSString *newFileHash = [LocalyticsUtil md5HashForFileWithPath:localyticsDocumentDatabasePath];
        
        if (![originalFileHash isEqualToString:newFileHash])
        {
            // if the new database is invalid, delete it
            [[NSFileManager defaultManager] removeItemAtPath:localyticsDocumentDatabasePath error:nil];
        }
	}
    
    // Regardless of copy success, delete original
    [[NSFileManager defaultManager] removeItemAtPath:localyticsCachesDatabasePath error:nil];
}

/*
 * Marks the file for exclusion from backups. Returns YES on success,
 * NO on failure or if the file does not exist
 */
- (void)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    NSNumber *currentValue; // current Skip Backup attribute value on the file
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[URL path]] &&
        [URL getResourceValue:&currentValue
                       forKey:NSURLIsExcludedFromBackupKey
                        error:nil])
    { // the file exists and the attribute was successfully read
        if (currentValue == nil || ![currentValue boolValue])
        { // the file does not have the attribute set, or it is set to NO
            
            // attempt to set the attribute to YES
            NSError *error = nil;
            BOOL success = [URL setResourceValue:[NSNumber numberWithBool: YES]
                                          forKey:NSURLIsExcludedFromBackupKey
                                           error:&error];
            
            if(!success){
                LocalyticsLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
            }
        }
    }
}

- (void)createSchema {
	int code = SQLITE_OK;
	
	// Execute schema creation within a single transaction.
	code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"CREATE TABLE upload_headers ("
							"sequence_number INTEGER PRIMARY KEY, "
							"blob_string TEXT)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"CREATE TABLE events ("
							"event_id INTEGER PRIMARY KEY AUTOINCREMENT, " // In case foreign key constraints are reintroduced.
							"upload_header INTEGER, "
							"blob_string TEXT NOT NULL)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"CREATE TABLE localytics_info ("
							"schema_version INTEGER PRIMARY KEY, "
							"last_upload_number INTEGER, "
							"last_session_number INTEGER, "
							"opt_out BOOLEAN, "
							"last_close_event INTEGER, "
							"last_flow_event INTEGER, "
							"last_session_start REAL, "
							"app_key CHAR(64), "
							"custom_d0 CHAR(64), "
							"custom_d1 CHAR(64), "
							"custom_d2 CHAR(64), "
							"custom_d3 CHAR(64) "
							")",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"INSERT INTO localytics_info (schema_version, last_upload_number, last_session_number, opt_out) "
							"VALUES (3, 0, 0, 0)", NULL, NULL, NULL);
	}
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

#pragma mark - Upgrade database
// V2 adds a unique identifier for each installation
// This identifier has been moved to user preferences so the database an live in the caches directory
// Also adds storage for custom dimensions
- (void)upgradeToSchemaV2 {
	int code = SQLITE_OK;
	
	code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD install_id CHAR(40)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD custom_d0 CHAR(64)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD custom_d1 CHAR(64)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD custom_d2 CHAR(64)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		sqlite3_exec(_databaseConnection,
					 "ALTER TABLE localytics_info ADD custom_d3 CHAR(64)",
					 NULL, NULL, NULL);
	}
	
	// Attempt to set schema version and install_id regardless of the result code following the ALTER statements above.
	// This is necessary because a previous version of the library performed the migration without setting these values.
	// The transaction will succeed even if the individual statements fail with errors (eg. "duplicate column name").
	sqlite3_stmt *updateLocalyticsInfo;
	sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info set install_id = ?, schema_version = 2 ", -1, &updateLocalyticsInfo, NULL);
	sqlite3_bind_text (updateLocalyticsInfo, 1, [[self randomUUID] UTF8String], -1, SQLITE_TRANSIENT);
	code = sqlite3_step(updateLocalyticsInfo);
	sqlite3_finalize(updateLocalyticsInfo);
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

// V3 adds a field for the last app key and patches a V2 migration issue.
- (void)upgradeToSchemaV3 {
	int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		sqlite3_exec(_databaseConnection,
					 "ALTER TABLE localytics_info ADD app_key CHAR(64)",
					 NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 3",
							NULL, NULL, NULL);
	}
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

// V4 adds a field for the customer id.
- (void)upgradeToSchemaV4 {
	int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		sqlite3_exec(_databaseConnection,
					 "ALTER TABLE localytics_info ADD customer_id CHAR(64)",
					 NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 4",
							NULL, NULL, NULL);
	}
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

// V5 adds AMP related tables.
- (void)upgradeToSchemaV5 {
	
	int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	//The AMP DB table was initially created here. in Version 7 it will be dropped and re-added with the correct data types.
	//therefore the code that creates it is no longer going to be called here.
	
	//we still want to change the schema version
	
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 5",
							NULL, NULL, NULL);
	}
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

// V6 adds a field for the queued close event blob string.
- (void)upgradeToSchemaV6 {
	int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		sqlite3_exec(_databaseConnection,
					 "ALTER TABLE localytics_info ADD queued_close_event_blob TEXT",
					 NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 6",
							NULL, NULL, NULL);
	}
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV7 {
	int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection, "DROP TABLE IF EXISTS localytics_amp_rule", NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"CREATE TABLE IF NOT EXISTS localytics_amp_rule ("
							"rule_id INTEGER PRIMARY KEY AUTOINCREMENT, "
							"rule_name TEXT UNIQUE,  "
							"expiration INTEGER, "
							"phone_location TEXT, "
							"phone_size_width INTEGER, "
							"phone_size_height INTEGER, "
							"tablet_location TEXT, "
							"tablet_size_width INTEGER, "
							"tablet_size_height INTEGER, "
							"display_seconds INTEGER, "
							"display_session INTEGER, "
							"version INTEGER, "
							"did_display INTEGER, "
							"times_to_display INTEGER, "
							"internet_required INTEGER, "
							"ab_test TEXT"
							")",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"CREATE TABLE IF NOT EXISTS localytics_amp_ruleevent ("
							"rule_id INTEGER, "
							"event_name TEXT, "
							"FOREIGN KEY(rule_id) REFERENCES localytics_amp_rule(rule_id) ON DELETE CASCADE "
							")",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 7",
							NULL, NULL, NULL);
	}
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV8 {
	int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		sqlite3_exec(_databaseConnection,
					 "ALTER TABLE localytics_amp_rule ADD campaign_id INTEGER",
					 NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		sqlite3_exec(_databaseConnection,
					 "ALTER TABLE localytics_amp_rule ADD ttl_expiration INTEGER",
					 NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		sqlite3_exec(_databaseConnection,
					 "ALTER TABLE localytics_amp_rule ADD update_on_ttl_expiration INTEGER",
					 NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 8",
							NULL, NULL, NULL);
	}
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV9 {
	int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		sqlite3_exec(_databaseConnection,
					 "ALTER TABLE localytics_amp_rule ADD location TEXT",
					 NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 9",
							NULL, NULL, NULL);
	}
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV10 {
	int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		sqlite3_exec(_databaseConnection,
					 "ALTER TABLE localytics_amp_rule ADD conversion_expiration INTEGER",
					 NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"CREATE TABLE IF NOT EXISTS localytics_identifiers ("
							"key TEXT PRIMARY KEY, "
							"value TEXT"
							")",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 10",
							NULL, NULL, NULL);
	}
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV11 {
	
	int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		sqlite3_exec(_databaseConnection,
					 "ALTER TABLE localytics_info ADD fb_attribution TEXT",
					 NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		sqlite3_exec(_databaseConnection,
					 "ALTER TABLE localytics_amp_rule ADD devices TEXT",
					 NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"CREATE TABLE IF NOT EXISTS localytics_amp_conditions ("
							"condition_id INTEGER PRIMARY KEY AUTOINCREMENT, "
							"rule_id INTEGER, "
							"attribute_name TEXT, "
							"operator TEXT, "
							"FOREIGN KEY(rule_id) REFERENCES localytics_amp_rule(rule_id) ON DELETE CASCADE "
							")",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"CREATE TABLE IF NOT EXISTS localytics_amp_conditions_values ("
							"condition_id INTEGER, "
							"value TEXT, "
							"FOREIGN KEY(condition_id) REFERENCES localytics_amp_conditions(condition_id) ON DELETE CASCADE "
							")",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 11",
							NULL, NULL, NULL);
	}
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV12 {
	int code = SQLITE_OK;
	
	code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD custom_d4 CHAR(64)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD custom_d5 CHAR(64)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD custom_d6 CHAR(64)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD custom_d7 CHAR(64)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD custom_d8 CHAR(64)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD custom_d9 CHAR(64)",
							NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 12",
							NULL, NULL, NULL);
	}
	
	// Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV13
{
    int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD app_version CHAR(64)",
							NULL, NULL, NULL);
	}
    
    if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 13",
							NULL, NULL, NULL);
	}

    // Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV14
{
    int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD push_token CHAR(64)",
							NULL, NULL, NULL);
	}
    
    if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 14",
							NULL, NULL, NULL);
	}
    
    // Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV15
{
    int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD push_on BOOLEAN",
							NULL, NULL, NULL);
	}
    
    if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 15",
							NULL, NULL, NULL);
	}
    
    // Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV16
{
    int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD dev_push_token CHAR(64)",
							NULL, NULL, NULL);
	}
    
    if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 16",
							NULL, NULL, NULL);
	}
    
    // Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV17
{
    int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD first_adid CHAR(64)",
							NULL, NULL, NULL);
	}
    
	if (code == SQLITE_OK) {
        // Ignore return code, because install_id may already exist for some users
		sqlite3_exec(_databaseConnection,
							"ALTER TABLE localytics_info ADD install_id CHAR(64)",
							NULL, NULL, NULL);
	}
    
    // Migrate or create the install id if needed
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *installId = [prefs stringForKey:@"_localytics_install_id"];
    
    if (installId == nil || [installId isEqualToString:@""])
    {
        // Do we already have one in the DB?
        installId = [self installId];
        
        if (installId == nil || [installId isEqualToString:@""])
        {
            // We need a new one
            installId = [self randomUUID];
        }
    }
        
    if (code == SQLITE_OK) {
        sqlite3_stmt *updateLocalyticsInfo;
        sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info set install_id = ?, schema_version = 17 ", -1, &updateLocalyticsInfo, NULL);
        sqlite3_bind_text (updateLocalyticsInfo, 1, [installId UTF8String], -1, SQLITE_TRANSIENT);
        code = sqlite3_step(updateLocalyticsInfo);
        sqlite3_finalize(updateLocalyticsInfo);
	}
    
    // Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV18
{
	int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);

    // create a new localytics_profile table with an element_id (integer primary key), json_blob (text), and action (text)
    if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"CREATE TABLE IF NOT EXISTS profile ("
							"element_id INTEGER PRIMARY KEY AUTOINCREMENT, "
							"json_blob TEXT, "
							"action TEXT "
							")",
							NULL, NULL, NULL);
	}

	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 18",
							NULL, NULL, NULL);
	}
    
    // Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

- (void)upgradeToSchemaV19
{
	int code = sqlite3_exec(_databaseConnection, "BEGIN", NULL, NULL, NULL);
    
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"ALTER TABLE profile ADD customer_id TEXT",
							NULL, NULL, NULL);
	}
    
	sqlite3_stmt *selectNextProfileEvent;
    ProfileEventTuple *profileEventTuple;
    sqlite3_prepare_v2(_databaseConnection, "SELECT * FROM profile", -1, &selectNextProfileEvent, NULL);
    while (sqlite3_step(selectNextProfileEvent) == SQLITE_ROW)
    {
        // Extract old profile data from database
        profileEventTuple = [[ProfileEventTuple alloc]init];
        profileEventTuple.elementId = sqlite3_column_int(selectNextProfileEvent, 0);
		profileEventTuple.jsonBlob = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectNextProfileEvent, 1)];
		profileEventTuple.action = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectNextProfileEvent, 2)];
        
        // convert jsonBlob into jsonData
        NSData *jsonData = [profileEventTuple.jsonBlob dataUsingEncoding:NSUTF8StringEncoding];
        
        // Extract the customerId associated with this profileEventTuple
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
        profileEventTuple.customerId = jsonDictionary[@"cid"];

        NSDictionary *attributes = jsonDictionary[@"attributes"];
        profileEventTuple.jsonBlob = [LocalyticsSession toJSON:attributes];
        
        // Update profile data to database
        NSString *updateStatemenet = [NSString stringWithFormat:@"UPDATE profile SET json_blob='%@', customer_id='%@' WHERE element_id = '%d'",
                                      profileEventTuple.jsonBlob, profileEventTuple.customerId, profileEventTuple.elementId];
        sqlite3_exec(_databaseConnection, [updateStatemenet UTF8String], NULL, NULL, NULL);
	}
	sqlite3_finalize(selectNextProfileEvent);

    
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info set schema_version = 19",
							NULL, NULL, NULL);
	}
    
    // Commit transaction.
	if (code == SQLITE_OK || code == SQLITE_DONE) {
		sqlite3_exec(_databaseConnection, "COMMIT", NULL, NULL, NULL);
	} else {
		sqlite3_exec(_databaseConnection, "ROLLBACK", NULL, NULL, NULL);
	}
}

#pragma mark - 

- (unsigned long long)databaseSize {
	unsigned long long size = 0;
	NSDictionary *fileAttributes = [[NSFileManager defaultManager]
									attributesOfItemAtPath:[LocalyticsDatabase localyticsDatabasePath]
									error:nil];
	size = [fileAttributes fileSize];
	return size;
}

- (int)eventCount {
	int count = 0;
	const char *sql = "SELECT count(*) FROM events";
	sqlite3_stmt *selectEventCount;
	
	if(sqlite3_prepare_v2(_databaseConnection, sql, -1, &selectEventCount, NULL) == SQLITE_OK)
	{
		if(sqlite3_step(selectEventCount) == SQLITE_ROW) {
			count = sqlite3_column_int(selectEventCount, 0);
		}
	}
	sqlite3_finalize(selectEventCount);
	
	return count;
}

- (NSTimeInterval)createdTimestamp {
	NSTimeInterval timestamp = 0;
	NSDictionary *fileAttributes = [[NSFileManager defaultManager]
									attributesOfItemAtPath:[LocalyticsDatabase localyticsDatabasePath]
									error:nil];
	timestamp = [[fileAttributes fileCreationDate] timeIntervalSince1970];
	return timestamp;
}

- (NSTimeInterval)lastSessionStartTimestamp {
	
	NSTimeInterval lastSessionStart = 0;
	
	sqlite3_stmt *selectLastSessionStart;
	sqlite3_prepare_v2(_databaseConnection, "SELECT last_session_start FROM localytics_info", -1, &selectLastSessionStart, NULL);
	int code = sqlite3_step(selectLastSessionStart);
	if (code == SQLITE_ROW) {
		lastSessionStart = sqlite3_column_double(selectLastSessionStart, 0);
	}
	sqlite3_finalize(selectLastSessionStart);
	
	return lastSessionStart;
}

- (BOOL)setLastSessionStartTimestamp:(NSTimeInterval)timestamp {
	sqlite3_stmt *updateLastSessionStart;
	sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info SET last_session_start = ?", -1, &updateLastSessionStart, NULL);
	sqlite3_bind_double(updateLastSessionStart, 1, timestamp);
	int code = sqlite3_step(updateLastSessionStart);
	sqlite3_finalize(updateLastSessionStart);
	
	return code == SQLITE_DONE;
}

- (BOOL)isOptedOut {
	BOOL optedOut = NO;
	
	sqlite3_stmt *selectOptOut;
	sqlite3_prepare_v2(_databaseConnection, "SELECT opt_out FROM localytics_info", -1, &selectOptOut, NULL);
	int code = sqlite3_step(selectOptOut);
	if (code == SQLITE_ROW) {
		optedOut = sqlite3_column_int(selectOptOut, 0) == 1;
	}
	sqlite3_finalize(selectOptOut);
	
	return optedOut;
}

- (BOOL)setOptedOut:(BOOL)optOut {
	sqlite3_stmt *updateOptedOut;
	sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info SET opt_out = ?", -1, &updateOptedOut, NULL);
	sqlite3_bind_int(updateOptedOut, 1, optOut);
	int code = sqlite3_step(updateOptedOut);
	sqlite3_finalize(updateOptedOut);
	
	return code == SQLITE_OK;
}

- (NSString *)appVersion {
	NSString *appVersion = nil;
	
	sqlite3_stmt *selectAppVersion;
	sqlite3_prepare_v2(_databaseConnection, "SELECT app_version FROM localytics_info", -1, &selectAppVersion, NULL);
	int code = sqlite3_step(selectAppVersion);
	if (code == SQLITE_ROW) {
		char* chars = (char *)sqlite3_column_text(selectAppVersion, 0);
		if(chars) appVersion = [NSString stringWithUTF8String:chars];
	}
	sqlite3_finalize(selectAppVersion);
	
	return appVersion;
}

- (BOOL)updateAppVersion:(NSString *)appVersion {
	sqlite3_stmt *updateAppVersion;
	sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info set app_version = ?", -1, &updateAppVersion, NULL);
	sqlite3_bind_text (updateAppVersion, 1, [appVersion UTF8String], -1, SQLITE_TRANSIENT);
	int code = sqlite3_step(updateAppVersion);
	sqlite3_finalize(updateAppVersion);
	return (code == SQLITE_DONE);
}

- (BOOL)isPushTokenNull {
	BOOL isPushTokenNull = NO;
	
	sqlite3_stmt *selectPushToken;
	sqlite3_prepare_v2(_databaseConnection, "SELECT push_token FROM localytics_info", -1, &selectPushToken, NULL);
	int code = sqlite3_step(selectPushToken);
	if (code == SQLITE_ROW) {
        isPushTokenNull = (SQLITE_NULL == sqlite3_column_type(selectPushToken, 0));
	}
	sqlite3_finalize(selectPushToken);
	
	return isPushTokenNull;
}

- (NSString *)pushToken {
	NSString *pushToken = nil;
	
	sqlite3_stmt *selectPushToken;
	sqlite3_prepare_v2(_databaseConnection, "SELECT push_token FROM localytics_info", -1, &selectPushToken, NULL);
	int code = sqlite3_step(selectPushToken);
	if (code == SQLITE_ROW) {
		char* chars = (char *)sqlite3_column_text(selectPushToken, 0);
		if(chars) pushToken = [NSString stringWithUTF8String:chars];
	}
	sqlite3_finalize(selectPushToken);
	
	return pushToken;
}

- (BOOL)updatePushToken:(NSString *)pushToken {
	sqlite3_stmt *updatePushToken;
	sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info set push_token = ?", -1, &updatePushToken, NULL);
	sqlite3_bind_text (updatePushToken, 1, [pushToken UTF8String], -1, SQLITE_TRANSIENT);
	int code = sqlite3_step(updatePushToken);
	sqlite3_finalize(updatePushToken);
	return (code == SQLITE_DONE);
}

- (BOOL)isDevPushTokenNull {
	BOOL isDevPushTokenNull = NO;
	
	sqlite3_stmt *selectDevPushToken;
	sqlite3_prepare_v2(_databaseConnection, "SELECT dev_push_token FROM localytics_info", -1, &selectDevPushToken, NULL);
	int code = sqlite3_step(selectDevPushToken);
	if (code == SQLITE_ROW) {
        isDevPushTokenNull = (SQLITE_NULL == sqlite3_column_type(selectDevPushToken, 0));
	}
	sqlite3_finalize(selectDevPushToken);
	
	return isDevPushTokenNull;
}

- (NSString *)devPushToken {
	NSString *devPushToken = nil;
	
	sqlite3_stmt *selectDevPushToken;
	sqlite3_prepare_v2(_databaseConnection, "SELECT dev_push_token FROM localytics_info", -1, &selectDevPushToken, NULL);
	int code = sqlite3_step(selectDevPushToken);
	if (code == SQLITE_ROW) {
		char* chars = (char *)sqlite3_column_text(selectDevPushToken, 0);
		if(chars) devPushToken = [NSString stringWithUTF8String:chars];
	}
	sqlite3_finalize(selectDevPushToken);
	
	return devPushToken;
}

- (BOOL)updateDevPushToken:(NSString *)devPushToken {
	sqlite3_stmt *updateDevPushToken;
	sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info set dev_push_token = ?", -1, &updateDevPushToken, NULL);
	sqlite3_bind_text (updateDevPushToken, 1, [devPushToken UTF8String], -1, SQLITE_TRANSIENT);
	int code = sqlite3_step(updateDevPushToken);
	sqlite3_finalize(updateDevPushToken);
	return (code == SQLITE_DONE);
}

- (BOOL)isFirstAdidNull
{
    BOOL isFirstAdidNull = NO;
	
	sqlite3_stmt *selectFirstAdid;
	sqlite3_prepare_v2(_databaseConnection, "SELECT first_adid FROM localytics_info", -1, &selectFirstAdid, NULL);
	int code = sqlite3_step(selectFirstAdid);
	if (code == SQLITE_ROW) {
        isFirstAdidNull = (SQLITE_NULL == sqlite3_column_type(selectFirstAdid, 0));
	}
	sqlite3_finalize(selectFirstAdid);
	
	return isFirstAdidNull;
}

- (BOOL)updateFirstAdid:(NSString *)firstAdid
{
	sqlite3_stmt *updateFirstAdid;
	sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info set first_adid = ?", -1, &updateFirstAdid, NULL);
	sqlite3_bind_text (updateFirstAdid, 1, [firstAdid UTF8String], -1, SQLITE_TRANSIENT);
	int code = sqlite3_step(updateFirstAdid);
	sqlite3_finalize(updateFirstAdid);
	return (code == SQLITE_DONE);
}

- (NSString *)firstAdid;
{
	NSString *firstAdid = nil;
	
	sqlite3_stmt *selectFirstAdid;
	sqlite3_prepare_v2(_databaseConnection, "SELECT first_adid FROM localytics_info", -1, &selectFirstAdid, NULL);
	int code = sqlite3_step(selectFirstAdid);
	if (code == SQLITE_ROW) {
		char* chars = (char *)sqlite3_column_text(selectFirstAdid, 0);
		if(chars) firstAdid = [NSString stringWithUTF8String:chars];
	}
	sqlite3_finalize(selectFirstAdid);
	
	return firstAdid;
}

- (NSString *)customDimension:(int)dimension {
	if(dimension < 0 || dimension > 9) {
		return nil;
	}
	
	NSString *value = nil;
	NSString *query = [NSString stringWithFormat:@"select custom_d%i from localytics_info", dimension];
	
	sqlite3_stmt *selectCustomDim;
	sqlite3_prepare_v2(_databaseConnection, [query UTF8String], -1, &selectCustomDim, NULL);
	int code = sqlite3_step(selectCustomDim);
	if (code == SQLITE_ROW && sqlite3_column_text(selectCustomDim, 0)) {
		value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectCustomDim, 0)];
	}
	sqlite3_finalize(selectCustomDim);
	
	return value;
}

- (BOOL)setCustomDimension:(int)dimension value:(NSString *)value {
	if(dimension < 0 || dimension > 9) {
		return false;
	}
	
	NSString *query = [NSString stringWithFormat:@"update localytics_info SET custom_d%i = %@",
					   dimension,
					   (value == nil) ? @"null" : [NSString stringWithFormat:@"\"%@\"", value]];
	
	int code = sqlite3_exec(_databaseConnection, [query UTF8String], NULL, NULL, NULL);
	
	return code == SQLITE_OK;
}

- (BOOL)incrementLastUploadNumber:(int *)uploadNumber {
	NSString *t = @"increment_upload_number";
	int code = SQLITE_OK;
	
	code = [self beginTransaction:t] ? SQLITE_OK : SQLITE_ERROR;
	
	if(code == SQLITE_OK) {
		// Increment value
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info "
							"SET last_upload_number = (last_upload_number + 1)",
							NULL, NULL, NULL);
	}
	
	if(code == SQLITE_OK) {
		// Retrieve new value
		sqlite3_stmt *selectUploadNumber;
		sqlite3_prepare_v2(_databaseConnection,
						   "SELECT last_upload_number FROM localytics_info",
						   -1, &selectUploadNumber, NULL);
		code = sqlite3_step(selectUploadNumber);
		if (code == SQLITE_ROW) {
			*uploadNumber = sqlite3_column_int(selectUploadNumber, 0);
		}
		sqlite3_finalize(selectUploadNumber);
	}
	
	if(code == SQLITE_ROW) {
		[self releaseTransaction:t];
	} else {
		[self rollbackTransaction:t];
	}
	
	return code == SQLITE_ROW;
}

- (BOOL)incrementLastSessionNumber:(int *)sessionNumber {
	NSString *t = @"increment_session_number";
	int code = [self beginTransaction:t] ? SQLITE_OK : SQLITE_ERROR;
	
	if(code == SQLITE_OK) {
		// Increment value
		code = sqlite3_exec(_databaseConnection,
							"UPDATE localytics_info "
							"SET last_session_number = (last_session_number + 1)",
							NULL, NULL, NULL);
	}
	
	if(code == SQLITE_OK) {
		// Retrieve new value
		sqlite3_stmt *selectSessionNumber;
		sqlite3_prepare_v2(_databaseConnection,
						   "SELECT last_session_number FROM localytics_info",
						   -1, &selectSessionNumber, NULL);
		code = sqlite3_step(selectSessionNumber);
		if (code == SQLITE_ROW && sessionNumber != NULL) {
			*sessionNumber = sqlite3_column_int(selectSessionNumber, 0);
		}
		sqlite3_finalize(selectSessionNumber);
	}
	
	if(code == SQLITE_ROW) {
		[self releaseTransaction:t];
	} else {
		[self rollbackTransaction:t];
	}
	
	return code == SQLITE_ROW;
}

- (BOOL)addEventWithBlobString:(NSString *)blob {
	
	int code = SQLITE_OK;
	sqlite3_stmt *insertEvent;
	sqlite3_prepare_v2(_databaseConnection, "INSERT INTO events (blob_string) VALUES (?)", -1, &insertEvent, NULL);
	sqlite3_bind_text(insertEvent, 1, [blob UTF8String], -1, SQLITE_TRANSIENT);
	code = sqlite3_step(insertEvent);
	sqlite3_finalize(insertEvent);
	
	return code == SQLITE_DONE;
}

- (BOOL)addCloseEventWithBlobString:(NSString *)blob {
	NSString *t = @"add_close_event";
	BOOL success = [self beginTransaction:t];
	
	// Add close event.
	if (success) {
		success = [self addEventWithBlobString:blob];
	}
	
	// Record row id to localytics_info so that it can be removed if the session resumes.
	if (success) {
		sqlite3_stmt *updateCloseEvent;
		sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info SET last_close_event = (SELECT event_id FROM events WHERE rowid = ?)", -1, &updateCloseEvent, NULL);
		sqlite3_int64 lastRow = sqlite3_last_insert_rowid(_databaseConnection);
		sqlite3_bind_int64(updateCloseEvent, 1, lastRow);
		int code = sqlite3_step(updateCloseEvent);
		sqlite3_finalize(updateCloseEvent);
		success = code == SQLITE_DONE;
	}
	
	if (success) {
		[self releaseTransaction:t];
	} else {
		[self rollbackTransaction:t];
	}
	return success;
}

- (BOOL)queueCloseEventWithBlobString:(NSString *)blob {
	NSString *t = @"queue_close_event";
	BOOL success = [self beginTransaction:t];
	
	// Queue close event.
	if (success) {
		sqlite3_stmt *queueCloseEvent;
		sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info SET queued_close_event_blob = ?", -1, &queueCloseEvent, NULL);
		sqlite3_bind_text(queueCloseEvent, 1, [blob UTF8String], -1, SQLITE_TRANSIENT);
		int code = sqlite3_step(queueCloseEvent);
		sqlite3_finalize(queueCloseEvent);
		success = code == SQLITE_DONE;
	}
	
	if (success) {
		[self releaseTransaction:t];
	} else {
		[self rollbackTransaction:t];
	}
	return success;
}

- (NSString *)dequeueCloseEventBlobString {
	NSString *value = nil;
	NSString *query = @"SELECT queued_close_event_blob FROM localytics_info";
	
	sqlite3_stmt *selectStmt;
	sqlite3_prepare_v2(_databaseConnection, [query UTF8String], -1, &selectStmt, NULL);
	int code = sqlite3_step(selectStmt);
	if (code == SQLITE_ROW && sqlite3_column_text(selectStmt, 0)) {
		value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectStmt, 0)];
	}
	sqlite3_finalize(selectStmt);
	
	// Clear the queued close event blob.
	[self queueCloseEventWithBlobString:nil];
	
	return value;
}

- (BOOL)addFlowEventWithBlobString:(NSString *)blob {
	NSString *t = @"add_flow_event";
	BOOL success = [self beginTransaction:t];
	
	// Add flow event.
	if (success) {
		success = [self addEventWithBlobString:blob];
	}
	
	// Record row id to localytics_info so that it can be removed if the session resumes.
	if (success) {
		sqlite3_stmt *updateFlowEvent;
		sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info SET last_flow_event = (SELECT event_id FROM events WHERE rowid = ?)", -1, &updateFlowEvent, NULL);
		sqlite3_int64 lastRow = sqlite3_last_insert_rowid(_databaseConnection);
		sqlite3_bind_int64(updateFlowEvent, 1, lastRow);
		int code = sqlite3_step(updateFlowEvent);
		sqlite3_finalize(updateFlowEvent);
		success = code == SQLITE_DONE;
	}
	
	if (success) {
		[self releaseTransaction:t];
	} else {
		[self rollbackTransaction:t];
	}
	return success;
}

- (BOOL)removeLastCloseAndFlowEvents {
	// Attempt to remove the last recorded close event.
	// Fail quietly if none was saved or it was previously removed.
	int code = sqlite3_exec(_databaseConnection, "DELETE FROM events WHERE event_id = (SELECT last_close_event FROM localytics_info) OR event_id = (SELECT last_flow_event FROM localytics_info)", NULL, NULL, NULL);
	
	return code == SQLITE_OK;
}

- (BOOL)addHeaderWithSequenceNumber:(int)number blobString:(NSString *)blob rowId:(sqlite3_int64 *)insertedRowId {
	sqlite3_stmt *insertHeader;
	sqlite3_prepare_v2(_databaseConnection, "INSERT INTO upload_headers (sequence_number, blob_string) VALUES (?, ?)", -1, &insertHeader, NULL);
	sqlite3_bind_int(insertHeader, 1, number);
	sqlite3_bind_text(insertHeader, 2, [blob UTF8String], -1, SQLITE_TRANSIENT);
	int code = sqlite3_step(insertHeader);
	sqlite3_finalize(insertHeader);
	
	if (code == SQLITE_DONE && insertedRowId != NULL) {
		*insertedRowId = sqlite3_last_insert_rowid(_databaseConnection);
	}
	
	return code == SQLITE_DONE;
}

- (int)unstagedEventCount {
	int rowCount = 0;
	sqlite3_stmt *selectEventCount;
	sqlite3_prepare_v2(_databaseConnection, "SELECT COUNT(*) FROM events WHERE UPLOAD_HEADER IS NULL", -1, &selectEventCount, NULL);
	int code = sqlite3_step(selectEventCount);
	if (code == SQLITE_ROW) {
		rowCount = sqlite3_column_int(selectEventCount, 0);
	}
	sqlite3_finalize(selectEventCount);
	
	return rowCount;
}

- (BOOL)stageEventsForUpload:(sqlite3_int64)headerId {
	
	// Associate all outstanding events with the given upload header ID.
	NSString *stageEvents = [NSString stringWithFormat:@"UPDATE events SET upload_header = ? WHERE upload_header IS NULL"];
	sqlite3_stmt *updateEvents;
	sqlite3_prepare_v2(_databaseConnection, [stageEvents UTF8String], -1, &updateEvents, NULL);
	sqlite3_bind_int64(updateEvents, 1, headerId);
	int code = sqlite3_step(updateEvents);
	sqlite3_finalize(updateEvents);
	BOOL success = (code == SQLITE_DONE);
	
	return success;
}

- (BOOL)updateAppKey:(NSString *)appKey {
	sqlite3_stmt *updateAppKey;
	sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_info set app_key = ?", -1, &updateAppKey, NULL);
	sqlite3_bind_text (updateAppKey, 1, [appKey UTF8String], -1, SQLITE_TRANSIENT);
	int code = sqlite3_step(updateAppKey);
	sqlite3_finalize(updateAppKey);
	BOOL success = (code == SQLITE_DONE);
	
	return success;
}

- (NSString *)uploadBlobString {
	
	// Retrieve the blob strings of each upload header and its child events, in order.
	const char *sql = "SELECT * FROM ( "
	"   SELECT h.blob_string AS 'blob', h.sequence_number as 'seq', 0 FROM upload_headers h"
	"   UNION ALL "
	"   SELECT e.blob_string AS 'blob', e.upload_header as 'seq', 1 FROM events e"
	") "
	"ORDER BY 2, 3";
	sqlite3_stmt *selectBlobs;
	sqlite3_prepare_v2(_databaseConnection, sql, -1, &selectBlobs, NULL);
	NSMutableString *uploadBlobString = [NSMutableString string];
	while (sqlite3_step(selectBlobs) == SQLITE_ROW) {
		const char *blob = (const char *)sqlite3_column_text(selectBlobs, 0);
		if (blob != NULL) {
			NSString *blobString = [[NSString alloc] initWithCString:blob encoding:NSUTF8StringEncoding];
			[uploadBlobString appendString:blobString];
			[blobString release];
		}
	}
	sqlite3_finalize(selectBlobs);
	
	return [[uploadBlobString copy] autorelease];
}

- (BOOL)deleteUploadedData {
	// Delete all headers and staged events.
	NSString *t = @"delete_upload_data";
	int code = [self beginTransaction:t] ? SQLITE_OK : SQLITE_ERROR;
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection, "DELETE FROM events WHERE upload_header IS NOT NULL", NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection, "DELETE FROM upload_headers", NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		[self releaseTransaction:t];
	} else {
		[self rollbackTransaction:t];
	}
	
	return code == SQLITE_OK;
}

- (BOOL)resetAnalyticsData {
	// Delete or zero all analytics data.
	// Reset: headers, events, session number, upload number, last session start, last close event, and last flow event.
	// Unaffected: schema version, opt out status, install ID (deprecated), and app key.
	
	NSString *t = @"reset_analytics_data";
	int code = [self beginTransaction:t] ? SQLITE_OK : SQLITE_ERROR;
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection, "DELETE FROM events", NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection, "DELETE FROM upload_headers", NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection, "DELETE FROM localytics_amp_rule", NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection, "DELETE FROM localytics_amp_ruleevent", NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection, "DELETE FROM localytics_amp_conditions", NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection, "DELETE FROM localytics_amp_conditions_values", NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection, "DELETE FROM localytics_identifiers", NULL, NULL, NULL);
	}
	
	if (code == SQLITE_OK) {
		code = sqlite3_exec(_databaseConnection,"UPDATE localytics_info SET last_session_number = 0, last_upload_number = 0,"
							"last_close_event = null, last_flow_event = null, last_session_start = null, "
							"custom_d0 = null, custom_d1 = null, custom_d2 = null, custom_d3 = null, "
							"queued_close_event_blob = null, fb_attribution = null",
							NULL, NULL, NULL);
	}
	
	
	if (code == SQLITE_OK) {
		[self releaseTransaction:t];
	} else {
		[self rollbackTransaction:t];
	}
	
	return code == SQLITE_OK;
}

- (BOOL)vacuumIfRequired {
	int code = SQLITE_OK;
	if ([self databaseSize] > MAX_DATABASE_SIZE * VACUUM_THRESHOLD) {
		code =  sqlite3_exec(_databaseConnection, "VACUUM", NULL, NULL, NULL);
	}
	
	return code == SQLITE_OK;
}

- (NSString *)randomUUID {
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef stringUUID = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return [(NSString *)stringUUID autorelease];
}

- (BOOL)setValueForIdentifier:(NSString *)identifierName value:(NSString *)value
{
	sqlite3_stmt *sqlRule;
	if([self valueForIdentifier:identifierName]) {
		// Update
		sqlite3_prepare_v2(_databaseConnection, "UPDATE localytics_identifiers SET value=? WHERE key=?", -1, &sqlRule, NULL);
		sqlite3_bind_text(sqlRule, 1, [value UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(sqlRule, 2, [identifierName UTF8String], -1, SQLITE_TRANSIENT);
	} else {
		// Insert
		sqlite3_prepare_v2(_databaseConnection, "INSERT INTO localytics_identifiers (value, key) VALUES (?, ?)", -1, &sqlRule, NULL);
		sqlite3_bind_text(sqlRule, 1, [value UTF8String], -1, SQLITE_TRANSIENT);
		sqlite3_bind_text(sqlRule, 2, [identifierName UTF8String], -1, SQLITE_TRANSIENT);
	}
	
	int code = sqlite3_step(sqlRule);
	sqlite3_finalize(sqlRule);
	
	return code == SQLITE_DONE;
}

- (NSString *)valueForIdentifier:(NSString *)identifierName
{
	NSString *value = nil;
	
	sqlite3_stmt *selectRuleId;
	sqlite3_prepare_v2(_databaseConnection, "SELECT value FROM localytics_identifiers WHERE key = ?", -1, &selectRuleId, NULL);
	sqlite3_bind_text(selectRuleId, 1, [identifierName UTF8String], -1, SQLITE_TRANSIENT);
	
	int code = sqlite3_step(selectRuleId);
	if (code == SQLITE_ROW && sqlite3_column_text(selectRuleId, 0)) {
		value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectRuleId, 0)];
	}
	sqlite3_finalize(selectRuleId);
	
	return value;
}

- (BOOL)deleteIdentifer:(NSString *)identifierName
{
	sqlite3_stmt *deleteRule;
	sqlite3_prepare_v2(_databaseConnection, "DELETE FROM localytics_identifiers WHERE key  = ?", -1, &deleteRule, NULL);
	sqlite3_bind_text(deleteRule, 1, [identifierName UTF8String], -1, SQLITE_TRANSIENT);
	int code = sqlite3_step(deleteRule);
	sqlite3_finalize(deleteRule);
	
	return (code == SQLITE_DONE);;
}

- (NSDictionary *)identifiers
{
	NSMutableDictionary *identifiers = nil;
	
	sqlite3_stmt *selectRule;
	sqlite3_prepare_v2(_databaseConnection, "SELECT key, value FROM localytics_identifiers", -1, &selectRule, NULL);
	
	while (sqlite3_step(selectRule) == SQLITE_ROW)
	{
		NSString *key = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectRule, 0)];
		NSString *value = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectRule, 1)];
		
		if(key.length > 0 && value.length > 0)
		{
			// Defer allocation of the dictionary until we know we need it
			// This also allows us to return nil in the event of an empty set
			//
			if(!identifiers)
			{
				identifiers = [NSMutableDictionary dictionary];
			}
			
			[identifiers setObject:value forKey:key];
		}
	}
	sqlite3_finalize(selectRule);
	
	return [[identifiers copy] autorelease];
}


#pragma mark - Safe NSDictionary value methods

- (NSInteger)safeIntegerValueFromDictionary:(NSDictionary *)dict forKey:(NSString *)key
{
	NSInteger integerValue = 0;
	id value = [dict objectForKey:key];
	if ([value isKindOfClass:[NSNumber class]] || [value isKindOfClass:[NSString class]]) {
		integerValue = [value integerValue];
	} else if ([value isKindOfClass:[NSNull class]]) {
		integerValue = 0;
	}
	
	return integerValue;
}

- (NSString *)safeStringValueFromDictionary:(NSDictionary *)dict forKey:(NSString *)key
{
	NSString *stringValue = nil;
	id value = [dict objectForKey:key];
	if ([value isKindOfClass:[NSString class]]) {
		stringValue = value;
	} else if ([value isKindOfClass:[NSNumber class]]) {
		stringValue = [value stringValue];
	} else if ([value isKindOfClass:[NSNull class]]) {
		stringValue = nil;
	}
	
	return stringValue;
}

- (NSDictionary *)safeDictionaryFromDictionary:(NSDictionary *)dict forKey:(NSString *)key
{
	NSDictionary *dictValue = nil;
	id value = [dict objectForKey:key];
	if ([value isKindOfClass:[NSDictionary class]]) {
		dictValue = value;
	}
	return dictValue;
}

- (NSArray *)safeListFromDictionary:(NSDictionary *)dict forKey:(NSString *)key
{
	NSArray *arrayValue = nil;
	id value = [dict objectForKey:key];
	if ([value isKindOfClass:[NSArray class]]) {
		arrayValue = value;
	}
	return arrayValue;
}

#pragma mark - Profiles

- (BOOL)queueProfileEventTuple:(ProfileEventTuple *)profileEventTuple{
	sqlite3_stmt *sqlInsert;
    
    // Insert
    sqlite3_prepare_v2(_databaseConnection, "INSERT INTO profile (json_blob, action, customer_id) VALUES (?, ?, ?)", -1, &sqlInsert, NULL);
    sqlite3_bind_text(sqlInsert, 1, [profileEventTuple.jsonBlob UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(sqlInsert, 2, [profileEventTuple.action UTF8String], -1, SQLITE_TRANSIENT);
    sqlite3_bind_text(sqlInsert, 3, [profileEventTuple.customerId UTF8String], -1, SQLITE_TRANSIENT);
	
	int code = sqlite3_step(sqlInsert);
	sqlite3_finalize(sqlInsert);
	
	return (code == SQLITE_DONE);
}

- (ProfileEventTuple *)getNextProfileEventTuple{
    ProfileEventTuple *profileEventTuple = nil;
    
	sqlite3_stmt *selectNextProfileEvent;
	sqlite3_prepare_v2(_databaseConnection, "SELECT * FROM profile ORDER BY element_id ASC LIMIT 1", -1, &selectNextProfileEvent, NULL);
	int code = sqlite3_step(selectNextProfileEvent);
	if (code == SQLITE_ROW) {
        profileEventTuple = [[ProfileEventTuple alloc]init];
        profileEventTuple.elementId = sqlite3_column_int(selectNextProfileEvent, 0);
		profileEventTuple.jsonBlob = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectNextProfileEvent, 1)];
		profileEventTuple.action = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectNextProfileEvent, 2)];
		profileEventTuple.customerId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectNextProfileEvent, 3)];
	}
	sqlite3_finalize(selectNextProfileEvent);
	
	return [profileEventTuple autorelease];
}

- (NSArray *)getAllProfileEvents
{
    NSMutableArray *profileEventTuples = [NSMutableArray array];
	sqlite3_stmt *selectNextProfileEvent;
    sqlite3_prepare_v2(_databaseConnection, "SELECT * FROM profile", -1, &selectNextProfileEvent, NULL);
    while (sqlite3_step(selectNextProfileEvent) == SQLITE_ROW)
    {
        // Extract old profile data from database
        ProfileEventTuple *profileEventTuple = [[ProfileEventTuple alloc]init];
        profileEventTuple.elementId = sqlite3_column_int(selectNextProfileEvent, 0);
		profileEventTuple.jsonBlob = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectNextProfileEvent, 1)];
		profileEventTuple.action = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectNextProfileEvent, 2)];
		profileEventTuple.customerId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(selectNextProfileEvent, 3)];
        [profileEventTuples addObject:profileEventTuple];
	}
	sqlite3_finalize(selectNextProfileEvent);
    
    return profileEventTuples;
}

- (BOOL)deleteProfileEvents:(NSArray *)profileEventIds
{
    BOOL success = YES;

    if (profileEventIds.count > 0){
        NSString *joinedProfileEventIds = [profileEventIds componentsJoinedByString:@","];
        NSString *deleteStatement = [NSString stringWithFormat:@"DELETE FROM profile WHERE element_id IN (%@)",joinedProfileEventIds];
        int code = sqlite3_exec(_databaseConnection, [deleteStatement UTF8String], NULL, NULL, NULL);
        success = (code == SQLITE_DONE);
    }
    
    return success;
}

- (BOOL)deleteProfileEventTuple:(ProfileEventTuple *)profileEventTuple{
	sqlite3_stmt *deleteProfileEvent;
	sqlite3_prepare_v2(_databaseConnection, "DELETE FROM profile WHERE element_id = ?", -1, &deleteProfileEvent, NULL);
    sqlite3_bind_int(deleteProfileEvent, 1, profileEventTuple.elementId);
    int code = sqlite3_step(deleteProfileEvent);
	sqlite3_finalize(deleteProfileEvent);
	
    return (code == SQLITE_DONE);
}

- (NSInteger)profileEventCount{
	int rowCount = 0;
	sqlite3_stmt *selectEventCount;
	sqlite3_prepare_v2(_databaseConnection, "SELECT COUNT(*) FROM profile", -1, &selectEventCount, NULL);
	int code = sqlite3_step(selectEventCount);
	if (code == SQLITE_ROW) {
		rowCount = sqlite3_column_int(selectEventCount, 0);
	}
	sqlite3_finalize(selectEventCount);
	
	return rowCount;
}

#pragma mark - Lifecycle

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

- (void)dealloc {
	sqlite3_close(_databaseConnection);
	[super dealloc];
}

@end
