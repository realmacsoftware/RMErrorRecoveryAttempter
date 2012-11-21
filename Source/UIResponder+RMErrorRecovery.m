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

#if !defined(__has_feature)
#define __has_feature(x) 0
#endif

#if !__has_feature(objc_arc)
#error This source file must be built with ARC
#endif

#import "UIResponder+RMErrorRecovery.h"

#import <objc/runtime.h>

static NSString *_RMAlertViewDelegateContext = @"_RMAlertViewDelegateContext";

@interface _RMAlertViewDelegate : NSObject <UIAlertViewDelegate>

@property (strong, nonatomic) NSError *error;
@property (copy, nonatomic) void (^completionHandler)(BOOL recovered);

@end

@implementation _RMAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSError *error = [self error];
	BOOL recovered = [[error recoveryAttempter] attemptRecoveryFromError:error optionIndex:buttonIndex];
	if ([self completionHandler] != nil) {
		[self completionHandler](recovered);
	}
}

@end

#pragma mark -

@implementation UIResponder (RMErrorRecovery)

- (void)rm_presentError:(NSError *)error completionHandler:(void (^)(BOOL recovered))completionHandler
{
	_RMAlertViewDelegate *alertViewDelegate = [[_RMAlertViewDelegate alloc] init];
	[alertViewDelegate setError:error];
	[alertViewDelegate setCompletionHandler:completionHandler];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[error localizedDescription] message:[error localizedRecoverySuggestion] delegate:alertViewDelegate cancelButtonTitle:nil otherButtonTitles:nil];
	
	NSArray *recoveryOptions = [error localizedRecoveryOptions];
	if (recoveryOptions == nil || [recoveryOptions count] == 0) {
		[alertView addButtonWithTitle:NSLocalizedString(@"OK", @"UIResponder+RMErrorRecovery OK button title")];
	}
	else {
		[recoveryOptions enumerateObjectsUsingBlock:^ (NSString *title, NSUInteger idx, BOOL *stop) {
			[alertView addButtonWithTitle:title];
		}];
	}
	
	objc_setAssociatedObject(alertView, &_RMAlertViewDelegateContext, alertViewDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	
	[alertView show];
}

@end
