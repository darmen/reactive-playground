//
//  DATwitterInstantViewControllerTableViewController.m
//  Reactive Playground
//
//  Created by Darmen Amanbayev on 3/17/14.
//  Copyright (c) 2014 Darmen Amanbayev. All rights reserved.
//

#import "DATwitterInstantViewControllerTableViewController.h"
#import "UISearchBar+RAC.h"
#import "NSArray+LinqExtensions.h"
#import "DATweet.h"
#import "DATableViewCell.h"

typedef NS_ENUM(NSInteger, DATwitterInstantError) {
    DATwitterInstantErrorAccessDenied,
    DATwitterInstantErrorNoTwitterAccounts,
    DATwitterInstantErrorInvalidResponse
};

static NSString * const DATwitterInstantDomain = @"TwitterInstant";


@interface DATwitterInstantViewControllerTableViewController ()
@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) ACAccountType *twitterAccountType;
@property (strong, nonatomic) NSArray *tweets;
@end

@implementation DATwitterInstantViewControllerTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.accountStore = [[ACAccountStore alloc] init];
    self.twitterAccountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    RAC(self.searchBar, barTintColor) = [self.searchBar.rac_textSignal map:^id(NSString *text) {
        return [self isValidSearchText:text] ? [UIColor lightGrayColor] : [UIColor redColor];
    }];

    @weakify(self)
    [[[[[[self requestAccessToTwitterSignal]
    then:^RACSignal *{
        @strongify(self)
        return self.searchBar.rac_textSignal;
    }]
    filter:^BOOL(NSString *text) {
        @strongify(self)
        return [self isValidSearchText:text];
    }]
    flattenMap:^RACStream *(NSString *text) {
        @strongify(self)
        return [self signalForSearchWithText:text];
    }]
    deliverOn:[RACScheduler mainThreadScheduler]]
    subscribeNext:^(NSDictionary *jsonSearchResult) {
        NSArray *statuses = jsonSearchResult[@"statuses"];
        NSArray *tweets = [statuses linq_select:^id(id tweet) {
            return [DATweet tweetWithStatus:tweet];
        }];
        [self displayTweets:tweets];
    } error:^(NSError *error) {
        NSLog(@"An error occured: %@", error);
    }];
}

- (void)displayTweets:(NSArray *)tweets
{
    self.tweets = tweets;
    [self.tableView reloadData];
}

- (BOOL)isValidSearchText:(NSString *)text {
    return text.length > 3;
}

- (RACSignal *)requestAccessToTwitterSignal {
    // 1 - define the error
    NSError *accessError = [NSError errorWithDomain:DATwitterInstantDomain
                                               code:DATwitterInstantErrorAccessDenied
                                           userInfo:nil];
    
    // 2 - create the signal
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        // 3 - request access to Twitter
        @strongify(self)
        [self.accountStore
         requestAccessToAccountsWithType:self.twitterAccountType
         options:nil
         completion:^(BOOL granted, NSError *error) {
             // 4 - handle the response
             if (!granted) {
                 [subscriber sendError:accessError];
             } else {
                 [subscriber sendNext:nil];
                 [subscriber sendCompleted];
             }
         }];
        return nil;
    }];
    
}

- (SLRequest *)requestForTwitterSearchWithText:(NSString *)text {
    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/search/tweets.json"];
    NSDictionary *params = @{@"q":text};
    SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                            requestMethod:SLRequestMethodGET
                                                      URL:url
                                               parameters:params];
    
    return request;
}

- (RACSignal *)signalForSearchWithText:(NSString *)text {
    // 1 - define the errors
    NSError *noAccountsError = [NSError errorWithDomain:DATwitterInstantDomain
                                                   code:DATwitterInstantErrorNoTwitterAccounts
                                               userInfo:nil];
    
    NSError *invalidResponseError = [NSError errorWithDomain:DATwitterInstantDomain
                                                        code:DATwitterInstantErrorInvalidResponse
                                                    userInfo:nil];
    
    // 2 - create the signal block
    
    @weakify(self)
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        @strongify(self)
        
        // 3 - create the request
        SLRequest *request = [self requestForTwitterSearchWithText:text];
        
        // 4 - supply a twitter account
        NSArray *twitterAccounts = [self.accountStore accountsWithAccountType:self.twitterAccountType];
        if (twitterAccounts.count == 0) {
            [subscriber sendError:noAccountsError];
        } else {
            [request setAccount:[twitterAccounts lastObject]];
            
            // 5 - perform the request
            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                if (urlResponse.statusCode == 200) {
                    // 6 - on success parse the response
                    NSDictionary *timelineData = [NSJSONSerialization JSONObjectWithData:responseData
                                                                                 options:NSJSONReadingAllowFragments
                                                                                   error:nil];
                    [subscriber sendNext:timelineData];
                    [subscriber sendCompleted];
                } else {
                    // 7 - on failure send error
                    [subscriber sendError:invalidResponseError];
                }
            }];
        }
        
        return nil;
    }];
}

- (RACSignal *)signalForLoadingImage:(NSString *)imageUrl
{
    RACScheduler *scheduler = [RACScheduler schedulerWithPriority:RACSchedulerPriorityBackground];
    
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]];
        UIImage *image = [UIImage imageWithData:data];
        [subscriber sendNext:image];
        [subscriber sendCompleted];
        return nil;
    }] subscribeOn:scheduler];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tweets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DATableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    DATweet *tweet = self.tweets[indexPath.row];
    cell.statusLabel.text = tweet.status;
    cell.usernameLabel.text = [NSString stringWithFormat:@"@%@", tweet.username];
    
    cell.avatarImageView.image = nil;
    [[[self signalForLoadingImage:tweet.profileImageUrl]
    deliverOn:[RACScheduler mainThreadScheduler]]
    subscribeNext:^(UIImage *image) {
        cell.avatarImageView.image = image;
    }];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

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
