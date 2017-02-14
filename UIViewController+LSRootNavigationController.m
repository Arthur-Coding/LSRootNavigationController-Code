//  Copyright © 2017年 ArthurShuai. All rights reserved.
//

#import <objc/runtime.h>

#import "UIViewController+LSRootNavigationController.h"
#import "LSRootNavigationController.h"

@implementation UIViewController (LSRootNavigationController)
@dynamic ls_disableInteractivePop;

- (void)setLs_disableInteractivePop:(BOOL)ls_disableInteractivePop
{
    objc_setAssociatedObject(self, @selector(ls_disableInteractivePop), @(ls_disableInteractivePop), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)ls_disableInteractivePop
{
    return [objc_getAssociatedObject(self, @selector(ls_disableInteractivePop)) boolValue];
}

- (Class)ls_navigationBarClass
{
    return nil;
}

- (LSRootNavigationController *)ls_navigationController
{
    UIViewController *vc = self;
    while (vc && ![vc isKindOfClass:[LSRootNavigationController class]]) {
        vc = vc.navigationController;
    }
    return (LSRootNavigationController *)vc;
}

- (UIBarButtonItem *)customBackItemWithTarget:(id)target
                                       action:(SEL)action
{
    return [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", nil) style:UIBarButtonItemStylePlain target:target action:action];
}

@end
