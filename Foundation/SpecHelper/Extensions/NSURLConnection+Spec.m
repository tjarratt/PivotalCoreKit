#import "NSURLConnection+Spec.h"
#import "NSObject+MethodRedirection.h"


@interface NSURLConnection (Spec_Private)
- (id)originalInitWithRequest:(NSURLRequest *)request
                     delegate:(id)delegate NS_RETURNS_RETAINED;
- (id)originalInitWithRequest:(NSURLRequest *)request
                     delegate:(id)delegate
             startImmediately:(BOOL)startImmediately NS_RETURNS_RETAINED;
@end


@implementation NSURLConnection (Spec)

+ (void)initialize {
    if (![[NSURLConnection class] respondsToSelector:@selector(originalInitWithRequest:delegate:startImmediately:)]) {
        [NSURLConnection redirectSelector:@selector(initWithRequest:delegate:startImmediately:)
                                       to:@selector(pckInitWithRequest:delegate:startImmediately:)
                            andRenameItTo:@selector(originalInitWithRequest:delegate:startImmediately:)];
        
        [NSURLConnection redirectSelector:@selector(initWithRequest:delegate:)
                                       to:@selector(pckInitWithRequest:delegate:)
                            andRenameItTo:@selector(originalInitWithRequest:delegate:)];
    }
}

- (id)pckInitWithRequest:(NSURLRequest *)request delegate:(id)delegate {
    return [self initWithRequest:request delegate:delegate startImmediately:NO];
}

- (id)pckInitWithRequest:(NSURLRequest *)request delegate:(id)delegate startImmediately:(BOOL)startImmediately {
    if ((self = [self originalInitWithRequest:request delegate:delegate startImmediately:startImmediately])) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate date]];
    }
    return self;
}

@end
