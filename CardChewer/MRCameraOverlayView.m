//
//  MRCameraOverlayView.m
//  CardChewer
//
//  Created by Michael Roher on 5/5/14.
//  Copyright (c) 2014 Michael Roher. All rights reserved.
//

#import "MRCameraOverlayView.h"

@implementation MRCameraOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Clear the background of the overlay:
        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        //Find and create the image
        UIImage *image = [UIImage imageNamed:kOverlayGraphicFilename];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(30, 100, 260, 200);
        //Add the image to the subview
        [self addSubview:imageView];
    }
    return self;
}

@end
