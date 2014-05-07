//
//  MRAddressBookViewController.m
//  CardChewer
//
//  Created by Michael Roher on 5/7/14.
//  Copyright (c) 2014 Michael Roher. All rights reserved.
//

#import "MRAddressBookViewController.h"
#import <AddressBookUI/AddressBookUI.h>
@interface MRAddressBookViewController () <ABNewPersonViewControllerDelegate>

@end

@implementation MRAddressBookViewController

@synthesize dictionary;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


#pragma mark - ABNewPersonDelegate
- (void)newPersonViewController:(ABNewPersonViewController *)newPersonView didCompleteWithNewPerson:(ABRecordRef)person {
    
}


#pragma mark - JLActionSheet Delegate

// Called when the action button is initially clicked
- (void) actionSheet:(JLActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == actionSheet.cancelButtonIndex)
        NSLog(@"Is cancel button");
    if (buttonIndex == 2) {
        NSLog(@"Create a new contact");
        ABRecordRef newPerson = ABPersonCreate();
        CFErrorRef error = NULL;
        ABPropertyID property = kNilOptions;
        CFTypeRef value = nil;
        for (id key in self.dictionary) {
            value = (__bridge CFTypeRef)([self.dictionary objectForKey:key]);
            NSInteger index = -1;
            if ([key isEqualToString:@"First Name"])
                property = kABPersonFirstNameProperty;
            else if ([key isEqualToString:@"Last Name"])
                property = kABPersonLastNameProperty;
            else if ([key isEqualToString:kPhoneNumberKey])
                index = kABPersonPhoneProperty;
            else if (key == NSTextCheckingStreetKey)
                index = kABPersonAddressProperty;
            else if (key == NSTextCheckingCityKey)
                index = kABPersonAddressProperty;
            else if (key == NSTextCheckingStateKey)
                index = kABPersonAddressProperty;
            else if (key == NSTextCheckingCountryKey)
                index = kABPersonAddressProperty;
            else if ([key isEqualToString:kLinkKey])
                index = kABPersonNoteProperty;
            else
                index = NSNotFound;
            
            ABRecordSetValue(newPerson, property, value, &error);
        }
        
        ABNewPersonViewController *contactPicker = [[ABNewPersonViewController alloc] init];
        contactPicker.displayedPerson = newPerson;
        contactPicker.newPersonViewDelegate = self;
        [self.navigationController pushViewController:contactPicker animated:YES];
        CFRelease(newPerson);
        CFRelease(value);
    } else if (buttonIndex == 1) {
        NSLog(@"Add to an existing contact");
    } else if (buttonIndex == actionSheet.cancelButtonIndex) {
        NSLog(@"Cancel button pressed");
    }
}

// Called when the action button fully disappears from view
- (void) actionSheet:(JLActionSheet *)actionSheet didDismissButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"Did dismiss");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
