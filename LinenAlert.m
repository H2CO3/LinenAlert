/*
 * LinenAlert.m
 * LinenAlert
 *
 * Created by Arpad Goretity on 23/11/2012
 * Licensed under the 3-clause BSD License
 */

#import <substrate.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "LinenAlertContainerView.h"

static void *LinenAlertKeyContainerView = "LinenAlertKeyContainerView";

static IMP LinenAlert_orig_$_UIAlertView_$_show;
static IMP LinenAlert_orig_$_UIAlertView_$_dismissWithClickedButtonIndex_;
static IMP LinenAlert_orig_$_meta_$_UIAlertView_$_alloc;
static IMP LinenAlert_orig_$_UIAlertView_$_dealloc;

id LinenAlert_mod_$_meta_$_UIAlertView_$_alloc(Class self, SEL _cmd)
{
	id instance = LinenAlert_orig_$_meta_$_UIAlertView_$_alloc(self, _cmd);
	LinenAlertContainerView *cv = [[LinenAlertContainerView alloc] initWithAlertView:instance];
	objc_setAssociatedObject(instance, LinenAlertKeyContainerView, cv, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	return instance;
}

void LinenAlert_mod_$_UIAlertView_$_dealloc(UIAlertView *self, SEL _cmd)
{
	LinenAlertContainerView *cv = objc_getAssociatedObject(self, LinenAlertKeyContainerView);
	objc_setAssociatedObject(self, LinenAlertKeyContainerView, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[cv release];
	LinenAlert_orig_$_UIAlertView_$_dealloc(self, _cmd);
}

void LinenAlert_mod_$_UIAlertView_$_show(UIAlertView *self, SEL _cmd)
{
	if (self.alertViewStyle != UIAlertViewStyleDefault) {
		LinenAlert_orig_$_UIAlertView_$_show(self, _cmd);
		return;
	}

	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		LinenAlert_orig_$_UIAlertView_$_show(self, _cmd);
		return;
	}

	LinenAlertContainerView *cv = objc_getAssociatedObject(self, LinenAlertKeyContainerView);
	[cv show];
}

void LinenAlert_mod_$_UIAlertView_$_dismissWithClickedButtonIndex_(UIAlertView *self, SEL _cmd, NSInteger idx)
{
	if (self.alertViewStyle != UIAlertViewStyleDefault) {
		LinenAlert_orig_$_UIAlertView_$_dismissWithClickedButtonIndex_(self, _cmd, idx);
	}

	if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
		LinenAlert_orig_$_UIAlertView_$_dismissWithClickedButtonIndex_(self, _cmd, idx);
	}
	
	LinenAlertContainerView *cv = objc_getAssociatedObject(self, LinenAlertKeyContainerView);
	[cv dismissWithButtonIndex:idx];
}

__attribute__((constructor))
void init()
{
	MSHookMessageEx(
		objc_getMetaClass("UIAlertView"),
		@selector(alloc),
		(IMP)LinenAlert_mod_$_meta_$_UIAlertView_$_alloc,
		&LinenAlert_orig_$_meta_$_UIAlertView_$_alloc
	);

	MSHookMessageEx(
		[UIAlertView class],
		@selector(dealloc),
		(IMP)LinenAlert_mod_$_UIAlertView_$_dealloc,
		&LinenAlert_orig_$_UIAlertView_$_dealloc
	);

	MSHookMessageEx(
		[UIAlertView class],
		@selector(show),
		(IMP)LinenAlert_mod_$_UIAlertView_$_show,
		&LinenAlert_orig_$_UIAlertView_$_show
	);

	MSHookMessageEx(
		[UIAlertView class],
		@selector(dismissWithClickedButtonIndex:),
		(IMP)LinenAlert_mod_$_UIAlertView_$_dismissWithClickedButtonIndex_,
		&LinenAlert_orig_$_UIAlertView_$_dismissWithClickedButtonIndex_
	);
}
