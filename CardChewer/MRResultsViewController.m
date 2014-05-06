//
//  MRViewController.m
//  CardChewer
//
//  Created by Michael Roher on 4/30/14.
//  Copyright (c) 2014 Michael Roher. All rights reserved.
//

#import "MRResultsViewController.h"
#import "MRTesseract.h"

#define LOG(fmt, ...) NSLog((@"%s " fmt), __PRETTY_FUNCTION__,##__VA_ARGS__)
static NSString *kTypeCellID = @"typeCell";
static NSString *kTypePickerID = @"typePicker";
static NSString *kOtherCell = @"otherCell";

#pragma mark -

@interface MRResultsViewController () <UITableViewDataSource, UITableViewDelegate,
                                            UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, strong) NSMutableArray *dataArray;
//@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIPickerView *pickerView;
@property (nonatomic, strong) NSIndexPath *typePickerIndexPath;
@property (assign) NSInteger typePickerCellRowHeight;
//this button appears only when the picker is shown (ver <= iOS 6.1.x)
@property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
@property (nonatomic, strong) NSArray *pickerValues;


- (NSInteger)convertTypeKeyToTypeStringIndex:(id)typeKey;
@end

#pragma mark -

@implementation MRResultsViewController

@synthesize dictionary, image;

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
    self.pickerValues = [NSArray arrayWithObjects: @"First Name", @"Last Name", @"Phone Number", @"Address", @"City", @"State", @"Country", @"Link", nil];
    self.dataArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *itemOne = [@{kTitleKey: kHelpTextBeforeResultsAreVerified} mutableCopy];
//    [self.dataArray addObject:itemOne];
    for (id key in self.dictionary) {
        NSInteger index = [self convertTypeKeyToTypeStringIndex:key];
        if (index != NSNotFound) {
            NSMutableDictionary *item = [@{kTitleKey: [self.dictionary objectForKey:key], kTypeKey: [NSNumber numberWithInteger:index] } mutableCopy];
            [self.dataArray addObject:item];
    
        }
    }
    NSMutableDictionary *itemFour = [@{ kTitleKey : @"(other item1)" } mutableCopy];
    NSMutableDictionary *itemFive = [@{ kTitleKey : @"(other item2)" } mutableCopy];
    [self.dataArray addObject:itemFour];
    [self.dataArray addObject:itemFive];
    
    UITableViewCell *pickerViewCellToCheck = [self.tableView dequeueReusableCellWithIdentifier:kTypePickerID];
    self.typePickerCellRowHeight = pickerViewCellToCheck.frame.size.height;

    NSLog(@"%@", dictionary);
//    NSLog(@"Line 45: Results View Controller => %@", recognizedText);
//    NSLog(@"recongized text: %@", recognizedText);
//    NSMutableDictionary *words = [self groupWordsByType: recognizedText];
    
