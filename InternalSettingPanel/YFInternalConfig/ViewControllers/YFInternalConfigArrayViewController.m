//
//  YFInternalConfigArrayViewController.m
//
//  Created by Elton Gao on 01/03/14.
//  Copyright (c) 2014 Elton Gao. All rights reserved.
//

#import "YFInternalConfigPanelViewController.h"
#import "YFInternalConfigArrayViewController.h"
#import "YFInternalConfigManager.h"
#import "YFInternalConfigManager+Private.h"

#define kCellIdentifier @"cell_reuseIdentifier"

@interface YFInternalConfigTextFieldCell : YFInternalConfigTableViewCell {
}
@property (nonatomic, readonly) YFInternalConfigTextField *textField;
@end

@implementation YFInternalConfigTextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _textField = [[YFInternalConfigTextField alloc] initWithFrame:CGRectMake(10,2,self.contentView.frame.size.width - 20, 40)];
        [self.contentView addSubview:_textField];
    }
    return self;
}

@end

@interface YFInternalConfigArrayViewController () <UITextFieldDelegate>
{
    YFInternalConfigType _type;
    NSUInteger _selectedIndex;
}
@property (nonatomic, strong) YFInternalConfig *config;
@property (nonatomic, strong) NSString *keyForTheConfig;
@property (nonatomic, strong) NSMutableArray *mutableArray;
@end

@implementation YFInternalConfigArrayViewController

- (id)initWithStyle:(UITableViewStyle)style config:(YFInternalConfig*)config key:(NSString *)key
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _config = config;
        _keyForTheConfig = key;
        _type = [YFInternalConfig getType:config];
        NSAssert((_type == YFInternalConfigTypeArray || _type == YFInternalConfigTypeOption),
                 @"YFInternalConfigArrayViewController only accept types of array or option for now");
        if (_type == YFInternalConfigTypeOption) {
            _selectedIndex = [YFInternalConfig getSelectedIndexForOption:_config];
        } else {
            _selectedIndex = -1;
        }

        //For both array and config, we have array to store the values
        _mutableArray = [NSMutableArray arrayWithArray:[YFInternalConfig getValue:config]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.tableView registerClass:[YFInternalConfigTextFieldCell class] forCellReuseIdentifier:kCellIdentifier];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    if (_type == YFInternalConfigTypeArray) {
        self.navigationItem.rightBarButtonItems = @[self.editButtonItem, [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(onAddEntryTapped:)]];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)removeEmptyEntries:(NSMutableArray*)mutableArray {
    for (int i = 0; i < mutableArray.count; i++) {
        YFInternalConfig *config = [mutableArray objectAtIndex:i];
        NSString *string = [YFInternalConfig getValue:config];
        if (string.length == 0) {
            [mutableArray removeObjectAtIndex:i];
        }
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    //remove empty string
    if (_type == YFInternalConfigTypeArray) {
        [self removeEmptyEntries:self.mutableArray];
        [[YFInternalConfigManager sharedManager] storeArray:self.mutableArray forKey:self.keyForTheConfig];
    }

    [super viewWillDisappear:animated];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.mutableArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YFInternalConfigTextFieldCell *cell = (YFInternalConfigTextFieldCell*)[tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    //clear everything
    cell.textLabel.text = nil;
    cell.accessoryView = nil;
    cell.accessoryType = UITableViewCellAccessoryNone;

    NSArray *array = self.mutableArray;
    if (indexPath.row >= array.count) {

    } else {
        YFInternalConfig *entryInConfig = [array objectAtIndex:indexPath.row];
        if (_type == YFInternalConfigTypeArray) {
            YFInternalConfigTextField *textField = cell.textField;
            textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            textField.text = [YFInternalConfig getValue:entryInConfig];
            textField.tag = indexPath.row;
            textField.delegate = self;
            textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
            textField.hidden = NO;
            if (textField.text.length == 0) {
                [textField becomeFirstResponder];
            }
        } else if (_type == YFInternalConfigTypeOption) {
            cell.textLabel.text = [YFInternalConfig getValue:entryInConfig];
            cell.textField.hidden = YES;
            if (_selectedIndex == indexPath.row) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        } else {
            [NSException raise:@"YFInternalConfigArrayViewControllerInconsistentParameterException"
                        format:@"Type can only be array or option, encounter: %d", _type];
        }
    }
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [YFInternalConfig getFooterStringForArrayOption:self.config];
}

#pragma mark - UITableView Delegate

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_mutableArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_type == YFInternalConfigTypeArray) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (_type == YFInternalConfigTypeOption){
        [[YFInternalConfigManager sharedManager] storeOptions:self.mutableArray selectedIndex:indexPath.row forKey:self.keyForTheConfig];
        _selectedIndex = indexPath.row;
        [tableView reloadData];
    }
}

- (void)onAddEntryTapped:(id)sender {
    [_mutableArray addObject:[YFInternalConfig s:@""]];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:_mutableArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - UITextField Delegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSAssert([textField isKindOfClass:[YFInternalConfigTextField class]], nil);
    int index = textField.tag;
    YFInternalConfig *newConfig = [YFInternalConfig s:textField.text];
    if (index >= 0 && index < self.mutableArray.count) {
        [self.mutableArray replaceObjectAtIndex:index withObject:newConfig];
    }
}

@end
