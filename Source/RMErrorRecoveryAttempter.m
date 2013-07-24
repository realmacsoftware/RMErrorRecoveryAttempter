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

#import "RMErrorRecoveryAttempter.h"

#import <objc/message.h>

@interface RMErrorRecoveryAttempter ()

@property (strong, nonatomic) NSMutableArray *titles;
@property (strong, nonatomic) NSMutableArray *blocks;

@end

@interface RMErrorRecoveryAttempter (RMFoundationDelegate)

@end

@implementation RMErrorRecoveryAttempter

- (id)init
{
	self = [super init];
	if (self == nil) {
		return nil;
	}
	
	_titles = [[NSMutableArray alloc] init];
	_blocks = [[NSMutableArray alloc] init];
	
	return self;
}

- (void)addRecoveryOptionWithLocalizedTitle:(NSString *)localizedTitle recoveryBlock:(BOOL (^)(void))recoveryBlock
{
	NSParameterAssert(localizedTitle != nil);
	NSParameterAssert(recoveryBlock != nil);
	
	[[self titles] addObject:[localizedTitle copy]];
	[[self blocks] addObject:[recoveryBlock copy]];
}

- (void)addCancelRecoveryOption
{
	[self addRecoveryOptionWithLocalizedTitle:NSLocalizedString(@"Cancel", @"RMErrorRecoveryAttempter cancel recovery option") recoveryBlock:^ BOOL (void) {
		return YES;
	}];
}

- (NSArray *)recoveryOptions
{
	return [_titles copy];
}

- (BOOL (^)(void))_recoveryHandlerAtIndex:(NSUInteger)idx
{
	return (BOOL (^)(void))[[self blocks] objectAtIndex:idx];
}

@end

@implementation RMErrorRecoveryAttempter (RMFoundationDelegate)

- (BOOL)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex
{
	return [self _recoveryHandlerAtIndex:recoveryOptionIndex]();
}

- (void)attemptRecoveryFromError:(NSError *)error optionIndex:(NSUInteger)recoveryOptionIndex delegate:(id)delegate didRecoverSelector:(SEL)didRecoverSelector contextInfo:(void *)contextInfo
{
	void (^originalDidRecover)(BOOL) = ^ (BOOL didRecover) {
		((void (*)(id, SEL, BOOL, void *))objc_msgSend)(delegate, didRecoverSelector, didRecover, contextInfo);
	};
	
	BOOL didRecover = [self _recoveryHandlerAtIndex:recoveryOptionIndex]();
	originalDidRecover(didRecover);
}

@end
