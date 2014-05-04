//
//  MRPhotoChooserViewController.m
//  CardChewer
//
//  Created by Michael Roher on 4/30/14.
//  Copyright (c) 2014 Michael Roher. All rights reserved.
//

#import "MRPhotoChooserViewController.h"
#import "MRResultsViewController.h"

#define kHelpTextBeforeImageSelected @"Please select a photo"
#define kHelpTextAfterImageSelected @"Is this the right photo?"

@interface MRPhotoChooserViewController ()
@property (strong, nonatomic) UIImage *chosenImage;
@property (strong, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIButton *chooseImageButton;
@property (strong, nonatomic) IBOutlet UILabel *helpLabel;
@property (strong, nonatomic) IBOutlet UIButton *incorrectImageButton;
@property (strong, nonatomic) IBOutlet UIButton *correctImageButton;
- (void)showImageButtonsAfterSelection:(bool)correctImage;
- (IBAction)chooseImageButtonPressed:(id)sender;
- (IBAction)correctImageButtonPressed:(id)sender;
- (IBAction)incorrectImageButtonPressed:(id)sender;

@end

@implementation MRPhotoChooserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

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



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    MRResultsViewController *resultsViewController = (MRResultsViewController *)[segue destinationViewController];
    resultsViewController.image = self.chosenImage;
}


@end
