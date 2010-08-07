//
//  SQLite.m
//  Senster
//
//  Created by UCLANRL on 2/2/09.
//  Modified by Jared Crawford
//  Copyright 2009 UCLA/Engineering. All rights reserved.
//

/*
 Copyright (c) 2009 UCLANRL
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */ 

#import "SQLite.h"


@implementation SQLite

+ (NSString*) filename {
	return @"CampusData.sqlite3";
}
+ (NSString*) fullFilePath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES); 
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingFormat:@"%@%@",@"/",[SQLite filename]];
}

+ (void) initialize {
	BOOL foundFileAtPath;
    BOOL needToCopyTheResourceVersion = YES;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	foundFileAtPath = [fileManager fileExistsAtPath:[SQLite fullFilePath]];
	if(foundFileAtPath){
        //implement your logic to determine if it needs to be copied
        needToCopyTheResourceVersion = NO;
    }
    if(needToCopyTheResourceVersion){
        NSString *databasePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[SQLite filename]];
        [fileManager copyItemAtPath:databasePathFromApp toPath:[SQLite fullFilePath] error:nil];
    }
}

+ (void) remove {
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if(![fileManager fileExistsAtPath:[SQLite fullFilePath]]) return;
	[fileManager removeItemAtPath:[SQLite fullFilePath] error:nil];
}

+ (SQLiteResult*) query:(NSString*)content {
	
	// Takes a query NSString and returns a SQLiteResult result object.
	
	sqlite3 *database;
	SQLiteResult *result = [SQLiteResult createSQLiteResult];
	if(sqlite3_open([[SQLite fullFilePath] UTF8String], &database) == SQLITE_OK) {
		const char *sqlStatement = [content cStringUsingEncoding:NSUTF8StringEncoding];
		sqlite3_stmt *compiledStatement;
		if(sqlite3_prepare_v2(database, sqlStatement, -1, &compiledStatement, NULL) == SQLITE_OK) {
			int colCount = sqlite3_column_count(compiledStatement);
			for(int i=0;i<colCount;i++) {
				if(i == 0) {
					//result.tableName = [NSString stringWithCString:sqlite3_column_table_name(compiledStatement, 0) encoding:NSUTF8StringEncoding];
					//result.databaseName = [NSString stringWithCString:sqlite3_column_database_name(compiledStatement, 0) encoding:NSUTF8StringEncoding];
				}
				[result.columnNames addObject:[NSString stringWithCString:sqlite3_column_name(compiledStatement, i) encoding:NSUTF8StringEncoding]];
				[result.columnTypes addObject:[NSString stringWithCString:sqlite3_column_decltype(compiledStatement, i) encoding:NSUTF8StringEncoding]];
			}
			while(sqlite3_step(compiledStatement) == SQLITE_ROW) {
				// Read the data from the result row
				NSMutableDictionary *row = [NSMutableDictionary dictionaryWithCapacity:colCount];
				for(int i=0;i<colCount;i++) {
					if(sqlite3_column_text(compiledStatement, i) != NULL){
						[row setValue:[NSString stringWithUTF8String:(char *)sqlite3_column_text(compiledStatement, i)] forKey:[result.columnNames objectAtIndex:i]];
					}
				}
				[result.rows addObject:row];
			}
			result.errorCode = @"OK";
		}
		else result.errorCode = @"SQL Statement failed to execute.";
		// Release the compiled statement from memory
		sqlite3_finalize(compiledStatement);
		
	}
	else result.errorCode = @"SQLite Database failed to open.";
	sqlite3_close(database);
	return result;
}

@end
