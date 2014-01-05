//
//  YFInternalConfigPanelViewController.m
//
//  Created by Elton Gao on 01/03/14.
//  Copyright (c) 2014 Elton Gao. All rights reserved.
//

#import "YFInternalConfigPanelViewController.h"
#import "YFInternalConfigArrayViewController.h"
#import "YFInternalConfigManager.h"
#import "YFInternalConfigManager+Private.h"

#define kCellIdentifier @"cell_reuseIdentifier"

#define kNavigationBarTitle @"Internal Settings"
#define kLastSectionFooterTitle @"To ensure new configs really kick in,\nPlease restart the app."

////////////////////////////////////////
@interface YFInternalConfigSwitch : UISwitch
@property (nonatomic, strong) NSString *associatedConfigKey;
@property (nonatomic, strong) NSIndexPath *associatedCellIndexPath;
@end

@implementation YFInternalConfigSwitch
//empty implementation
@end

@implementation YFInternalConfigTextField
//empty implementation
@end

@implementation YFInternalConfigTableViewCell
//empty implementation
@end
////////////////////////////////////////


@interface YFInternalConfigPanelViewController () <UITextFieldDelegate>
@property (nonatomic, strong) NSArray *configArray;
@property (nonatomic, strong) NSMutableArray *sectionsIndexInConfigArray;
@property (nonatomic, strong) NSMutableArray *rowsCountInConfigArray;

@end

@implementation YFInternalConfigPanelViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initializations
        _configArray = [[YFInternalConfigManager sharedManager] configArray];
        _sectionsIndexInConfigArray = [NSMutableArray array];
        _rowsCountInConfigArray = [NSMutableArray array];
    }
    return self;
}

