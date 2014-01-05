//
//  YFInternalConfigPanelViewController.h
//
//  Created by Elton Gao on 01/03/14.
//  Copyright (c) 2014 Elton Gao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YFInternalConfigTableViewCell : UITableViewCell
@property (nonatomic, strong) NSDictionary *associatedConfigDictionary;
@property (nonatomic, strong) NSString *associatedKey;
@end

@interface YFInternalConfigTextField : UITextField
@property (nonatomic, strong) NSString *associatedConfigKey;
@property (nonatomic, strong) NSIndexPath *associatedCellIndexPath;
@end

@interface YFInternalConfigPanelViewController : UITableViewController

@end
