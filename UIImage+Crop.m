/*
 * UIImage+Crop.m
 * LinenAlert
 *
 * Created by Arpad Goretity on 23/11/2012
 * Licensed under the 3-clause BSD License
 */

#import "UIImage+Crop.h"

@implementation UIImage (Crop)

- (UIImage *)cropToRect:(CGRect)rect
{
	rect = CGRectMake(
		rect.origin.x * self.scale,
                rect.origin.y * self.scale,
                rect.size.width * self.scale,
                rect.size.height * self.scale
	);

	CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
	UIImage *result = [UIImage imageWithCGImage:imageRef 
                                          scale:self.scale 
                                    orientation:self.imageOrientation];
	CGImageRelease(imageRef);
	return result;
}

@end