//    self.imageView.image = self.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Utilities
NSUInteger DeviceSystemMajorVersion() {
    static NSUInteger _deviceSystemMajorVersion = -1;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _deviceSystemMajorVersion = [[[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."] objectAtIndex:0] intValue];
    });
    
    return _deviceSystemMajorVersion;
}


#define EMBEDDED_TYPE_PICKER (DeviceSystemMajorVersion() >= 7)
/*
 Determines if the given indexPath has a cell below it with a
 UIPickerView.
 @param indexPath - The indexPth to check if its cell has a UIPicker below it
 */
- (BOOL)hasTypePickerForIndexPath:(NSIndexPath *)indexPath {
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkPickerCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    UIPickerView *checkPicker = (UIPickerView *)[checkPickerCell viewWithTag:kTypePickerTag];
    //Determine if the picker exists or it's nil
    return checkPicker != nil;
}

/*
 Updates the UIPickerView's value to match with the type of the cell above it 
 */
- (void)updateTypePicker {
    if (self.typePickerIndexPath != nil) {
        UITableViewCell *associatedTypePickerCell = [self.tableView cellForRowAtIndexPath:self.typePickerIndexPath];
        UIPickerView *targetedPicker = (UIPickerView *)[associatedTypePickerCell viewWithTag:kTypePickerTag];
        if (targetedPicker != nil) {
            //we found a UIPicker so let's update the value
            NSDictionary *itemData = self.dataArray[self.typePickerIndexPath.row - 1];
            NSInteger rowIndex = [[itemData valueForKey:kTypeKey] integerValue];
            [targetedPicker selectRow:rowIndex inComponent:0 animated:YES];
//            [targetedPicker setValuesForKeysWithDictionary:itemData];
        }
    }
}

/*
 Determines if the UITableViewController has a UITypePicker in any of its cells
 */
- (BOOL)hasInlineTypePicker {
    return self.typePickerIndexPath != nil;
}

/*
 Determines if the given index path [points to a cell that contains the UIPickerView
 
 @param indexPath - the index path to check if it represents a cell the UIPickerView
 */
- (BOOL)indexPathHasPicker:(NSIndexPath *)indexPath {
    return [self hasInlineTypePicker] && self.typePickerIndexPath.row == indexPath.row;
}

/*
 Determines if the given indexPath points to a cell that contains a picker 
 
 @param indexPath - the indexPath to check if it represents a picker cell
 */

- (BOOL)indexPathHasType:(NSIndexPath *)indexPath {
    BOOL hasType = NO;
    NSInteger lastRow = kTypePickerFirstRow + [self.dictionary count];
//    if ((indexPath.row == kTypeStartRow) ||
//        (indexPath.row == kTypeEndRow || ([self hasInlineTypePicker] && (indexPath.row == kTypeEndRow + 1))))
//    {
    if ((indexPath.row >= kTypePickerFirstRow && indexPath.row < lastRow) ||
        ([self hasInlineTypePicker] && indexPath.row == lastRow + 1)){
        hasType = YES;
    }
    
    return hasType;
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self indexPathHasPicker:indexPath] ? self.typePickerCellRowHeight : self.tableView.rowHeight;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    NSString *cellID = kOtherCell;
    if ([self indexPathHasPicker:indexPath]) {
        //this is the index path which contains the inline date picker
        cellID = kTypePickerID;
    } else if ([self indexPathHasType:indexPath]) {
        cellID = kTypeCellID;
    }
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (indexPath.row == 0) {
        //the first cell is not selectable..it's just a label
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    //if we have a type picker open whose cell is above the cell we want to update then we have one more cell that the model allows
    NSInteger modelRow = indexPath.row;
    if (self.typePickerIndexPath != nil && self.typePickerIndexPath.row < indexPath.row) {
        modelRow--;
    }
    
    //configure dat cell
    NSDictionary *itemData = self.dataArray[modelRow];
    if ([cellID isEqualToString:kTypeCellID]) {
        LOG(@"Creating TypeCell");
        cell.textLabel.text = [itemData valueForKey:kTitleKey];
        NSInteger pickerIndex = [[itemData valueForKey:kTypeKey] integerValue];
        cell.detailTextLabel.text = [self.pickerValues objectAtIndex:pickerIndex];
    } else if ([cellID isEqualToString:kOtherCell]) {
        //this cell is just a stupid text label
        cell.textLabel.text = [itemData valueForKey:kTitleKey];
    }
    return cell;
}

#pragma mark - UITableviewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell.reuseIdentifier == kTypeCellID) {
        if (EMBEDDED_TYPE_PICKER)
            [self displayInlineTypePickerForRowAtIndexPath:indexPath];
        else
            [self displayExternalTypePickerForRowAtIndexPath:indexPath];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numOfRows = self.dataArray.count;
    if ([self hasInlineTypePicker]) {
        //account for it in the number of rows in this section
        ++numOfRows;
    }
    return numOfRows;
}

/*
 Adds or removes a UITypePicker cell directly below the given indexPath
 
 @param indexPath - the indexPath to reveal the UIDatePicker
 */
-(void)toggleTypePickerForSelectedIndexPath:(NSIndexPath *)indexPath {

    [self.tableView beginUpdates];
    
    NSArray *indexPaths = @[[NSIndexPath indexPathForRow:indexPath.row + 1 inSection:0]];
    
    if ([self hasTypePickerForIndexPath:indexPath]) {
    
        //found a picker below it so remove it
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];

    } else {
        // didn't find a picker below it, so we should insert it
        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
    
    }
    
    [self.tableView endUpdates];
}

/*
 Reveals the picker inline for the given index path
 Called by: `didSelectRowAtIndexPath
 @param indexPath - the indexPath which has the picker
 */
