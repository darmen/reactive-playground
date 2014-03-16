//
//  DADetailViewController.m
//  Reactive Playground
//
//  Created by Darmen Amanbayev on 3/16/14.
//  Copyright (c) 2014 Darmen Amanbayev. All rights reserved.
//

#import "DADetailViewController.h"

@interface DADetailViewController ()
@end

@implementation DADetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.usernameTextField.rac_textSignal subscribeNext:^(id x){
        DLog(@"%@", x);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
