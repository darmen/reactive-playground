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
    
    self.reachability = [Reachability reachabilityForInternetConnection];
    
    [[[self reachabilitySignal]
    deliverOn:[RACScheduler mainThreadScheduler]]
    subscribeNext:^(Reachability *reachability) {
        [self updateInterfaceWithReachability:self.reachability];
    }];
    
    [self updateInterfaceWithReachability:self.reachability];
}

- (RACSignal *)reachabilitySignal
{
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self);
        self.reachability.reachableBlock = ^(Reachability*reachability) {
            [subscriber sendNext:reachability];
        };
        
        self.reachability.unreachableBlock = ^(Reachability*reachability) {
            [subscriber sendNext:reachability];
        };
        
        [self.reachability startNotifier];
        return nil;
    }];
//    [[RACReplaySubject subject] subscribeNext:^(Reachability *reachability) {
//        @strongify(self);
//        [self updateInterfaceWithReachability:reachability];
//    }];
}

- (void)updateInterfaceWithReachability:(Reachability *)reachability
{
    self.reachabilityStatusLabel.text = reachability.isReachable ? @"Reachable" : @"Not reachable";
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
