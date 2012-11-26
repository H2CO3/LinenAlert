/*
 * LinenAlertContainerView.h
 * LinenAlert
 *
 * Created by Arpad Goretity on 23/11/2012
 * Licensed under the 3-clause BSD License
 */

#import <UIKit/UIKit.h>
#import "UnselectableTextView.h"

@interface LinenAlertContainerView: UIView {
	UIImageView *upperFakeHalfScreen;
	UIImageView *lowerFakeHalfScreen;
	UILabel *titleLabel;
	UnselectableTextView *messageView;
	UIAlertView *alertView;
	NSMutableArray *buttons;
	NSInteger dismissButtonIndex;
}

- (id)initWithAlertView:(UIAlertView *)av;
- (void)show;
- (void)dismissWithButtonIndex:(NSInteger)idx;
- (void)setTransformForCurrentOrientation;

@property (nonatomic, retain) UIImageView *upperFakeHalfScreen;
@property (nonatomic, retain) UIImageView *lowerFakeHalfScreen;
@property (nonatomic, retain) UIAlertView *alertView;

@end
