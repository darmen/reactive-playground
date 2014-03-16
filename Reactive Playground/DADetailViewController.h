//
//  DADetailViewController.h
//  Reactive Playground
//
//  Created by Darmen Amanbayev on 3/16/14.
//  Copyright (c) 2014 Darmen Amanbayev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DADetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
