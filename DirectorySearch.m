//
//  DirectorySearch.m
//  iWVU
//
//  Created by Jared Crawford on 7/7/09.
//  Copyright 2009 Jared Crawford. All rights reserved.
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

#import "DirectorySearch.h"

#import "iWVUAppDelegate.h"

#import "RHLDAPSearch.h"
#import "Reachability.h"

// You must have the LDAPInclude directory in your header search path



/*
 
 To-Do:
 
 *Memory Management
 *3 Line Addresses
 *Job Titles
 *SSH Tunneling
 *Delegate Protocol Implementation
 *Search Criteria
 *More than 50 Results Returned Error
 *Error for non-WVU network
 *Better way than notes to record ptype
 
 
 */






@implementation DirectorySearch

@synthesize searchResults;
@synthesize facstaffResults;
@synthesize studentsResults;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	self.searchResults = [NSArray array];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}




//Search Bar



- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar{
	return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
	[searchBar resignFirstResponder];
	
	// do the ldap search
	NSError* searchError;
	NSMutableArray *LocalSearchResults = [NSMutableArray array];
	NSMutableArray *LocalStudentResults = [NSMutableArray array];
	NSMutableArray *LocalFacStaffResults = [NSMutableArray array];
	BOOL isFacStaff = NO;
	NSString *LDAPurl = @"ldap://ldap.wvu.edu:389";
	
	/************************/
	//For testing from off-campus IP, use an SSH tunnel
	//ssh -N -L 3389:ldap.wvu.edu:389 <CSEE USERNAME>@shell.csee.wvu.edu
	LDAPurl = @"ldap://localhost:3389";
	/*************************/
	
	RHLDAPSearch *mySearch = [[RHLDAPSearch alloc] initWithURL:LDAPurl]; 
	NSString *searchQuery = [self convertTextSearchToLDAPSyntax:searchBar.text]; //for small test use @"(mail=*cukic*)"
	NSArray *LDAPSearchResults = [mySearch searchWithQuery:searchQuery withinBase:@"ou=people,dc=wvu,dc=edu" usingScope:RH_LDAP_SCOPE_SUBTREE error:&searchError];
	if(!LDAPSearchResults){
		NSString *errorMessage;
		if([searchError code] == -1){
			//This is the error code for unreachable network
			//due to the limitation of only being able to use LDAP
			//from WVU subnet, I wrote a custom error message for this one
			errorMessage = @"You must be connected to a WVU WiFi network to search the directory. Ensure you are properly connected and try your search again.";
		}
		else{
			//For all other errors, OpenLDAP provides an adequate error message
			//OpenLDAP's error is repackaged to this NSError object in RHLDAPSearch
			errorMessage=[[searchError userInfo] objectForKey:@"err_msg"]; 
		}
		UIAlertView *err = [[UIAlertView alloc] initWithTitle:nil message:errorMessage delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		NSLog(@"LDAP Error: %@", [searchError localizedDescription]);
		[err show];
		[err release];
	}
	else if([LDAPSearchResults count] == 0){
		UIAlertView *err = [[UIAlertView alloc] initWithTitle:nil message:@"No results were found matching your search criteria." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
		[err show];
		[err release];
	}
	else{
		[LDAPSearchResults retain];
		for(NSDictionary *dict in LDAPSearchResults){
			ABRecordRef person = ABPersonCreate();
			
			NSString *firstName = [(NSArray *)[dict objectForKey:@"givenName"] objectAtIndex:0];
			ABRecordSetValue(person, kABPersonFirstNameProperty, firstName, NULL);
			
			NSString *lastName = [(NSArray *)[dict objectForKey:@"sn"] objectAtIndex:0];
			ABRecordSetValue(person, kABPersonLastNameProperty, lastName, NULL);
			
			NSString *personType = [(NSArray *)[dict objectForKey:@"wvuptype"] objectAtIndex:0];
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
			
			if([dict objectForKey:@"department"]){
				NSString *department = [(NSArray *)[dict objectForKey:@"department"] objectAtIndex:0];
				ABRecordSetValue(person, kABPersonOrganizationProperty, department, NULL);
			}
			
			if([dict objectForKey:@"type"]){
				NSString *JobTitle = [(NSArray *)[dict objectForKey:@"type"] objectAtIndex:0];
				ABRecordSetValue(person, kABPersonJobTitleProperty, JobTitle, NULL);
			}
			
			
			
			
			
			NSString *phoneNumber = [(NSArray *)[dict objectForKey:@"telephoneNumber"] objectAtIndex:0];
			phoneNumber = [phoneNumber stringByReplacingOccurrencesOfString:@" " withString:@","];//for extensions
			if(NO == [@"000-000-0000" isEqualToString:phoneNumber]){
				ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
				ABMultiValueAddValueAndLabel(multiPhone, phoneNumber, kABPersonPhoneMainLabel, NULL);     
				ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone,NULL);
				CFRelease(multiPhone);
			}
			
			NSString *email = [(NSArray *)[dict objectForKey:@"mail"] objectAtIndex:0];
			if(email){
				ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
				ABMultiValueAddValueAndLabel(multiEmail, email, kABWorkLabel, NULL);     
				ABRecordSetValue(person, kABPersonEmailProperty, multiEmail,NULL);
				CFRelease(multiEmail);
			}
			
			
			//Address
			NSArray *addressArray = [dict objectForKey:@"postalAddress"];
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
			
			
			
			/*
			 ABMutableMultiValueRef urls = ABMultiValueCreateMutable(kABMultiStringPropertyType);
			 ABMultiValueAddValueAndLabel(urls, [webPerson urlString], CFSTR("soylent green"), NULL);
			 ABRecordSetValue(person, kABPersonURLProperty, urls, NULL);
			 CFRelease(urls);
			 
			 */
			[LocalSearchResults addObject:(id)person];
			if(isFacStaff){
				[LocalFacStaffResults addObject:(id)person];
			}
			else{
				[LocalStudentResults addObject:(id)person];
			}
			[(id)person autorelease];
		}
		self.searchResults = (NSArray *)LocalSearchResults;
		self.facstaffResults = (NSArray *)LocalFacStaffResults;
		self.studentsResults = (NSArray *)LocalStudentResults;
		[theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
	}
	
}


- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope{
	[theTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)unknownPersonViewController:(ABUnknownPersonViewController *)unknownPersonView didResolveToPerson:(ABRecordRef)person{
	//don't think I need to do anything here
}


//Table View


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
	
	NSArray *currentArray;
	if(theSearchBar.selectedScopeButtonIndex == 0){
		currentArray = searchResults;
	}
	else if(theSearchBar.selectedScopeButtonIndex == 1){
		currentArray = facstaffResults;
	}
	else{
		currentArray = studentsResults;
	}
	ABRecordRef person = [currentArray objectAtIndex:indexPath.row];
	
	NSString *personType = ABRecordCopyValue(person, kABPersonNoteProperty);
	
	UITableViewCell *cell;
	if([@"Faculty or Staff" isEqualToString:personType]){
		cell = [tableView dequeueReusableCellWithIdentifier:@"FacStaffCell"];
		if(cell==nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FacStaffCell"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			NSString *IconPath = [[NSBundle mainBundle] bundlePath];
			cell.imageView.image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"BusinessPerson.png"]];
		}
		
	}
	else{
		cell = [tableView dequeueReusableCellWithIdentifier:@"StudentCell"];
		if(cell==nil){
			cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StudentCell"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			NSString *IconPath = [[NSBundle mainBundle] bundlePath];
			cell.imageView.image = [UIImage imageWithContentsOfFile:[IconPath stringByAppendingPathComponent:@"StudentPerson.png"]];
		}
	}
	
	
	
	
	
	NSString *firstName = ABRecordCopyValue(person, kABPersonFirstNameProperty);
	NSString *LastName = ABRecordCopyValue(person, kABPersonLastNameProperty);
	
	cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", firstName, LastName];
	
	
	return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
	if(theSearchBar.selectedScopeButtonIndex == 0){
		return [searchResults count];
	}
	else if(theSearchBar.selectedScopeButtonIndex == 1){
		return [facstaffResults count];
	}
	else{
		return [studentsResults count];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	
	iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	
	ABUnknownPersonViewController *personViewController = [[ABUnknownPersonViewController alloc] init];
	
	NSArray *currentArray;
	if(theSearchBar.selectedScopeButtonIndex == 0){
		currentArray = searchResults;
	}
	else if(theSearchBar.selectedScopeButtonIndex == 1){
		currentArray = facstaffResults;
	}
	else{
		currentArray = studentsResults;
	}
	ABRecordRef person = [currentArray objectAtIndex:indexPath.row];
	personViewController.displayedPerson = person;
	personViewController.unknownPersonViewDelegate = self;

	personViewController.allowsActions = YES;
	personViewController.allowsAddingToAddressBook = YES;
	personViewController.navigationItem.title = @"Search Results";
	[AppDelegate.navigationController pushViewController:personViewController animated:YES];
}




-(NSString *)convertTextSearchToLDAPSyntax:(NSString *)search{
	NSArray *parts = [search componentsSeparatedByString:@" "];
	NSString *searchQuery = @"";
	if(1 == [parts count]){
		//search last name ~=
		searchQuery = [NSString stringWithFormat:@"(sn~=%@)", [parts objectAtIndex:0]];
	}
	else if(2 <= [parts count]){
		//search  cn~=last, first
		searchQuery = [NSString stringWithFormat:@"(&(sn~=%@)(givenName=%@))",[parts objectAtIndex:1], [parts objectAtIndex:0]];
	}
	else{
		searchQuery = [NSString stringWithFormat:@"(cn~=%@)", search];
	}
	return searchQuery;
}









@end
