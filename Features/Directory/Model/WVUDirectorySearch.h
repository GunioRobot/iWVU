//
//  WVUDirectorySearch.h
//  iWVU
//
//  Created by Jared Crawford on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@protocol WVUDirectorySearchDelegate;


@interface WVUDirectorySearch : NSObject {
	NSArray *searchResults;
	NSArray *facultyResults;
	NSArray *studentResults;
	id<WVUDirectorySearchDelegate> delegate;
	
	NSThread *aThread;
}

@property(nonatomic, retain) NSArray *searchResults;
@property(nonatomic, retain) NSArray *facultyResults;
@property(nonatomic, retain) NSArray *studentResults;
@property(nonatomic, assign) id<WVUDirectorySearchDelegate> delegate;

-(void)searchWithString:(NSString *)searchQuery;

@end



@protocol WVUDirectorySearchDelegate

-(void)newDirectoryDataAvailable:(WVUDirectorySearch *)aSearchEngine;
-(void)directorySearchErrorOccured:(NSString *)errorMessage;
-(NSString *)getPrivateKey;

@end

