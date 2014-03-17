
#import "DATweet.h"

@implementation DATweet

+ (instancetype)tweetWithStatus:(NSDictionary *)status {
  DATweet *tweet = [DATweet new];
  tweet.status = status[@"text"];
  
  NSDictionary *user = status[@"user"];
  tweet.profileImageUrl = user[@"profile_image_url"];
  tweet.username = user[@"screen_name"];
  return tweet;
}

@end
