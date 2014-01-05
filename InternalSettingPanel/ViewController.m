//
//  ViewController.m
//  InternalSettingPanel
//
//  Created by Yuanfeng on 2014-01-04.
//  Copyright (c) 2014 Elton Gao. All rights reserved.
//

#import "ViewController.h"
#import "YFInternalConfigPanelViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated {
    YFInternalConfigPanelViewController *vc = [[YFInternalConfigPanelViewController alloc] init];
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissViewController)];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

- (void)dismissViewController {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
