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

#import <UIKit/UIKit.h>
/*!
 \brief
 Presented error completion method (which UIAlerViewDelegate's method has to be used for completionHandler)
 */
typedef enum : NSInteger {
    RMErrorRecoveryPresentedErrorCompletionMethodClickedButton = 0,
    RMErrorRecoveryPresentedErrorCompletionMethodWillDismiss = 1,
    RMErrorRecoveryPresentedErrorCompletionMethodDidDismiss = 2,
} RMErrorRecoveryPresentedErrorCompletionMethod;

/*!
	\brief
	Presenting an alert from an error.
 */
@interface UIResponder (RMErrorRecovery)

#if NS_BLOCKS_AVAILABLE

/*!
	\brief
	Present an alert from an error with `RMErrorRecoveryPresentedErrorCompletionMethodClickedButton` completion method. An error that includes an `NSRecoveryAttempterErrorKey` object will include buttons with the `NSLocalizedRecoveryOptionsErrorKey` strings as titles.
 */
- (void)rm_presentError:(NSError *)error completionHandler:(void (^)(BOOL recovered))completionHandler;

/*!
 \brief
 Present an alert from an error with specified completion method. An error that includes an `NSRecoveryAttempterErrorKey` object will include buttons with the `NSLocalizedRecoveryOptionsErrorKey` strings as titles.
 */
- (void)rm_presentError:(NSError *)error completionHandler:(void (^)(BOOL recovered))completionHandler completionMethod:(RMErrorRecoveryPresentedErrorCompletionMethod)competionMethod;

#endif

@end
