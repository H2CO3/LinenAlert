/*
 * LinenAlertContainerView.m
 * LinenAlert
 *
 * Created by Arpad Goretity on 23/11/2012
 * Licensed under the 3-clause BSD License
 */

#import <QuartzCore/QuartzCore.h>
#import "LinenAlertContainerView.h"
#import "UIImage+Crop.h"

#define LinenAlertAnimationDuration (0.7f)

extern CGImageRef UIGetScreenImage();

@implementation LinenAlertContainerView

@synthesize upperFakeHalfScreen, lowerFakeHalfScreen, alertView;

- (id)initWithAlertView:(UIAlertView *)av
{
	if ((self = [super init])) {
		self.clipsToBounds = YES;
		self.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];		
		self.alertView = av;
		self.upperFakeHalfScreen = [[[UIImageView alloc] init] autorelease];
		self.lowerFakeHalfScreen = [[[UIImageView alloc] init] autorelease];

		titleLabel = [[UILabel alloc] init];
		titleLabel.backgroundColor = [UIColor clearColor];
		titleLabel.textAlignment = UITextAlignmentCenter;
		titleLabel.textColor = [UIColor whiteColor];
		titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
		titleLabel.layer.cornerRadius = 7.5f;
		titleLabel.layer.borderWidth = 2.0f;
		titleLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
		[self addSubview:titleLabel];

		messageView = [[UnselectableTextView alloc] init];
		messageView = [[UnselectableTextView alloc] init];
		messageView.backgroundColor = [UIColor clearColor];
		messageView.textAlignment = UITextAlignmentCenter;
		messageView.textColor = [UIColor whiteColor];
		messageView.font = [UIFont systemFontOfSize:16.0f];
		messageView.editable = NO;
		messageView.layer.cornerRadius = 7.5f;
		messageView.layer.borderWidth = 2.0f;
		messageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
		[self addSubview:messageView];

		buttons = [[NSMutableArray alloc] init];
	}
	return self;
}

- (void)dealloc
{
	self.alertView = nil;
	self.upperFakeHalfScreen = nil;
	self.lowerFakeHalfScreen = nil;
	[titleLabel release];
	[messageView release];
	[buttons release];
	[super dealloc];
}

