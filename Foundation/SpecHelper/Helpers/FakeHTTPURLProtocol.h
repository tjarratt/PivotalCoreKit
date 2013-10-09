#import <Foundation/Foundation.h>

@class PSHKFakeHTTPURLResponse;

@interface FakeHTTPURLProtocol : NSURLProtocol

+ (void)resetAll;

+ (NSArray *)connections;
+ (FakeHTTPURLProtocol *)connectionForPath:(NSString *)path;

- (void)receiveResponse:(PSHKFakeHTTPURLResponse *)response;

- (void)failWithError:(NSError *)error;
- (void)failWithError:(NSError *)error data:(NSData *)data;
@end
