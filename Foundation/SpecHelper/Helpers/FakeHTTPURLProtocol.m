#import "FakeHTTPURLProtocol.h"
#import "PSHKFakeHTTPURLResponse.h"

@implementation FakeHTTPURLProtocol

static NSMutableArray *currentProtocolInstances_ = nil;

+ (void)beforeEach {
    [currentProtocolInstances_ release];
    currentProtocolInstances_ = [@[] mutableCopy];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [NSURLProtocol registerClass:[FakeHTTPURLProtocol class]];
    });
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
    return [request.URL.scheme isEqualToString:@"http"] || [request.URL.scheme isEqualToString:@"https"];
}

+ (NSArray *)connections {
    return currentProtocolInstances_;
}

+ (FakeHTTPURLProtocol *)connectionForPath:(NSString *)path {
    for (FakeHTTPURLProtocol *protocol in currentProtocolInstances_) {
        if ([protocol.request.URL.path isEqualToString:path]) {
            return protocol;
        }
    }
    return nil;
}

+ (void)resetAll {
    [currentProtocolInstances_ release];
    currentProtocolInstances_ = [@[] mutableCopy];
}

- (void)startLoading {
    
}

- (id)initWithRequest:(NSURLRequest *)request cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client {
    if (self = [super initWithRequest:request cachedResponse:cachedResponse client:client]) {
        [currentProtocolInstances_ addObject:self];
    }
    return self;
}

- (void)receiveResponse:(PSHKFakeHTTPURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageAllowed];
    [self.client URLProtocol:self didLoadData:[response bodyData]];
    [self.client URLProtocolDidFinishLoading:self];
    [currentProtocolInstances_ removeObject:self];
}

- (void)failWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
    [currentProtocolInstances_ removeObject:self];
}

- (void)failWithError:(NSError *)error data:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    [self.client URLProtocol:self didFailWithError:error];
    [currentProtocolInstances_ removeObject:self];
}

@end
