//
//  SingleGameScore.m
//  iWVU
//
//  Created by Jared Crawford on 12/18/09.
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

#import "SingleGameScore.h"
#import "NSDate+Helper.h"
#import "NSString+MD5.h"


@implementation SingleGameScore

@synthesize homeTeamName;
@synthesize awayTeamName;
@synthesize homeTeamLogo;
@synthesize awayTeamLogo;
@synthesize homeTeamScore;
@synthesize awayTeamScore;
@synthesize backSideMessage;
@synthesize startTime;
@synthesize winOrLoss;




- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        // Initialization code
    }
    return self;
}



-(id)initWithDictionary:(NSDictionary *)dict homeLogo:(UIImage *)homeLogo awayLogo:(UIImage *)awayLogo{
	[[NSBundle mainBundle] loadNibNamed:@"SingleGameScore" owner:self options:nil];
	self = scoreCell;
    isShowingBackside = NO;
	
	
	//Name
	self.homeTeamName.text = [self stringForKey:@"home" inDict:dict];
	self.awayTeamName.text = [self stringForKey:@"away" inDict:dict];
	
	//Logo
	self.homeTeamLogo.image = homeLogo;
	self.awayTeamLogo.image = awayLogo;
	
	//hasStarted Status
	BOOL hasStarted = YES;
	if (0==[[self stringForKey:@"hasStarted" inDict:dict] intValue]) {
		hasStarted = NO;
	}
	
	//Start Time
	double UNIXTime = [[dict valueForKey:@"startDateTime"] doubleValue];
	NSDate *aStartTime = [NSDate dateWithTimeIntervalSince1970:UNIXTime];
	NSDateFormatter *format = [[[NSDateFormatter alloc] init] autorelease];
	
	
	[format setDateFormat:@"EEE, MMM d'\n'h:mm a"];

	
	self.startTime.text = [format stringFromDate:aStartTime];
	
	
	//Game Clock
	if (hasStarted) {
		self.startTime.text = [self.startTime.text stringByAppendingString:[self stringForKey:@"gameClock" inDict:dict]];
	}
	
	//score
	self.homeTeamScore.text = [self stringForKey:@"homeScore" inDict:dict];
	self.awayTeamScore.text = [self stringForKey:@"awayScore" inDict:dict];
	
	
	//win Loss
	NSLog(@"%@",[self stringForKey:@"hasFinished" inDict:dict]);
	if([[self stringForKey:@"hasFinished" inDict:dict] isEqualToString:@"1"]){
		self.winOrLoss.text = [self stringForKey:@"winLoss" inDict:dict];
	}
	else{
		self.winOrLoss.text = [self stringForKey:@"remainingTime" inDict:dict];
	}
	
	self.selectionStyle = UITableViewCellSelectionStyleNone;
	
	//timeStamp
	self.backSideMessage.text = [NSString stringWithFormat:@"Last Updated:\n%@",[NSDate stringForDisplayFromDate:[NSDate date]]];
	
	return self;
}


-(NSString *)stringForKey:(NSString *)key inDict:(NSDictionary *)dict{
	NSString *value = [dict objectForKey:key];
	if ((value != nil)&&(![value isEqual:[NSNull null]])) {
		if([value isKindOfClass:[NSString class]]){
			value = [value  stringByDecodingXMLEntities];
		}
		return value;
	}
	return @"";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


-(IBAction)informationButtonPressed:(UIButton *)sender{
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDelegate:self];
	
	if (isShowingBackside) {
		[UIView setAnimationWillStartSelector:@selector(showFrontSideForID:andContext:)];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:[sender superview] cache:NO];
	}
	else {
		[UIView setAnimationWillStartSelector:@selector(showBackSideForID:andContext:)];
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:[sender superview] cache:NO];
	}

	[UIView setAnimationDuration:1];
	
	[UIView commitAnimations];
}


-(void)showFrontSideForID:(id)animationID andContext:(id)animationContext{
	self.homeTeamLogo.hidden = NO;
	self.awayTeamLogo.hidden = NO;
	self.homeTeamName.hidden = NO;
	self.awayTeamName.hidden = NO;
	self.homeTeamScore.hidden = NO;
	self.awayTeamScore.hidden = NO;
	self.startTime.hidden = NO;
	
	self.backSideMessage.hidden = YES;
	backSideDisclaimer.hidden = YES;
	isShowingBackside = NO;
}

-(void)showBackSideForID:(id)animationID andContext:(id)animationContext{
	self.homeTeamLogo.hidden = YES;
	self.awayTeamLogo.hidden = YES;
	self.homeTeamName.hidden = YES;
	self.awayTeamName.hidden = YES;
	self.homeTeamScore.hidden = YES;
	self.awayTeamScore.hidden = YES;
	self.startTime.hidden = YES;
	
	self.backSideMessage.hidden = NO;
	backSideDisclaimer.hidden = NO;
	isShowingBackside = YES;
}


- (void)dealloc {
    [super dealloc];
}


@end
