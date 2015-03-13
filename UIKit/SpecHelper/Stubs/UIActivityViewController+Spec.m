#import "UIActivityViewController+Spec.h"
#import <objc/runtime.h>

@implementation UIActivityViewController (Spec)

- (NSArray *)activityItems {
    return [self valueForKey:@"_activityItems"];
}

- (NSArray *)applicationActivities {
    return [self valueForKey:@"_applicationActivities"];
}

@end
