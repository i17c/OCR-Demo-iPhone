//
//  MRAddressBookViewController.h
//  CardChewer
//
//  Created by Michael Roher on 5/7/14.
//  Copyright (c) 2014 Michael Roher. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JLActionSheet.h"
@interface MRAddressBookViewController : UIViewController <JLActionSheetDelegate>
@property(nonatomic, strong) NSMutableDictionary *dictionary;
@end
