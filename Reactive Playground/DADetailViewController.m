//
//  DADetailViewController.m
//  Reactive Playground
//
//  Created by Darmen Amanbayev on 3/16/14.
//  Copyright (c) 2014 Darmen Amanbayev. All rights reserved.
//

#import "DADetailViewController.h"

@interface DADetailViewController ()
- (BOOL)isValidUsername:(NSString *)username;
- (BOOL)isValidPassword:(NSString *)password;
@end

@implementation DADetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.dummyService = [DADummyService new];
    
    // Validation
    RACSignal *validUsernameSignal = [self.usernameTextField.rac_textSignal
                                      map:^id(NSString *text) {
                                          return @([self isValidUsername:text]);
                                      }];
    
    RACSignal *validPasswordSignal = [self.passwordTextField.rac_textSignal
                                      map:^id(NSString *text) {
                                          return @([self isValidPassword:text]);
                                      }];
    
    RAC(self.passwordTextField, backgroundColor) = [validPasswordSignal map:^id(NSNumber *valid) {
        return [valid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
    }];
    
    RAC(self.usernameTextField, backgroundColor) = [validUsernameSignal map:^id(NSNumber *valid) {
        return [valid boolValue] ? [UIColor clearColor] : [UIColor yellowColor];
    }];
    
    RACSignal *signUpActiveSignal =
        [RACSignal
         combineLatest:@[validUsernameSignal, validPasswordSignal]
         reduce:^id(NSNumber *usernameValid, NSNumber *passwordValid) {
             return @(usernameValid.boolValue && passwordValid.boolValue);
         }];
    
    RAC(self.loginButton, enabled) = [signUpActiveSignal map:^id(NSNumber *valid) {
        return @(valid.boolValue);
    }];
    
    // Action
    [[[[self.loginButton rac_signalForControlEvents:UIControlEventTouchUpInside]
    doNext:^(id x) {
        self.loginButton.enabled = NO;
    }]
    flattenMap:^id(id x) {
        return [self signInSignal];
    }]
    subscribeNext:^(NSNumber *x) {
        self.loginButton.enabled = YES;
        BOOL success = x.boolValue;
        if (success) {
            NSLog(@"login successful");
        }
    }];
    
}

- (RACSignal *)signInSignal {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self.dummyService
         signInWithUsername:self.usernameTextField.text
         password:self.passwordTextField.text
         complete:^(BOOL success) {
             [subscriber sendNext:@(success)];
             [subscriber sendCompleted];
         }];
        return nil;
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)isValidUsername:(NSString *)username
{
    return username.length > 3;
}
- (BOOL)isValidPassword:(NSString *)password
{
    return password.length > 3;
}

@end
