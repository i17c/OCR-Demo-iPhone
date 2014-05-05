//
//  MRPhotoChooserViewController.m
//  CardChewer
//
//  Created by Michael Roher on 4/30/14.
//  Copyright (c) 2014 Michael Roher. All rights reserved.
//

#import "MRPhotoChooserViewController.h"
#import "MRResultsViewController.h"
#import "MRTesseract.h"

@interface MRPhotoChooserViewController ()
@property (strong, nonatomic) UIImage *chosenImage;
@property (strong, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIButton *chooseImageButton;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel;
@property (strong, nonatomic) IBOutlet UIButton *incorrectImageButton;
@property (strong, nonatomic) IBOutlet UIButton *correctImageButton;
@property (strong, nonatomic) NSMutableDictionary *dictionary;
- (void)showImageButtonsAfterSelection:(bool)correctImage;
- (IBAction)chooseImageButtonPressed:(id)sender;
- (IBAction)correctImageButtonPressed:(id)sender;
- (IBAction)incorrectImageButtonPressed:(id)sender;

@end

@implementation MRPhotoChooserViewController

- (IBAction)chooseImageButtonPressed:(id)sender {
    NSLog(@"Image button pressed");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    } else {
        imagePicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }
    [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark Image Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (self.chosenImage) {
        self.helpLabel.text = kHelpTextAfterImageSelected;
        [self showImageButtonsAfterSelection:YES];
        [self.selectedImageView setImage:self.chosenImage];
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark after image is selected

- (IBAction)correctImageButtonPressed:(id)sender {
    MRTesseract *tesseract = [[MRTesseract alloc] init];
    NSString *recognizedText = [tesseract readImage: self.chosenImage];
    self.dictionary = [self groupWordsByType:recognizedText];
    [self performSegueWithIdentifier:@"showResults" sender:self];
}
- (IBAction)incorrectImageButtonPressed:(id)sender {
    [self showImageButtonsAfterSelection:NO];
    self.selectedImageView.image = [UIImage imageNamed:@"placeholder.png"];
    self.helpLabel.text = kHelpTextBeforeImageSelected;
}

- (void)showImageButtonsAfterSelection:(bool)correctImage {
    self.correctImageButton.enabled = correctImage;
    self.incorrectImageButton.enabled = correctImage;
    self.chooseImageButton.enabled = !correctImage;
    self.correctImageButton.hidden = !correctImage;
    self.incorrectImageButton.hidden = !correctImage;
    self.chooseImageButton.hidden = correctImage;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedImageView.layer.borderWidth = 5;
    self.selectedImageView.layer.cornerRadius = 2;
    self.selectedImageView.layer.borderColor = [[UIColor blackColor] CGColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark NSDataDetector
/*
 Goes through each word in the text passed in and groups the words by type
 e.g. phone numbers, links, postal codes, cities, countries, etc.
 @param text - the text to be checked for the different types
 */
- (NSMutableDictionary *)groupWordsByType:(NSString *)text {
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    //If there is no text passed in/read by the ocr scanner, then return
    //an empty dictionary otherwise the nsdatadetector will crash
    if (text.length > 0) {
        NSError *error = nil;
        NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeAddress | NSTextCheckingTypePhoneNumber
                                    | NSTextCheckingTypeLink error:&error];
        
        [detector enumerateMatchesInString:text
                                   options:kNilOptions
                                     range:NSMakeRange(0, [text length])
                                usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                                    if (result.resultType == NSTextCheckingTypePhoneNumber) {
                                        [dictionary setObject:[result phoneNumber] forKey:kPhoneNumberKey];
                                    } else if (result.resultType == NSTextCheckingTypeLink) {
                                        [dictionary setObject:[result URL] forKey:kLinkKey];
                                    } else if (result.resultType == NSTextCheckingTypeAddress) {
                                        [dictionary addEntriesFromDictionary:[result addressComponents]];
                                    }
                                }];
    }
    return dictionary;
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MRResultsViewController *resultsViewController = (MRResultsViewController *)[segue destinationViewController];
    resultsViewController.image = self.chosenImage;
    resultsViewController.dictionary = self.dictionary;
}


@end
