# RMErrorRecoveryAttempter

RMErrorRecoveryAttempter is a class that conforms to the `NSErrorRecoveryAttempting` informal protocol and harnesses the power of blocks allowing you to provide recovery options for an error.

Read the [Cocoa Error Handling and Recovery](http://www.realmacsoftware.com/blog/cocoa-error-handling-and-recovery) blog post on the Realmac Blog for more error handling tips.

## Sample Project

The sample project, RMErrorRecoveryAttempterSampleProject, is an iOS app where locked and unlocked items can be created. If you swipe-to-delete an item that is locked an error is created. The user info dictionary of this error contains an `RMErrorRecoveryAttempter` object which has two recovery options, each with a title and a block object. The titles of these recovery options are used to populate the buttons of an alert and upon tapping a button the corresponding block object is executed. The recovery options return `YES` or `NO` to inform the caller whether to resend the original message that failed.

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

The alert is presented using the `UIResponder+RMErrorRecovery` category. If the `recovered` parameter of the completion handler is `YES` then the user chose a recovery path and so the message to delete the item is resent.

	- (void)rm_presentError:(NSError *)error completionHandler:(void (^)(BOOL recovered))completionHandler;
	
You can also specify which completion method should the UIAlertView use to call the completion handler:

    - (void)rm_presentError:(NSError *)error completionHandler:(void (^)(BOOL recovered))completionHandler completionMethod:(RMErrorRecoveryPresentedErrorCompletionMethod)competionMethod;

On OS X you can use either the following two AppKit methods to present the error.

	- (BOOL)presentError:(NSError *)error;
	- (void)presentError:(NSError *)error modalForWindow:(NSWindow *)window delegate:(id)delegate didPresentSelector:(SEL)didPresentSelector contextInfo:(void *)contextInfo;

## Requirements

- Either iOS 5.0 and above, or OS X 10.7 and above
- LLVM Compiler 4.0 and above
- ARC

If your project is not using ARC, you’ll need to set the `-fobjc-arc` compiler flag on the `RMErrorRecoveryAttempter` and `UIResponder+RMErrorRecovery` source files. To set these in Xcode, go to your active target and select the Build Phases tab. Expand the Compile Sources section, select the mentioned source files, press Enter, and insert `-fobjc-arc`.

## Contact

Please contact James Beith regarding this project, [james@realmacsoftware.com](mailto:james@realmacsoftware.com?subject=RMErrorRecoveryAttempter)  

## Credits

Keith Duncan, [@keith_duncan](https://twitter.com/account/redirect_by_id?id=15379821)  
Damien DeVille, [@DamienDeVille](https://twitter.com/account/redirect_by_id?id=40584312)  
James Beith, [@jamesbeith](https://twitter.com/account/redirect_by_id?id=35832158)

## License

See the LICENSE file for more info.