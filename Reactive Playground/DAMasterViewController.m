//
//  DAMasterViewController.m
//  Reactive Playground
//
//  Created by Darmen Amanbayev on 3/16/14.
//  Copyright (c) 2014 Darmen Amanbayev. All rights reserved.
//

#import "DAMasterViewController.h"

#import "DADetailViewController.h"

@interface DAMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation DAMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"1. Login";
            break;
        
        case 1:
            cell.textLabel.text = @"2. Twitter Instant";
            break;
            
        default:
            break;
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self performSegueWithIdentifier:@"showLoginSegue" sender:nil];
            break;
        
        case 1:
            [self performSegueWithIdentifier:@"showTwitterInstantSegue" sender:nil];
            break;
            
        default:
            break;
    }
}


@end
