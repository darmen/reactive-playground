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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)isValidUsername:(NSString *)username
{
    return [username isEqualToString:@"user"];
}
- (BOOL)isValidPassword:(NSString *)password
{
    return [password isEqualToString:@"password"];
}

@end
