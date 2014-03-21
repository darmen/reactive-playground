//
//  Reachability+RAC.m
//  Reactive Playground
//
//  Created by Darmen Amanbayev on 3/21/14.
//  Copyright (c) 2014 Darmen Amanbayev. All rights reserved.
//

#import "Reachability+RAC.h"
#import <objc/runtime.h>

@implementation Reachability (RAC)
- (RACSignal *)rac_textSignal {
    RACSignal *signal = objc_getAssociatedObject(self, _cmd);
    if (signal != nil) return signal;
    self rac
    signal = [[self rac_signalForSelector:@selector(searchBar:textDidChange:) fromProtocol:@protocol(UISearchBarDelegate)] map:^id(RACTuple *tuple) {
        return tuple.second;
    }];
    objc_setAssociatedObject(self, _cmd, signal, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return signal;
}
@end
