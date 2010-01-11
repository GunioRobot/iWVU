//
//  AthleticKalTableCell.m
//  iWVU
//
//  Created by Jared Crawford on 12/23/09.
//  Copyright Jared Crawford 2009. All rights reserved.
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

#import "AthleticKalTableCell.h"


@implementation AthleticKalTableCell

@synthesize opponentName;
@synthesize startTime;
@synthesize opponentLogo;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}


-(id)initWithDict:(NSDictionary *)gameDict andSportOrNil:(NSString *)aSport{
	[[NSBundle mainBundle] loadNibNamed:@"AthleticKalTableCell" owner:self options:nil];
	self = theCell;
	
	self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[self retain];
	
	
	NSString *homeTeamName = [gameDict objectForKey:@"home"];
	if ([@"WVU" isEqualToString:homeTeamName]) {
		NSString *awayTeamName = [gameDict objectForKey:@"away"];
		self.opponentName.text = awayTeamName;
	}
	else {
		self.opponentName.text = [NSString stringWithFormat:@"@ %@", homeTeamName];
	}
	//self.opponentName.text = [self.opponentName.text stringByAppendingString:@"\n"];
	
	self.opponentLogo.image = [gameDict objectForKey:@"opponentLogoUIImage"];
	
	
	float startTimeInSec = [[gameDict objectForKey:@"startDateTime"] floatValue];
	NSDate *aDate = [NSDate dateWithTimeIntervalSince1970:startTimeInSec];
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	[format setDateFormat:@"h:mm a"];
	self.startTime.text = [format stringFromDate:aDate];
	
	if (aSport) {
		self.opponentName.numberOfLines = 2;
		self.opponentName.text = [self.opponentName.text stringByAppendingFormat:@"\n%@",aSport];
	}
	else {
		self.opponentName.numberOfLines = 1;
	}

	
	return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc {
    [super dealloc];
}


@end
