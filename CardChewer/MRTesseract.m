//
//  MRTesseract.m
//  CardChewer
//
//  Created by Michael Roher on 5/3/14.
//  Copyright (c) 2014 Michael Roher. All rights reserved.
//

#import "MRTesseract.h"
#import <TesseractOCR/TesseractOCR.h>

//Tesseract
#define kTesseractLanguage                                       @"eng"
#define kTrainedDataPath                                         @"/tessdata/%@.traineddata"
#define kTesseractWhitelist                                      @"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
#define degreesToRadians( degrees )                              ( ( degrees ) / 180.0 * M_PI )

@interface MRTesseract (private) <TesseractDelegate>
- (void)storeLanguageFile;
- (UIImage *)optimizeImage:(UIImage *)src_img;
@end

@implementation MRTesseract

- (NSString *)readImage: (UIImage *)sourceImage; {
    __block NSString *recognizedText = nil;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        Tesseract *tesseract = [[Tesseract alloc] initWithLanguage:kTesseractLanguage];
        tesseract.delegate = self;
        [tesseract setVariableValue:kTesseractWhitelist forKey:@"tessedit_char_whitelist"];
        
        [self storeLanguageFile];
//        UIImage *newImage = [self optimizeImage:sourceImage];
        
        [tesseract setImage: sourceImage];
        
        [tesseract recognize];
        recognizedText = [tesseract recognizedText];
//        tesseract = nil;
    });
    return recognizedText;
}
- (void)storeLanguageFile {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    setenv("TESSDATA_PREFIX", [[documentsDirectory stringByAppendingPathComponent:@"/"] UTF8String], 1);
    NSString *tessdataDirectoryPath = [documentsDirectory stringByAppendingPathComponent:@"tessdata"];
    if (![fileManager fileExistsAtPath:tessdataDirectoryPath]) {
        if ([fileManager fileExistsAtPath:documentsDirectory]) {
            [fileManager createDirectoryAtPath:tessdataDirectoryPath withIntermediateDirectories:NO attributes:nil error:nil];
        }
    }
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"eng" ofType:@"traineddata"];
    NSString *destPath = [tessdataDirectoryPath stringByAppendingPathComponent:@"eng.traineddata"];
    if (![fileManager fileExistsAtPath:destPath])
        [fileManager copyItemAtPath:sourcePath toPath:destPath error:nil];
}


- (BOOL)shouldCancelImageRecognitionForTesseract:(Tesseract*)tesseract {
    NSLog(@"progress: %d", tesseract.progress);
    return NO;  // return YES, if you need to interrupt tesseract before it finishes
}

// this does the trick to have tesseract accept the UIImage.
- (UIImage *)optimizeImage:(UIImage *)src_img {
    CGColorSpaceRef d_colorSpace = CGColorSpaceCreateDeviceRGB();
    /*
     * Note we specify 4 bytes per pixel here even though we ignore the
     * alpha value; you can't specify 3 bytes per-pixel.
     */
    size_t d_bytesPerRow = src_img.size.width * 4;
    unsigned char * imgData = (unsigned char*)malloc(src_img.size.height*d_bytesPerRow);
    CGRect imageRect = CGRectMake(0, 0, src_img.size.width, src_img.size.height);
    CGContextRef context =  CGBitmapContextCreate(imgData, src_img.size.width,
                                                  src_img.size.height,
                                                  8, d_bytesPerRow,
                                                  d_colorSpace,
                                                  kCGBitmapAlphaInfoMask);
    
    UIGraphicsPushContext(context);
    // These next two lines 'flip' the drawing so it doesn't appear upside-down.
    CGContextTranslateCTM(context, 0.0, src_img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    /*
     * At this point, we have the raw ARGB pixel data in the imgData buffer, so
     * we can perform whatever image processing here.
     */
    // Draw a white background
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(context, imageRect);
    // Draw the luminosity on top of the white background to get grayscale
    [src_img drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0f];
    
    // Apply the source image's alpha
    [src_img drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    //    UIGraphicsPopContext();
    // After we've processed the raw data, turn it back into a UIImage instance.
    CGImageRef new_img = CGBitmapContextCreateImage(context);
    UIImage * convertedImage = [[UIImage alloc] initWithCGImage:
                                new_img];
    
    CGImageRelease(new_img);
    CGContextRelease(context);
    CGColorSpaceRelease(d_colorSpace);
    UIGraphicsPopContext();
    
    free(imgData);
    return convertedImage;
}
@end