- (void)processNumberOfSections {
    NSUInteger index = 0;
    NSUInteger rowCount = 0;
    for (NSDictionary *dict in self.configArray) {
        NSString *key = [[YFInternalConfigManager sharedManager] keyForSingleKeyDictionary:dict];
        if ([key isEqualToString:kSectionTitleKey]) {
            [_sectionsIndexInConfigArray addObject:[NSNumber numberWithInteger:index]];
            [_rowsCountInConfigArray addObject:[NSNumber numberWithInteger:rowCount]];
            rowCount = 0;
        } else {
            if (index == 0) {
                [NSException raise:@"YFInternalConfigInvalidConfigArrayException" format:@"first entry of the array must be a section title"];
            }
            rowCount++;
        }
        index++;
    }
    //add the last row count of the section and remove the first one
    if ([self.sectionsIndexInConfigArray count] > 0) {
        [_rowsCountInConfigArray addObject:[NSNumber numberWithInteger:rowCount]];
        [_rowsCountInConfigArray removeObjectAtIndex:0];
    }
    NSAssert([self.sectionsIndexInConfigArray count] == [self.rowsCountInConfigArray count], nil);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = kNavigationBarTitle;
    [self processNumberOfSections];

    [self.tableView registerClass:[YFInternalConfigTableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [self.sectionsIndexInConfigArray count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.rowsCountInConfigArray objectAtIndex:section] integerValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YFInternalConfigTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor blackColor];

    NSUInteger sectionIndex = [[self.sectionsIndexInConfigArray objectAtIndex:indexPath.section] integerValue];
    NSUInteger indexInConfigArray = sectionIndex + 1 + indexPath.row;
    NSDictionary *dict = [self.configArray objectAtIndex:indexInConfigArray];
    NSString *key = [[YFInternalConfigManager sharedManager] keyForSingleKeyDictionary:dict];
    cell.textLabel.text = key;
    cell.associatedKey = key;
    YFInternalConfig *config = [dict objectForKey:key];
    cell.associatedConfigDictionary = dict;
    NSInteger type = [YFInternalConfig getType:config];
    cell.tag = type;
    if (type == YFInternalConfigTypeBool) {
        YFInternalConfigSwitch *aSwitch = [[YFInternalConfigSwitch alloc] init];
        aSwitch.associatedConfigKey = key;
        aSwitch.on = [[YFInternalConfig getValue:config] boolValue];
        aSwitch.associatedCellIndexPath = indexPath;
        [aSwitch addTarget:self action:@selector(onSwtichValueChanged:) forControlEvents:UIControlEventValueChanged];
        cell.accessoryView = aSwitch;
    } else if (type == YFInternalConfigTypeInt || type == YFInternalConfigTypeFloat) {
        NSNumber *value = [YFInternalConfig getValue:config];
        YFInternalConfigTextField *textField = [[YFInternalConfigTextField alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
        textField.associatedConfigKey = key;
        textField.associatedCellIndexPath = indexPath;
        textField.text = [value stringValue];
        textField.textAlignment = NSTextAlignmentRight;
        textField.tag = type;
        textField.delegate = self;
        cell.accessoryView = textField;
    } else if (type == YFInternalConfigTypeString) {
        NSString *value = [YFInternalConfig getValue:config];
        YFInternalConfigTextField *textField = [[YFInternalConfigTextField alloc] initWithFrame:CGRectMake(0, 0, 130, 40)];
        textField.associatedConfigKey = key;
        textField.associatedCellIndexPath = indexPath;
        textField.textAlignment = NSTextAlignmentRight;
        textField.text = value;
        textField.tag = type;
        textField.delegate = self;
        cell.accessoryView = textField;
    } else if (type == YFInternalConfigTypeArray) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else if (type == YFInternalConfigTypeOption) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSDictionary *dict =  [self.configArray objectAtIndex:[[self.sectionsIndexInConfigArray objectAtIndex:section] integerValue]];
    NSString *key = [[YFInternalConfigManager sharedManager] keyForSingleKeyDictionary:dict];
    return [dict objectForKey:key];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == [self.sectionsIndexInConfigArray count] - 1) {
        //last section, show a footer
        return kLastSectionFooterTitle;
    }
    return nil;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YFInternalConfigTableViewCell *cell = (YFInternalConfigTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    YFInternalConfigType type = cell.tag;
    if (type == YFInternalConfigTypeArray) {
        YFInternalConfigArrayViewController *vc = [[YFInternalConfigArrayViewController alloc]
                                                                            initWithStyle:UITableViewStyleGrouped
                                                                                   config:[cell.associatedConfigDictionary
                                                                             objectForKey:cell.associatedKey]
                                                                                      key:cell.associatedKey];
        [self.navigationController pushViewController:vc animated:YES];
    } else if (type == YFInternalConfigTypeOption) {
        YFInternalConfigArrayViewController *vc = [[YFInternalConfigArrayViewController alloc]
                                                    initWithStyle:UITableViewStyleGrouped
                                                    config:[cell.associatedConfigDictionary objectForKey:cell.associatedKey]
                                                       key:cell.associatedKey];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - UITextField Delegate
- (void)textFieldDidEndEditing:(YFInternalConfigTextField *)textField {
    NSAssert([textField isKindOfClass:[YFInternalConfigTextField class]], nil);
    //give default value
    if ([textField.text isEqualToString:@""]) {
        if (textField.tag == YFInternalConfigTypeInt || textField.tag == YFInternalConfigTypeFloat) {
            textField.text = 0;
        }
    }
    //now update and store the value
    if (textField.tag == YFInternalConfigTypeInt) {
        [[YFInternalConfigManager sharedManager] storeInt:[textField.text intValue] forKey:textField.associatedConfigKey];
    } else if (textField.tag == YFInternalConfigTypeFloat) {
        [[YFInternalConfigManager sharedManager] storeFloat:[textField.text floatValue] forKey:textField.associatedConfigKey];
    } else if (textField.tag == YFInternalConfigTypeString) {
        [[YFInternalConfigManager sharedManager] storeString:textField.text forKey:textField.associatedConfigKey];
    } else {
        [NSException raise:@"YFInternalConfigInconsistentTypeError" format:@"textField not supporting this type %d", textField.tag];
    }
}

#pragma mark - UIAction
- (void)onSwtichValueChanged:(id)sender {
    NSAssert([sender isKindOfClass:[YFInternalConfigSwitch class]], nil);
    YFInternalConfigSwitch *aSwitch = (YFInternalConfigSwitch*)sender;
    [[YFInternalConfigManager sharedManager] storeBool:aSwitch.on forKey:aSwitch.associatedConfigKey];
}
@end
