//
// Copyright (C) 2012 Realmac Software Ltd
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject
// to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
// ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
// CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

#import "RMMasterViewController.h"

#import "RMLockableItem.h"
#import "RMErrorRecoveryAttempter.h"
#import "UIResponder+RMErrorRecovery.h"
#import "RMErrorRecoveryAttempterSampleProject-Constants.h"

@interface RMMasterViewController ()

@property (strong, nonatomic) NSMutableArray *items;

- (IBAction)addUnlockedItem:(id)sender;
- (IBAction)addLockedItem:(id)sender;

@end

@implementation RMMasterViewController

- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self _addItemLocked:NO];
	[self _addItemLocked:YES];
}

#pragma mark - IBActions

- (IBAction)addUnlockedItem:(id)sender
{
	[self _addItemLocked:NO];
}

- (IBAction)addLockedItem:(id)sender
{
	[self _addItemLocked:YES];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [[self items] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	RMLockableItem *lockableItem = [self items][[indexPath row]];
	[[cell textLabel] setText:[lockableItem title]];
	if ([lockableItem isLocked]) {
		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"padlock"]];
		[cell setAccessoryView:imageView];
	}
	else {
		[cell setAccessoryView:nil];
	}
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
	return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		RMLockableItem *item = [self items][[indexPath row]];
		[self _tryDeleteItem:item];
		return;
	}
}

#pragma mark - Add/Delete Items

- (void)_addItemLocked:(BOOL)locked
{
	if ([self items] == nil) {
		[self setItems:[NSMutableArray array]];
	}
	
	RMLockableItem *lockableItem = [[RMLockableItem alloc] initWithTitle:[[NSDate date] description] locked:locked];
	
	[[self items] insertObject:lockableItem atIndex:0];
	[[self tableView] insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)_tryDeleteItem:(RMLockableItem *)item
{
	NSError *deleteError = nil;
	BOOL delete = [self _deleteItem:item error:&deleteError];
	if (!delete) {
		__weak RMMasterViewController *weakSelf = self;
		[self presentError:deleteError completionHandler:^ (BOOL recovered) {
			if (!recovered) {
				// The user didn't choose a recovery path, abort the operation.
				return;
			}
			
			__strong RMMasterViewController *strongSelf = weakSelf;
			if (strongSelf != nil) {
				// The user chose a recovery path, resend the original message.
				[strongSelf _tryDeleteItem:item];
			}
		}];
		return;
	}
	
	// Successfully deleted the item.
	return;
}

- (BOOL)_deleteItem:(RMLockableItem *)item error:(NSError **)errorRef
{
	if ([item isLocked]) {
		if (errorRef != NULL) {
			RMErrorRecoveryAttempter *errorRecoveryAttempter = [[RMErrorRecoveryAttempter alloc] init];
			[errorRecoveryAttempter addRecoveryOptionWithLocalizedTitle:NSLocalizedString(@"Don\u2019t Unlock", @"RMMasterViewController delete locked item error don't unlock recovery option") recoveryBlock:^ BOOL (void) {
				// Do not attempt to recover from the error. Return NO to inform the caller that they should not resend the message that failed.
				return NO;
			}];
			[errorRecoveryAttempter addRecoveryOptionWithLocalizedTitle:NSLocalizedString(@"Unlock & Delete", @"RMMasterViewController delete locked item error unlock & delete recovery option") recoveryBlock:^ BOOL (void) {
				// Do the required work to recover from the error; unlock the item.
				[item setLocked:NO];
				// Return YES to inform the caller that they should resend the message that failed, not that the original functionality of that message has been performed.
				return YES;
			}];
			/*
				The `userInfo` dictionary populated with our localized title and messages strings and `RMErrorRecoveryAttempter`. If you have an underlying 
				error, for example an error from a failed `-[NSManagedObjectContext save:]`, you can include it under the `NSUnderlyingErrorKey`.
			 */
			NSDictionary *userInfo = @{
				NSLocalizedDescriptionKey : NSLocalizedString(@"Cannot delete a locked item", @"RMMasterViewController delete locked item error description"),
				NSLocalizedRecoverySuggestionErrorKey : NSLocalizedString(@"This item cannot be deleted because it is currently locked. Would you like to Unlock & Delete this item?", @"RMMasterViewController delete locked item error recovery suggestion"),
				NSRecoveryAttempterErrorKey : errorRecoveryAttempter,
				NSLocalizedRecoveryOptionsErrorKey : [errorRecoveryAttempter recoveryOptions],
			};
			*errorRef = [NSError errorWithDomain:RMErrorRecoveryAttempterSampleProjectErrorDomain code:RMErrorRecoveryAttempterSampleProjectErrorCodeLockedItem userInfo:userInfo];
		}
		return NO;
	}
	
	NSUInteger index = [[self items] indexOfObject:item];
	[[self items] removeObjectAtIndex:index];
	[[self tableView] deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	
	return YES;
}

@end
