//
//  WVUDirectorySearch.m
//  iWVU
//
//  Created by Jared Crawford on 2/25/10.
//  Copyright Jared Crawford 2010. All rights reserved.
//

/*
 Copyright (c) 2009 Jared Crawford
 
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
 
 The trademarks owned or managed by the West Virginia 
 University Board of Governors (WVU) are used under agreement 
 between the above copyright holder(s) and WVU. The West 
 Virginia University Board of Governors maintains ownership of all 
 trademarks. Reuse of this software or software source code, in any 
 form, must remove all references to any trademark owned or 
 managed by West Virginia University.
 */ 

#import "WVUDirectorySearch.h"
#import "NSString+MD5.h"
#import "Reachability.h"


@implementation WVUDirectorySearch

@synthesize searchResults;
@synthesize studentResults;
@synthesize facultyResults;
@synthesize delegate;




- (void)performLDAPSearch:(NSString *)LDAPSyntaxSearchQuery{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSString *directoryURL = @"http://m.wvu.edu/people/json?q=%@&key=%@";
	NSString *escapedQuery = [LDAPSyntaxSearchQuery stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	escapedQuery = [NSString urlEncodeValue:escapedQuery];
	NSString *key = [self getPrivateKey];
	key = [LDAPSyntaxSearchQuery stringByAppendingString:key];
	directoryURL = [NSString stringWithFormat:directoryURL, escapedQuery, [NSString md5:key]];
	
	
	NSMutableArray *LocalSearchResults = [NSMutableArray array];
	NSMutableArray *LocalStudentResults = [NSMutableArray array];
	NSMutableArray *LocalFacStaffResults = [NSMutableArray array];


	
	BOOL isFacStaff = NO;
	
	//TESTING CODE
	
	
	//NSString *results = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json_directory" ofType:@"txt"]];
	//NSData *jsonData = [results dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	
	NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:directoryURL]];
	NSDictionary *LDAPSearchResultsDict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:nil];
	NSDictionary *resultsSet = [LDAPSearchResultsDict objectForKey:@"resultSet"];
	NSArray *LDAPSearchResults = [resultsSet objectForKey:@"result"];
	
	
	if(LDAPSearchResults == nil){
		
		if (![[NSThread currentThread] isCancelled]) {
			[((id)delegate) performSelectorOnMainThread:@selector(directorySearchErrorOccured) withObject:nil waitUntilDone:NO];
		}
		
		
	}
	else if([LDAPSearchResults count] == 0){
		UIAlertView *err = [[UIAlertView alloc] initWithTitle:nil message:@"No results were found matching your search criteria." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		if (![[NSThread currentThread] isCancelled]) {
			[err performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
		}
		[err release];
	}
	else{
		[LDAPSearchResults retain];
		for(NSDictionary *dict in LDAPSearchResults){
			
			
			
			ABRecordRef person = ABPersonCreate();
			
			NSString *firstName = [(NSArray *)[dict objectForKey:@"givenname"] objectAtIndex:0];
			ABRecordSetValue(person, kABPersonFirstNameProperty, firstName, NULL);
			
			NSString *lastName = [(NSArray *)[dict objectForKey:@"surname"] objectAtIndex:0];
			ABRecordSetValue(person, kABPersonLastNameProperty, lastName, NULL);
			
			NSString *personType = [(NSArray *)[dict objectForKey:@"affiliation"] objectAtIndex:0];
			if([@"facstaff" isEqualToString:personType]){
				isFacStaff = YES;
				personType = @"Faculty or Staff";
			}
			else if([@"student" isEqualToString:personType]){
				personType = @"Student";
				isFacStaff = NO;
			}
			ABRecordSetValue(person, kABPersonNoteProperty, personType, NULL);
			
			//ABRecordSetValue(person, kABPersonJobTitleProperty, personType, NULL);
			
			if([dict objectForKey:@"dept"]){
				NSString *department = [(NSArray *)[dict objectForKey:@"dept"] objectAtIndex:0];
				ABRecordSetValue(person, kABPersonOrganizationProperty, department, NULL);
			}
			
			if([dict objectForKey:@"title"]){
				NSString *JobTitle = [(NSArray *)[dict objectForKey:@"title"] objectAtIndex:0];
				ABRecordSetValue(person, kABPersonJobTitleProperty, JobTitle, NULL);
			}
			
			
			
			
			
			NSString *phoneNumber = [(NSArray *)[dict objectForKey:@"telephone"] objectAtIndex:0];
			phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@","];//for extensions
			if((phoneNumber!=nil) && ![@"000-000-0000" isEqualToString:phoneNumber]){
				ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
				ABMultiValueAddValueAndLabel(multiPhone, phoneNumber, kABPersonPhoneMainLabel, NULL);     
				ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone,NULL);
				CFRelease(multiPhone);
			}
			
			NSString *email = [(NSArray *)[dict objectForKey:@"email"] objectAtIndex:0];
			if(email){
				ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
				ABMultiValueAddValueAndLabel(multiEmail, email, kABWorkLabel, NULL);     
				ABRecordSetValue(person, kABPersonEmailProperty, multiEmail,NULL);
				CFRelease(multiEmail);
			}
			
			
			//Address
			NSArray *addressArray = [dict objectForKey:@"address"];
			if([addressArray count] == 0){
				//do nothing
			}
			else if([addressArray count] == 2){
				ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
				NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
				NSString *line1 = [addressArray objectAtIndex:0];
				[addressDictionary setObject:line1 forKey:(NSString *)kABPersonAddressStreetKey];
				NSString *line2 = [addressArray objectAtIndex:1];
				NSArray *CityStateAndZip = [line2 componentsSeparatedByString:@", "];
				NSString *City = [CityStateAndZip objectAtIndex:0];
				NSString *State = [CityStateAndZip objectAtIndex:1];
				NSString *Zip = [CityStateAndZip objectAtIndex:2];
				[addressDictionary setObject:City forKey:(NSString *)kABPersonAddressCityKey];
				[addressDictionary setObject:State forKey:(NSString *)kABPersonAddressStateKey];
				[addressDictionary setObject:Zip forKey:(NSString *)kABPersonAddressZIPKey];
				ABMultiValueAddValueAndLabel(multiAddress, addressDictionary, kABWorkLabel, NULL);
                [addressDictionary release];
				ABRecordSetValue(person, kABPersonAddressProperty, multiAddress,NULL);
				CFRelease(multiAddress);
			}
			else if([addressArray count] == 3){
				ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
				NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
				NSString *line1 = [addressArray objectAtIndex:0];
				NSString *line2 = [addressArray objectAtIndex:1];
				NSString *line1And2 = [NSString stringWithFormat:@"%@\n%@", line1, line2];
				[addressDictionary setObject:line1And2 forKey:(NSString *)kABPersonAddressStreetKey];
				NSString *line3 = [addressArray objectAtIndex:2];
				NSArray *CityStateAndZip = [line3 componentsSeparatedByString:@", "];
				NSString *City = [CityStateAndZip objectAtIndex:0];
			
				NSString *State = [CityStateAndZip objectAtIndex:1];
				NSString *Zip = [CityStateAndZip objectAtIndex:2];
				[addressDictionary setObject:City forKey:(NSString *)kABPersonAddressCityKey];
				[addressDictionary setObject:State forKey:(NSString *)kABPersonAddressStateKey];
				[addressDictionary setObject:Zip forKey:(NSString *)kABPersonAddressZIPKey];
				ABMultiValueAddValueAndLabel(multiAddress, addressDictionary, kABWorkLabel, NULL);
                [addressDictionary release];
				ABRecordSetValue(person, kABPersonAddressProperty, multiAddress,NULL);
				CFRelease(multiAddress);
			}
			
			
			[LocalSearchResults addObject:(id)person];
			if(isFacStaff){
				[LocalFacStaffResults addObject:(id)person];
			}
			else{
				[LocalStudentResults addObject:(id)person];
			}
			[(id)person autorelease];
		}
        [LDAPSearchResults release];
		if (![[NSThread currentThread] isCancelled]) {
			self.searchResults = [NSArray arrayWithArray:LocalSearchResults];
			self.facultyResults = [NSArray arrayWithArray:LocalFacStaffResults];
			self.studentResults = [NSArray arrayWithArray:LocalStudentResults];
			[((id)delegate) performSelectorOnMainThread:@selector(newDirectoryDataAvailable:) withObject:self waitUntilDone:NO];
			[aThread release];
			aThread = nil;
		}
		
	}
	
	[pool release];
}

-(NSString *)getPrivateKey{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"PrivateKey" ofType:@"plist"]];
	return [dict objectForKey:@"Private Key"];
}

-(void)searchWithString:(NSString *)searchQuery{
	self.searchResults = [NSArray array];
	self.facultyResults = [NSArray array];
	self.studentResults = [NSArray array];
	
	//get rid of any previous searches
	if (aThread) {
		[aThread cancel];
		[aThread release];
		aThread = nil;
	}
	
	
	//start a new search
	aThread = [[NSThread alloc] initWithTarget:self selector:@selector(performLDAPSearch:) object:searchQuery];
	[aThread start];
}

-(BOOL)directoryIsReachable{
	NSString *path = @"m.wvu.edu";
	[[Reachability sharedReachability] setHostName:path];
	NetworkStatus internetStatus = [[Reachability sharedReachability] remoteHostStatus];
	if(internetStatus == NotReachable){
		return NO;
	}
	return YES;
}


@end
