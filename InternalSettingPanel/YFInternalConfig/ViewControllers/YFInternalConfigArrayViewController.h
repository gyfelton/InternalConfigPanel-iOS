//
//  YFInternalConfigArrayViewController.h
//
//  Created by Elton Gao on 01/03/14.
//  Copyright (c) 2014 Elton Gao. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YFInternalConfig;
@interface YFInternalConfigArrayViewController : UITableViewController

- (id)initWithStyle:(UITableViewStyle)style config:(YFInternalConfig*)config key:(NSString*)key;

@end
