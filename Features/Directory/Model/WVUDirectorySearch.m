//
//  WVUDirectorySearch.m
//  iWVU
//
//  Created by Jared Crawford on 2/25/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "WVUDirectorySearch.h"
#import "CJSONDeserializer.h"
#import "NSString+MD5.h"


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
	
	NSLog(@"%@",directoryURL);
	NSLog(@"%@", LDAPSyntaxSearchQuery);
	NSLog(@"%@",escapedQuery);
	
	NSError *searchError = nil;
	NSMutableArray *LocalSearchResults = [NSMutableArray array];
	NSMutableArray *LocalStudentResults = [NSMutableArray array];
	NSMutableArray *LocalFacStaffResults = [NSMutableArray array];


	
	BOOL isFacStaff = NO;
	
	//TESTING CODE
	
	NSError *err;
	
	//NSString *results = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"json_directory" ofType:@"txt"]];
	//NSData *jsonData = [results dataUsingEncoding:NSUTF32BigEndianStringEncoding];
	
	NSData *jsonData = [NSData dataWithContentsOfURL:[NSURL URLWithString:directoryURL]];
	NSDictionary *LDAPSearchResultsDict = [[CJSONDeserializer deserializer] deserializeAsDictionary:jsonData error:&err];
	NSDictionary *resultsSet = [LDAPSearchResultsDict objectForKey:@"resultSet"];
	NSArray *LDAPSearchResults = [resultsSet objectForKey:@"result"];
	
	
	if(LDAPSearchResults == nil){
		
		if( (!searchError) || ([searchError code] == -1) ){
			//This is the error code for unreachable network
			//due to the limitation of only being able to use LDAP
			//from WVU subnet, I wrote a custom error message for this one
			NSString *errorMessage = escapedQuery;
			if (![[NSThread currentThread] isCancelled]) {
				[((id)delegate) performSelectorOnMainThread:@selector(directorySearchErrorOccured:) withObject:errorMessage waitUntilDone:NO];
			}
			[err release];
		}
		else{
			//For all other errors, OpenLDAP provides an adequate error message
			//OpenLDAP's error is repackaged to this NSError object in RHLDAPSearch
			NSString *errorMessage=[[searchError userInfo] objectForKey:@"err_msg"];
			UIAlertView *err = [[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
			NSLog(@"LDAP Error: %@", [searchError localizedDescription]);
			if (![[NSThread currentThread] isCancelled]) {
				[err performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:YES];
			}
			[err release];
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


@end
