#import <Foundation/Foundation.h>

@interface DATweet : NSObject

@property (strong, nonatomic) NSString *status;

@property (strong, nonatomic) NSString *profileImageUrl;

@property (strong, nonatomic) NSString *username;

+ (instancetype)tweetWithStatus:(NSDictionary *)status;


@end
