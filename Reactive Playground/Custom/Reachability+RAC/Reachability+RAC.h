//
//  Reachability+RAC.h
//  Reactive Playground
//
//  Created by Darmen Amanbayev on 3/21/14.
//  Copyright (c) 2014 Darmen Amanbayev. All rights reserved.
//

#import "Reachability.h"

@interface Reachability (RAC)
- (RACSignal *)rac_textSignal;
@end
