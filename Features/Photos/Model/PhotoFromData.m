//
//  PhotoFromData.m
//  iWVU
//
//  Created by Jared Crawford on 9/2/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "PhotoFromData.h"
#import "NSString+MD5.h"


#define LARGE_SIZE @"orig"
#define MEDIUM_SIZE @"src"
#define SMALL_SIZE @"src"
#define THUMBNAIL_SIZE @"tn"
#define CAPTION @"caption"

#define MDASH @"–"

@implementation PhotoFromData

@synthesize size, index, photoSource;

-(id)initWithDictionary:(NSDictionary *)newPhotoData{
	if (self = [super init]) {
		photoData = [newPhotoData retain];
	}
	return self;
}


- (NSString*)URLForVersion:(TTPhotoVersion)version {
	if (version == TTPhotoVersionLarge) {
		return [photoData objectForKey:LARGE_SIZE];
	} else if (version == TTPhotoVersionMedium) {
		return [photoData objectForKey:MEDIUM_SIZE];
	} else if (version == TTPhotoVersionSmall) {
		return [photoData objectForKey:SMALL_SIZE];
	} else if (version == TTPhotoVersionThumbnail) {
		return [photoData objectForKey:THUMBNAIL_SIZE];
	} else {
		return nil;
	}
}

-(void)setCaption:(NSString *)text{
	//not implemented
}

-(NSString *)caption{
	//NSLog(@"\n\n%@\n\n", [[photoData objectForKey:CAPTION] stringByDecodingXMLEntities]);
	if ([photoData objectForKey:CAPTION]) {
		
		NSString *fullHTML = [[photoData objectForKey:CAPTION] stringByDecodingXMLEntities];
		
		//Trim between the <p> and </p>
		NSRange pRange = [fullHTML rangeOfString:@"<p>"];
		if (pRange.location != NSNotFound) {
			fullHTML = [fullHTML substringFromIndex:(pRange.location + pRange.length)];
		}
		
		NSRange endPRange = [fullHTML rangeOfString:@"</p"];
		if (endPRange.location != NSNotFound) {
			fullHTML = [fullHTML substringToIndex:endPRange.location];
		}
		
		
		
		//take out all of the other HTML tags
		while ([fullHTML rangeOfString:@"<"].location != NSNotFound) {
			NSRange startOfTagToRemove = [fullHTML rangeOfString:@"<"];
			NSString *newHTML = [fullHTML substringToIndex:startOfTagToRemove.location];
			NSRange endOfTagToRemove = [fullHTML rangeOfString:@">"];
			if (endOfTagToRemove.location != NSNotFound) {
				NSString *endPartToAppend = [fullHTML substringFromIndex:(endOfTagToRemove.location + endOfTagToRemove.length)];
				newHTML = [newHTML stringByAppendingString:endPartToAppend];
			}
			fullHTML = newHTML;
		}
		
		fullHTML = [fullHTML urlDecodedValue];
		fullHTML = [fullHTML stringByReplacingOccurrencesOfString:@"&mdash;" withString:MDASH];
		
		return fullHTML;
	}
	return nil;
}


-(NSComparisonResult)compare:(PhotoFromData *)anotherPhoto{
	NSString *thisPhotosCaption = [self caption];
	NSString *anotherPhotosCaption = [anotherPhoto caption];
	NSRange rangeOfThisPhotosDate = [thisPhotosCaption rangeOfString:MDASH];
	NSRange rangeOfAnotherPhotosDate = [thisPhotosCaption rangeOfString:MDASH];
	if ((rangeOfThisPhotosDate.location == NSNotFound)&&(rangeOfAnotherPhotosDate.location == NSNotFound)) {
		return NSOrderedSame;
	}
	else if (rangeOfThisPhotosDate.location == NSNotFound) {
		return NSOrderedAscending;
	}
	else if(rangeOfAnotherPhotosDate.location == NSNotFound){
		return NSOrderedDescending;
	}
	NSString *thisPhotoDateString = [thisPhotosCaption substringToIndex:rangeOfThisPhotosDate.location];
	NSString *anotherPhotoDateString = [anotherPhotosCaption substringToIndex:rangeOfAnotherPhotosDate.location];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	NSDate *thisPhotoDate = [formatter dateFromString:thisPhotoDateString];
	NSDate *anotherPhotoDate = [formatter dateFromString:anotherPhotoDateString];
	if ((!thisPhotoDate)&&(!anotherPhotoDate)) {
		NSLog(@"%@", @"Neither photo had parsable date");
		return NSOrderedSame;
	}
	else if (!thisPhotoDate) {
		return NSOrderedAscending;
	}
	else if(!anotherPhotoDate){
		return NSOrderedDescending;
	}
	return [thisPhotoDate compare:anotherPhotoDate];
}



@end
