/*
 * UIImage+Crop.h
 * LinenAlert
 *
 * Created by Arpad Goretity on 23/11/2012
 * Licensed under the 3-clause BSD License
 */

#import <UIKit/UIKit.h>

@interface UIImage (Crop)
- (UIImage *)cropToRect:(CGRect)rect;
@end
