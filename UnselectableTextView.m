/*
 * UnselectableTextView.m
 * LinenAlert
 *
 * Created by Arpad Goretity on 23/11/2012
 * Licensed under the 3-clause BSD License
 */

#import "UnselectableTextView.h"

@implementation UnselectableTextView

- (BOOL)canBecomeFirstResponder
{
	return NO;
}

@end
