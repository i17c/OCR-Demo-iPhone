//
//  MRTesseract.h
//  CardChewer
//
//  Created by Michael Roher on 5/3/14.
//  Copyright (c) 2014 Michael Roher. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface MRTesseract : NSObject
- (NSString *)readImage: (UIImage *)sourceImage;
@end