- (void)show
{
	CGRect wforig = [[[UIApplication sharedApplication] keyWindow] frame];

	// Set upside-down transform if needed
	[self setTransformForCurrentOrientation];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init]; // for the UIImages
	// Take a screenshot
	CGImageRef cgScreenshot = UIGetScreenImage();
	UIImage *screenshot = [UIImage imageWithCGImage:cgScreenshot];
	CGImageRelease(cgScreenshot);
	CGSize halfsize = screenshot.size;
	halfsize.height = halfsize.height / 2;
	
	// Create the image views faking the window
	UIImage *upperHalf = [screenshot cropToRect:(CGRect){ CGPointZero, halfsize }];
	UIImage *lowerHalf = [screenshot cropToRect:(CGRect){ (CGPoint){ 0.0f, halfsize.height }, halfsize }];
	upperFakeHalfScreen.image = upperHalf;
	lowerFakeHalfScreen.image = lowerHalf;
	upperFakeHalfScreen.frame = CGRectMake(0.0f, 0.0f, wforig.size.width, wforig.size.height / 2);
	lowerFakeHalfScreen.frame = CGRectMake(0.0f, wforig.size.height / 2, wforig.size.width, wforig.size.height / 2);
	
	[pool release];
	
	// Configure title and message
	// Here, if I don't use a temporary variable, GCC exits with the following error:
	// error: assignment of read-only variable 'prop.247'
	// LinenAlertView.m:113: warning: left-hand operand of comma expression has no effect
	// Seems a compiler bug (?) or I am missing some C syntax (?)
	titleLabel.text = self.alertView.title;
	CGRect wtfIsThisNeeded = titleLabel.text.length != 0 ? CGRectMake(14.0f, 14.0f, wforig.size.width - 28.0f, 39.0f) : CGRectZero;
	titleLabel.frame = wtfIsThisNeeded;
	
	// same error here
	messageView.text = self.alertView.message;
	wtfIsThisNeeded = messageView.text.length != 0 ? CGRectMake(14.0f, CGRectGetMaxY(titleLabel.frame) + 14.0f, wforig.size.width - 28.0f, 88.0f) : CGRectZero;
	messageView.frame = wtfIsThisNeeded;
	
	CGSize msgSize = [self.alertView.message sizeWithFont:messageView.font constrainedToSize:CGSizeMake(messageView.frame.size.width, 120.0f)];
	CGRect msgFrame = messageView.frame;
	msgFrame.size.height = msgSize.height + 18.0f;
	messageView.frame = msgFrame;
	
	// Find out if it's the title or the message body which is in the lower position
	// (this is necessary because either one can be omitted)
	CGFloat alertMaxY = CGRectGetMaxY(messageView.frame) > CGRectGetMaxY(titleLabel.frame) ? CGRectGetMaxY(messageView.frame) : CGRectGetMaxY(titleLabel.frame);

	CGRect leftBtnFrm = CGRectMake(14.0f, alertMaxY + 14.0f, (wforig.size.width - 42.0f) / 2, 44.0f);
	CGRect rightBtnFrm = leftBtnFrm;
	rightBtnFrm.origin.x += leftBtnFrm.size.width + 14.0f;

	UIButton *btn;
	NSString *buttonTitle;
	int i;
	for (i = 0; i < [self.alertView numberOfButtons]; i++) {
		buttonTitle = [self.alertView buttonTitleAtIndex:i];
		btn = [UIButton buttonWithType:UIButtonTypeCustom];
		btn.frame = i % 2 != 0 ? rightBtnFrm : leftBtnFrm;
		
		if (i % 2 != 0) {
			leftBtnFrm.origin.y += 58.0f;
			rightBtnFrm.origin.y += 58.0f;
		}
		
		btn.backgroundColor = [UIColor clearColor];
		btn.layer.cornerRadius = 7.5f;
		btn.layer.borderWidth = 2.0f;
		btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
		[btn setTitle:buttonTitle forState:UIControlStateNormal];
		[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[btn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
		[btn addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		btn.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
		[buttons addObject:btn];
		[self addSubview:btn];
	}

	// If there's an odd number of buttons, then we expand the last one to fill the width of the screen
	if ([self.alertView numberOfButtons] % 2 != 0) {
		UIButton *lastBtn = [buttons lastObject];
		CGRect lastFrm = lastBtn.frame;
		lastFrm.size.width = wforig.size.width - 28.0f;
		lastBtn.frame = lastFrm;
	}
	
	CGFloat fullHeight = CGRectGetMaxY(leftBtnFrm) + 14.0f;
	// Since we increment `leftBtnFrm` and `rightBtnFrm` once per 2 iterations,
	// if there's an even number of buttons, the calculate height will be 44 + 14
	// pixels more than that is actually necessary. Correction for this:
	if ([self.alertView numberOfButtons] % 2 == 0) {
		fullHeight -= 44 + 14;
	}

	// Animate the display effect
	CGRect wf = wforig;
	wf.origin.y = wf.size.height / 2;
	wf.size.height = 0.0f;
	self.frame = wf;
	
	[[[UIApplication sharedApplication] keyWindow] addSubview:upperFakeHalfScreen];
	[[[UIApplication sharedApplication] keyWindow] addSubview:lowerFakeHalfScreen];
	[[[UIApplication sharedApplication] keyWindow] addSubview:self];

	if ([self.alertView.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
		[self.alertView.delegate willPresentAlertView:self.alertView];
	}

	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(openAnimationEnded:finished:context:)];
	[UIView setAnimationDuration:LinenAlertAnimationDuration];
	
	CGRect fakeHalfScreenRect;
	
	fakeHalfScreenRect = upperFakeHalfScreen.frame;
	fakeHalfScreenRect.origin.y -= fullHeight / 2;
	upperFakeHalfScreen.frame = fakeHalfScreenRect;
	
	fakeHalfScreenRect = lowerFakeHalfScreen.frame;
	fakeHalfScreenRect.origin.y += fullHeight / 2;
	lowerFakeHalfScreen.frame = fakeHalfScreenRect;

	wf = wforig;
	wf.origin.y += (wf.size.height - fullHeight) / 2;
	wf.size.height = fullHeight;
	self.frame = wf;
	
	[UIView commitAnimations];
}

- (void)dismissWithButtonIndex:(NSInteger)idx
{
	// Animate the accordion-style closure movement
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:LinenAlertAnimationDuration];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(closeAnimationEnded:finished:context:)];
	
	CGRect fakeHalfScreenRect;
	CGFloat fullHeight = self.frame.size.height;
	
	fakeHalfScreenRect = upperFakeHalfScreen.frame;
	fakeHalfScreenRect.origin.y += fullHeight / 2;
	upperFakeHalfScreen.frame = fakeHalfScreenRect;
	
	fakeHalfScreenRect = lowerFakeHalfScreen.frame;
	fakeHalfScreenRect.origin.y -= fullHeight / 2;
	lowerFakeHalfScreen.frame = fakeHalfScreenRect;
	
	CGRect wf = [[[UIApplication sharedApplication] keyWindow] frame];
	wf.origin.y = wf.size.height / 2;
	wf.size.height = 0.0f;
	self.frame = wf;
	
	[UIView commitAnimations];
}