- (void)displayInlineTypePickerForRowAtIndexPath:(NSIndexPath *)indexPath {
    //display the picker inline
    [self.tableView beginUpdates];
    
    //is the picker below the index path
    BOOL before = NO;
    
    if ([self hasInlineTypePicker]) {
        before = self.typePickerIndexPath.row < indexPath.row;
    }
    
    BOOL sameCellClicked = (self.typePickerIndexPath.row - 1 == indexPath.row);
    
    //remove any picker if it exists
    if ([self hasInlineTypePicker]) {
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.typePickerIndexPath.row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
        self.typePickerIndexPath = nil;
    }
    
    if (!sameCellClicked) {
        //hide the old picker and display the new one
        NSInteger rowToReveal = (before  ? indexPath.row - 1 : indexPath.row);
        NSIndexPath *indexPathToReveal = [NSIndexPath indexPathForRow:rowToReveal inSection:0];
        
        [self toggleTypePickerForSelectedIndexPath:indexPathToReveal];
        self.typePickerIndexPath = [NSIndexPath indexPathForRow:indexPathToReveal.row + 1 inSection:0];
    }
    
    //always deselect the row
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.tableView endUpdates];
    
    //Update the value of the type picker to match
    [self updateTypePicker];
}


/*
 Reveals the UIPickerView as an external slide-in view, iOS 6.1.x and earlier
 Called by: `didSelectRowAtIndexPath`
 @param indexPath - the indexPath which has the picker
 */
- (void)displayExternalTypePickerForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //first update the date picker's date value according to our model
    NSDictionary *itemData = self.dataArray[indexPath.row];
    NSInteger rowIndex = [[itemData valueForKey:kTypeKey] integerValue];
    [self.pickerView selectRow:rowIndex inComponent:0 animated:YES];
//    [self.pickerView setValuesForKeysWithDictionary:itemData];
    
    //the date picker might already be showing so don't add it tto our view
    if (self.pickerView.superview == nil) {
        
        CGRect startFrame = self.pickerView.frame;
        CGRect endFrame = self.pickerView.frame;
        
        //The start position is below the bottom of the visible frame
        startFrame.origin.y = self.view.frame.size.height;
        
        //the end position is slid up by the height of the view
        endFrame.origin.y = startFrame.origin.y - endFrame.size.height;
        
        self.pickerView.frame = startFrame;
        [self.view addSubview:self.pickerView];
        
        [UIView animateWithDuration:kTypePickerAnimationDuration animations:^{ self.pickerView.frame = endFrame; }
            completion:^(BOOL finished) {
                //add the done button to the nav bar
                self.navigationItem.rightBarButtonItem = self.doneButton;
            }];
    }
}

#pragma mark - UIPickerViewDatasource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.pickerValues count];
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.pickerValues objectAtIndex:row];
}
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSLog(@"selected %@", [self.pickerValues objectAtIndex:row]);
    NSIndexPath *targetedCellPath = nil;
    if ([self hasInlineTypePicker]) {
        //inline picker = update the cell above the picker
        targetedCellPath = [NSIndexPath indexPathForRow:self.typePickerIndexPath.row - 1 inSection:0];
    } else {
        //external picker = update the current cell
        targetedCellPath = [self.tableView indexPathForSelectedRow];
    }
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:targetedCellPath];
    
    NSMutableDictionary *itemData = self.dataArray[targetedCellPath.row];
    NSInteger selectedIndexInt = (NSInteger)[thePickerView selectedRowInComponent:0];
    NSNumber *selectedIndex = [NSNumber numberWithLong:selectedIndexInt];
    [itemData setValue:selectedIndex forKey:kTypeKey];
    
    cell.detailTextLabel.text = [self.pickerValues objectAtIndex:selectedIndexInt];
    
}

- (NSInteger)convertTypeKeyToTypeStringIndex:(id)key {
    NSInteger index = -1;
    if ([key isEqualToString:@"First Name"])
        index = 0;
    else if ([key isEqualToString:kPhoneNumberKey])
        index = 2;
    else if (key == NSTextCheckingStreetKey)
        index = 3;
    else if (key == NSTextCheckingCityKey)
        index = 4;
    else if (key == NSTextCheckingStateKey)
        index = 5;
    else if (key == NSTextCheckingCountryKey)
        index = 6;
    else if ([key isEqualToString:kLinkKey])
        index = 7;
    else
        index = NSNotFound;
    return index;
}
@end
