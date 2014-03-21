//
//  DAReachabilityViewController.m
//  Reactive Playground
//
//  Created by Darmen Amanbayev on 3/21/14.
//  Copyright (c) 2014 Darmen Amanbayev. All rights reserved.
//

#import "DAReachabilityViewController.h"
#import "Reachability.h"

@interface DAReachabilityViewController ()
@property (nonatomic) Reachability *reachability;
@end

@implementation DAReachabilityViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];

    self.reachability = [Reachability reachabilityForInternetConnection];
    [self.reachability startNotifier];
    
    [self updateInterfaceWithReachability:self.reachability];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    switch (networkStatus) {
        case NotReachable:
        {
            self.reachabilityStatusLabel.text = @"Not reachable";
            break;
        }
            
        case ReachableViaWWAN:
        {
            self.reachabilityStatusLabel.text = @"Reachable via WWAN";
            break;
        }
        case ReachableViaWiFi:
        {
            self.reachabilityStatusLabel.text = @"Reachable via WiFi";
            break;
        }
    }
}

- (void)reachabilityChanged:(NSNotification *)notification
{
	Reachability *reachability = [notification object];
	NSParameterAssert([reachability isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:reachability];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
