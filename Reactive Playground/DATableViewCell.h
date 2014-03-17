//
//  DATableViewCell.h
//  Reactive Playground
//
//  Created by Darmen Amanbayev on 3/17/14.
//  Copyright (c) 2014 Darmen Amanbayev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DATableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;

@end
