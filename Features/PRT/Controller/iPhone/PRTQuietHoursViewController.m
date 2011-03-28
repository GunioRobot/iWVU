//
//  PRTQuietHoursViewController.m
//  iWVU
//
//  Created by Jared Crawford on 10/25/10.
//  Copyright 2010 Jared Crawford. All rights reserved.
//

#import "PRTQuietHoursViewController.h"


@implementation PRTQuietHoursViewController



#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // For the sake of the UI, I'm going to return 2 and only use the second one
	return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 1) {
		return 24;
	}
	return 0;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSString *labelText = @"";
	
	switch (indexPath.row) {
		case 0:
			labelText = @"Midnight - 1AM";
			break;
		case 1:
			labelText = @"1AM - 2AM";
			break;
		case 2:
			labelText = @"2AM - 3AM";
			break;
		case 3:
			labelText = @"3AM - 4AM";
			break;
		case 4:
			labelText = @"4AM - 5AM";
			break;
		case 5:
			labelText = @"5AM - 6AM";
			break;
		case 6:
			labelText = @"6AM - 7AM";
			break;
		case 7:
			labelText = @"7AM - 8AM";
			break;
		case 8:
			labelText = @"8AM - 9AM";
			break;
		case 9:
			labelText = @"9AM - 10AM";
			break;
		case 10:
			labelText = @"10AM - 11AM";
			break;
		case 11:
			labelText = @"11AM - Noon";
			break;
		case 12:
			labelText = @"Noon - 1PM";
			break;
		case 13:
			labelText = @"1PM - 2PM";
			break;
		case 14:
			labelText = @"2PM - 3PM";
			break;
		case 15:
			labelText = @"3PM - 4PM";
			break;
		case 16:
			labelText = @"4PM - 5PM";
			break;
		case 17:
			labelText = @"5PM - 6PM";
			break;
		case 18:
			labelText = @"6PM - 7PM";
			break;
		case 19:
			labelText = @"7PM - 8PM";
			break;
		case 20:
			labelText = @"8PM - 9PM";
			break;
		case 21:
			labelText = @"9PM - 10PM";
			break;
		case 22:
			labelText = @"10PM - 11PM";
			break;
		case 23:
			labelText = @"11PM - Midnight";
			break;
		default:
			break;
	}

	cell.textLabel.text = labelText;
	
	NSString *quietHours = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRTQuietHours"];
	if ('1' == [quietHours characterAtIndex:indexPath.row]) {
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}
	else {
		cell.accessoryType = UITableViewCellAccessoryNone;
	}

	
    // Configure the cell...
    
    return cell;
}








/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	NSString *quietHours = [[NSUserDefaults standardUserDefaults] objectForKey:@"PRTQuietHours"];
	NSString *newQuietHours;
	if ('1' == [quietHours characterAtIndex:indexPath.row]) {
		newQuietHours = [NSString stringWithFormat:@"%@0%@",[quietHours substringToIndex:indexPath.row], [quietHours substringFromIndex:indexPath.row + 1]];
	}
	else {
		newQuietHours = [NSString stringWithFormat:@"%@1%@",[quietHours substringToIndex:indexPath.row], [quietHours substringFromIndex:indexPath.row + 1]];
	}
	[[NSUserDefaults standardUserDefaults] setObject:newQuietHours forKey:@"PRTQuietHours"];
	[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	iWVUAppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
	[appDelegate easyAPNSinit];
}



- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    iWVUAppDelegate *AppDelegate = [UIApplication sharedApplication].delegate;
	[AppDelegate configureTableViewCell:cell inTableView:tableView forIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0){
		return @"Select the hours for which you would like to receive push notifications on the status of the PRT.";
	}
	return nil;
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end

