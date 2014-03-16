//
//  DADummyService.h
//  Reactive Playground
//
//  Created by Darmen Amanbayev on 3/17/14.
//  Copyright (c) 2014 Darmen Amanbayev. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DASignInResponse)(BOOL);

@interface DADummyService : NSObject
- (void)signInWithUsername:(NSString *)username password:(NSString *)password complete:(DASignInResponse)completeBlock;
@end