// Callback to be called when the opening animation finishes
- (void)openAnimationEnded:(NSString *)animID finished:(NSNumber *)finished context:(void *)ctx
{
	if ([self.alertView.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
		[self.alertView.delegate didPresentAlertView:self.alertView];
	}
}

// This callback is invoked when the closure animation finishes
- (void)closeAnimationEnded:(NSString *)animID finished:(NSNumber *)finished context:(void *)ctx
{
	UIButton *btn;
	for (btn in buttons) {
		[btn removeFromSuperview];
	}
	[buttons removeAllObjects];
	
	[upperFakeHalfScreen removeFromSuperview];
	[lowerFakeHalfScreen removeFromSuperview];
	
	// Call our delegate
	if ([self.alertView.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
		[self.alertView.delegate alertView:self.alertView didDismissWithButtonIndex:dismissButtonIndex];
	}

	// Call this as last: potential of deallocation
	[self removeFromSuperview];
}

- (void)buttonClicked:(UIButton *)btn
{
	dismissButtonIndex = [buttons indexOfObject:btn];
	
	if (dismissButtonIndex == self.alertView.cancelButtonIndex) {
		if ([self.alertView.delegate respondsToSelector:@selector(alertViewCancel:)]) {
			[self.alertView.delegate alertViewCancel:self.alertView];
		}
	}
	
	if ([self.alertView.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
		[self.alertView.delegate alertView:self.alertView clickedButtonAtIndex:dismissButtonIndex];
	}
	
	// call the delegate - *will* dissmiss
	if ([self.alertView.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
		[self.alertView.delegate alertView:self.alertView willDismissWithButtonIndex:dismissButtonIndex];
	}

	// dismiss
	[self dismissWithButtonIndex:dismissButtonIndex];
}

- (void)setTransformForCurrentOrientation
{	
	// Stay in sync with the superview
	if (self.superview) {
		self.bounds = self.superview.bounds;
		[self setNeedsDisplay];
	}
	
	CGAffineTransform rotationTransform;
	
	UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
	CGFloat radians = 0;
	if (UIInterfaceOrientationIsPortrait(orientation)) {
		if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
			radians = M_PI;
		} else {
			radians = 0;
		}
	/*
	} else {
		if (orientation == UIInterfaceOrientationLandscapeLeft) {
			radians =  -M_PI_2;
		} else {
			radians = M_PI_2;
		}
		// swap width and height
		containerView.bounds = CGRectMake(0, 0, containerView.bounds.size.height, containerView.bounds.size.width);
	*/
	}

	rotationTransform = CGAffineTransformMakeRotation(radians);
	self.transform = CGAffineTransformConcat(self.transform, rotationTransform);
}

@end
