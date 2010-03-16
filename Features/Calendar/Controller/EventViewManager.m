//
//  EventViewManager.m
//  iWVU
//
//  Created by Jared Crawford on 3/5/10.
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

#import "EventViewManager.h"
#import "NSString+MD5.h"
#import "NSDate+Helper.h"



@implementation EventViewManager

+(UIViewController *)loadEventViewWithDictionary:(NSDictionary *)dict andDelegate:(id<ABPersonViewControllerDelegate>)aDelegate{
	
	ABRecordRef person = ABPersonCreate();
	
	NSString *eventName = [[dict objectForKey:@"title"] stringByDecodingXMLEntities];
	ABRecordSetValue(person, kABPersonFirstNameProperty, eventName, NULL);
	
	
	
	
	NSDate *startTime = [NSDate dateWithTimeIntervalSince1970:[[dict valueForKey:@"startTime"] floatValue]];
	NSString *startTimeStr = [[NSDate stringFromDate:startTime withFormat:@"h:mm a"] uppercaseString];
	ABRecordSetValue(person, kABPersonJobTitleProperty, startTimeStr, NULL);
	
	
	NSString *location = [[dict valueForKey:@"location"] stringByDecodingXMLEntities];
	if(location&&![location isEqualToString:@""]){
		ABRecordSetValue(person, kABPersonOrganizationProperty, location, NULL);
	}
	
	
	NSString *contact= [[dict objectForKey:@"contactName"]  stringByDecodingXMLEntities];
	if(contact&&![contact isEqualToString:@""]){
		ABMutableMultiValueRef contacts = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(contacts, contact, kABPersonManagerLabel, NULL); 
		ABRecordSetValue(person, kABPersonRelatedNamesProperty, contacts, NULL);
	}
	
	NSString *phoneNumber = [[dict objectForKey:@"contactPhone"] stringByDecodingXMLEntities];
	if(phoneNumber&&![phoneNumber isEqualToString:@""]){
		ABMutableMultiValueRef multiPhone = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(multiPhone, phoneNumber, kABPersonPhoneMainLabel, NULL);     
		ABRecordSetValue(person, kABPersonPhoneProperty, multiPhone,NULL);
		CFRelease(multiPhone);
	}
	
	NSString *email = [[dict objectForKey:@"contactEmail"] stringByDecodingXMLEntities];
	if(email&&![email isEqualToString:@""]){
		ABMutableMultiValueRef multiEmail = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(multiEmail, email, kABWorkLabel, NULL);     
		ABRecordSetValue(person, kABPersonEmailProperty, multiEmail,NULL);
		CFRelease(multiEmail);
	}
	
	NSString *website = [[dict objectForKey:@"eventLink"] stringByDecodingXMLEntities];
	if(website&&![website isEqualToString:@""]){
		ABMutableMultiValueRef multiweb = ABMultiValueCreateMutable(kABMultiStringPropertyType);
		ABMultiValueAddValueAndLabel(multiweb, website, kABWorkLabel, NULL);     
		ABRecordSetValue(person, kABPersonURLProperty, multiweb,NULL);
		CFRelease(multiweb);
	}
	
	
	
	
	NSString *description = [[dict objectForKey:@"description"] stringByDecodingXMLEntities];
	if(description&&![description isEqualToString:@""]){
		ABRecordSetValue(person, kABPersonNoteProperty, description, NULL);
	}
	
	/*
	 NSString *location = [dict objectForKey:@"location"];
	 if(location){
	 ABMutableMultiValueRef multiAddress = ABMultiValueCreateMutable(kABMultiDictionaryPropertyType);
	 NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] init];
	 [addressDictionary setObject:location forKey:(NSString *)kABPersonAddressStreetKey];
	 ABMultiValueAddValueAndLabel(multiAddress, addressDictionary, kABWorkLabel, NULL);
	 ABRecordSetValue(person, kABPersonAddressProperty, multiAddress,NULL);
	 CFRelease(multiAddress);
	 }
	 */
	
	
	
	UIImage *img = [UIImage imageNamed:@"EventLogo.png"];
	NSData *imgData = UIImagePNGRepresentation(img);
	NSError *err;
	ABPersonSetImageData(person, (CFDataRef)imgData, (CFErrorRef *)&err);
	
	
	
	ABPersonViewController *viewController = [[ABPersonViewController alloc] init];
	viewController.displayedPerson = person;
	viewController.allowsEditing = NO;
	viewController.navigationItem.title = @"Event Information";
	viewController.personViewDelegate = aDelegate;
	return viewController;
}

@end
