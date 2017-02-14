//  Copyright © 2017年 ArthurShuai. All rights reserved.
//

#import <objc/runtime.h>

#import "LSRootNavigationController.h"

#import "UIViewController+LSRootNavigationController.h"


@interface NSArray<ObjectType> (LSRootNavigationController)
- (NSArray *)ls_map:(id(^)(ObjectType obj, NSUInteger index))block;
- (BOOL)ls_any:(BOOL(^)(ObjectType obj))block;
@end

@implementation NSArray (LSRootNavigationController)

- (NSArray *)ls_map:(id (^)(id obj, NSUInteger index))block
{
    if (!block) {
        block = ^(id obj, NSUInteger index) {
            return obj;
        };
    }
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.count];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        [array addObject:block(obj, idx)];
    }];
    return [NSArray arrayWithArray:array];
}

- (BOOL)ls_any:(BOOL (^)(id))block
{
    if (!block)
        return NO;
    
    __block BOOL result = NO;
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * stop) {
        if (block(obj)) {
            result = YES;
            *stop = YES;
        }
    }];
    return result;
}

@end


@interface LSContainerController ()
@property (nonatomic, strong) __kindof UIViewController *contentViewController;
@property (nonatomic, strong) UINavigationController *containerNavigationController;

+ (instancetype)containerControllerWithController:(UIViewController *)controller;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)yesOrNo;
+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)yesOrNo
                                backBarButtonItem:(UIBarButtonItem *)backItem
                                        backTitle:(NSString *)backTitle;

- (instancetype)initWithController:(UIViewController *)controller;
- (instancetype)initWithController:(UIViewController *)controller navigationBarClass:(Class)navigationBarClass;

@end


static inline UIViewController *LSSafeUnwrapViewController(UIViewController *controller) {
    if ([controller isKindOfClass:[LSContainerController class]]) {
        return ((LSContainerController *)controller).contentViewController;
    }
    return controller;
}

__attribute((overloadable)) static inline UIViewController *LSSafeWrapViewController(UIViewController *controller,
                                                                                     Class navigationBarClass,
                                                                                     BOOL withPlaceholder,
                                                                                     UIBarButtonItem *backItem,
                                                                                     NSString *backTitle) {
    if (![controller isKindOfClass:[LSContainerController class]]) {
        return [LSContainerController containerControllerWithController:controller
                                                     navigationBarClass:navigationBarClass
                                              withPlaceholderController:withPlaceholder
                                                      backBarButtonItem:backItem
                                                              backTitle:backTitle];
    }
    return controller;
}

__attribute((overloadable)) static inline UIViewController *LSSafeWrapViewController(UIViewController *controller, Class navigationBarClass, BOOL withPlaceholder) {
    if (![controller isKindOfClass:[LSContainerController class]]) {
        return [LSContainerController containerControllerWithController:controller
                                                     navigationBarClass:navigationBarClass
                                              withPlaceholderController:withPlaceholder];
    }
    return controller;
}

__attribute((overloadable)) static inline UIViewController *LSSafeWrapViewController(UIViewController *controller, Class navigationBarClass) {
    return LSSafeWrapViewController(controller, navigationBarClass, NO);
}


@implementation LSContainerController

+ (instancetype)containerControllerWithController:(UIViewController *)controller
{
    return [[self alloc] initWithController:controller];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
{
    return [[self alloc] initWithController:controller
                         navigationBarClass:navigationBarClass];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)yesOrNo
{
    return [[self alloc] initWithController:controller
                         navigationBarClass:navigationBarClass
                  withPlaceholderController:yesOrNo];
}

+ (instancetype)containerControllerWithController:(UIViewController *)controller
                               navigationBarClass:(Class)navigationBarClass
                        withPlaceholderController:(BOOL)yesOrNo
                                backBarButtonItem:(UIBarButtonItem *)backItem
                                        backTitle:(NSString *)backTitle
{
    return [[self alloc] initWithController:controller
                         navigationBarClass:navigationBarClass
                  withPlaceholderController:yesOrNo
                          backBarButtonItem:backItem
                                  backTitle:backTitle];
}

- (instancetype)initWithController:(UIViewController *)controller
                navigationBarClass:(Class)navigationBarClass
         withPlaceholderController:(BOOL)yesOrNo
                 backBarButtonItem:(UIBarButtonItem *)backItem
                         backTitle:(NSString *)backTitle
{
    self = [super init];
    if (self) {
        // not work while push to a hideBottomBar view controller, give up
        /*
         self.edgesForExtendedLayout = UIRectEdgeAll;
         self.extendedLayoutIncludesOpaqueBars = YES;
         self.automaticallyAdjustsScrollViewInsets = NO;
         */
        
        self.contentViewController = controller;
        self.containerNavigationController = [[LSContainerNavigationController alloc] initWithNavigationBarClass:navigationBarClass toolbarClass:nil];
        if (yesOrNo) {
            UIViewController *vc = [UIViewController new];
            vc.title = backTitle;
            vc.navigationItem.backBarButtonItem = backItem;
            self.containerNavigationController.viewControllers = @[vc, controller];
        }
        else
            self.containerNavigationController.viewControllers = @[controller];
        
        [self addChildViewController:self.containerNavigationController];
        [self.containerNavigationController didMoveToParentViewController:self];
    }
    return self;
}

- (instancetype)initWithController:(UIViewController *)controller
                navigationBarClass:(Class)navigationBarClass
         withPlaceholderController:(BOOL)yesOrNo
{
    return [self initWithController:controller
                 navigationBarClass:navigationBarClass
          withPlaceholderController:yesOrNo
                  backBarButtonItem:nil
                          backTitle:nil];
}

- (instancetype)initWithController:(UIViewController *)controller
                navigationBarClass:(Class)navigationBarClass
{
    return [self initWithController:controller
                 navigationBarClass:navigationBarClass
          withPlaceholderController:NO];
}

- (instancetype)initWithController:(UIViewController *)controller
{
    return [self initWithController:controller navigationBarClass:nil];
}

- (instancetype)initWithContentController:(UIViewController *)controller
{
    self = [super init];
    if (self) {
        self.contentViewController = controller;
        [self addChildViewController:self.contentViewController];
        [self.contentViewController didMoveToParentViewController:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if (self.containerNavigationController) {
        self.containerNavigationController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.view addSubview:self.containerNavigationController.view];
        self.containerNavigationController.view.frame = self.view.bounds;
    }
    else {
        self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.contentViewController.view];
        self.contentViewController.view.frame = self.view.bounds;
    }
}

- (BOOL)becomeFirstResponder
{
    return [self.contentViewController becomeFirstResponder];
}

- (BOOL)canBecomeFirstResponder
{
    return [self.contentViewController canBecomeFirstResponder];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.contentViewController preferredStatusBarStyle];
}

- (BOOL)prefersStatusBarHidden
{
    return [self.contentViewController prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return [self.contentViewController preferredStatusBarUpdateAnimation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self.contentViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return self.contentViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.contentViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.contentViewController.preferredInterfaceOrientationForPresentation;
}

- (nullable UIView *)rotatingHeaderView
{
    return self.contentViewController.rotatingHeaderView;
}

- (nullable UIView *)rotatingFooterView
{
    return self.contentViewController.rotatingFooterView;
}


- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action
                                      fromViewController:(UIViewController *)fromViewController
                                              withSender:(id)sender
{
    return [self.contentViewController viewControllerForUnwindSegueAction:action
                                                       fromViewController:fromViewController
                                                               withSender:sender];
}

- (BOOL)hidesBottomBarWhenPushed
{
    return self.contentViewController.hidesBottomBarWhenPushed;
}

- (NSString *)title
{
    return self.contentViewController.title;
}

- (UITabBarItem *)tabBarItem
{
    return self.contentViewController.tabBarItem;
}

@end

@interface UIViewController (LSContainerNavigationController)
@property (nonatomic, assign, readonly) BOOL ls_hasSetInteractivePop;
@end

@implementation UIViewController (LSContainerNavigationController)

- (BOOL)ls_hasSetInteractivePop
{
    return !!objc_getAssociatedObject(self, @selector(ls_disableInteractivePop));
}

@end


@implementation LSContainerNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super initWithNavigationBarClass:rootViewController.ls_navigationBarClass toolbarClass:nil]) {
        [self pushViewController:rootViewController animated:NO];
        // use following way will cause bug
        // self.viewControllers = @[rootViewController];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //self.interactivePopGestureRecognizer.delegate = nil;
    self.interactivePopGestureRecognizer.enabled = NO;
    
    if (self.ls_navigationController.transferNavigationBarAttributes) {
        self.navigationBar.translucent     = self.navigationController.navigationBar.isTranslucent;
        self.navigationBar.tintColor       = self.navigationController.navigationBar.tintColor;
        self.navigationBar.barTintColor    = self.navigationController.navigationBar.barTintColor;
        self.navigationBar.barStyle        = self.navigationController.navigationBar.barStyle;
        self.navigationBar.backgroundColor = self.navigationController.navigationBar.backgroundColor;
        self.navigationBar.titleTextAttributes              = self.navigationController.navigationBar.titleTextAttributes;
        self.navigationBar.shadowImage                      = self.navigationController.navigationBar.shadowImage;
        self.navigationBar.backIndicatorImage               = self.navigationController.navigationBar.backIndicatorImage;
        self.navigationBar.backIndicatorTransitionMaskImage = self.navigationController.navigationBar.backIndicatorTransitionMaskImage;

        [self.navigationBar setBackgroundImage:[self.navigationController.navigationBar backgroundImageForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setTitleVerticalPositionAdjustment:[self.navigationController.navigationBar titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault] forBarMetrics:UIBarMetricsDefault];
    }
    [self.view layoutIfNeeded];
}

- (UITabBarController *)tabBarController
{
    UITabBarController *tabController = [super tabBarController];
    LSRootNavigationController *navigationController = self.ls_navigationController;
    if (tabController) {
        if (navigationController.tabBarController != tabController) {   // Tab is child of Root VC
            return tabController;
        }
        else {
            return !tabController.tabBar.isTranslucent || [navigationController.ls_viewControllers ls_any:^BOOL(__kindof UIViewController *obj) {
                return obj.hidesBottomBarWhenPushed;
            }] ? nil : tabController;
        }
    }
    return nil;
}

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action
                                      fromViewController:(UIViewController *)fromViewController
                                              withSender:(id)sender
{
    if (self.navigationController) {
        return [self.navigationController viewControllerForUnwindSegueAction:action
                                                          fromViewController:self.parentViewController
                                                                  withSender:sender];
    }
    return [super viewControllerForUnwindSegueAction:action
                                  fromViewController:fromViewController
                                          withSender:sender];
}

- (NSArray<UIViewController *> *)allowedChildViewControllersForUnwindingFromSource:(UIStoryboardUnwindSegueSource *)source
{
    if (self.navigationController) {
        return [self.navigationController allowedChildViewControllersForUnwindingFromSource:source];
    }
    return [super allowedChildViewControllersForUnwindingFromSource:source];
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
    if (self.navigationController) {
        [self.navigationController pushViewController:viewController
                                             animated:animated];
    }
    else {
        [super pushViewController:viewController
                         animated:animated];
    }
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if ([self.navigationController respondsToSelector:aSelector])
        return self.navigationController;
    return nil;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    if (self.navigationController)
        return [self.navigationController popViewControllerAnimated:animated];
    return [super popViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    if (self.navigationController)
        return [self.navigationController popToRootViewControllerAnimated:animated];
    return [super popToRootViewControllerAnimated:animated];
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController
                                                     animated:(BOOL)animated
{
    if (self.navigationController)
        return [self.navigationController popToViewController:viewController
                                                     animated:animated];
    return [super popToViewController:viewController
                             animated:animated];
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers animated:(BOOL)animated
{
    if (self.navigationController)
        [self.navigationController setViewControllers:viewControllers
                                             animated:animated];
    else
        [super setViewControllers:viewControllers animated:animated];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    if (self.navigationController)
        self.navigationController.delegate = delegate;
    else
        [super setDelegate:delegate];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [super setNavigationBarHidden:hidden animated:animated];
    if (!self.visibleViewController.ls_hasSetInteractivePop) {
        self.visibleViewController.ls_disableInteractivePop = hidden;
    }
}

@end


@interface LSRootNavigationController () <UINavigationControllerDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, weak) id<UINavigationControllerDelegate> ls_delegate;
@property (nonatomic, copy) void(^animationBlock)(BOOL finished);

@end

@implementation LSRootNavigationController

- (void)setBarItemTintColor:(UIColor *)barItemTintColor {
    _barItemTintColor = barItemTintColor;
    self.navigationBar.tintColor = barItemTintColor;
}

#pragma mark - Methods

- (void)onBack:(id)sender
{
    [self popViewControllerAnimated:YES];
}

- (void)_commonInit
{
    
}

#pragma mark - Overrides

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.viewControllers = [super viewControllers];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithNavigationBarClass:(Class)navigationBarClass
                              toolbarClass:(Class)toolbarClass
{
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    if (self) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    if (self = [super initWithRootViewController:LSSafeWrapViewController(rootViewController, rootViewController.ls_navigationBarClass)]) {
        [self _commonInit];
    }
    return self;
}

- (instancetype)initWithRootViewControllerNoWrapping:(UIViewController *)rootViewController
{
    if (self = [super initWithRootViewController:[[LSContainerController alloc] initWithContentController:rootViewController]]) {
        [self _commonInit];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [super setDelegate:self];
    [super setNavigationBarHidden:YES animated:NO];

    self.useSystemBackBarButtonItem = YES;
    self.transferNavigationBarAttributes = YES;
}

- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action
                                      fromViewController:(UIViewController *)fromViewController
                                              withSender:(id)sender
{
    UIViewController *controller = [super viewControllerForUnwindSegueAction:action
                                                          fromViewController:fromViewController
                                                                  withSender:sender];
    if (!controller) {
        NSInteger index = [self.viewControllers indexOfObject:fromViewController];
        if (index != NSNotFound) {
            for (NSInteger i = index - 1; i >= 0; --i) {
                controller = [self.viewControllers[i] viewControllerForUnwindSegueAction:action
                                                                      fromViewController:fromViewController
                                                                              withSender:sender];
                if (controller)
                    break;
            }
        }
    }
    return controller;
}

- (void)setNavigationBarHidden:(__unused BOOL)hidden
                      animated:(__unused BOOL)animated
{
    // Override to protect
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        UIViewController *currentLast = LSSafeUnwrapViewController(self.viewControllers.lastObject);
        [super pushViewController:LSSafeWrapViewController(viewController,
                                                           viewController.ls_navigationBarClass,
                                                           self.useSystemBackBarButtonItem,
                                                           currentLast.navigationItem.backBarButtonItem,
                                                           currentLast.title)
                         animated:animated];
    }
    else {
        [super pushViewController:LSSafeWrapViewController(viewController, viewController.ls_navigationBarClass)
                         animated:animated];
    }
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    return LSSafeUnwrapViewController([super popViewControllerAnimated:animated]);
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [[super popToRootViewControllerAnimated:animated] ls_map:^id(__kindof UIViewController *obj, NSUInteger index) {
        return LSSafeUnwrapViewController(obj);
    }];
}

- (NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController
                                                     animated:(BOOL)animated
{
    __block UIViewController *controllerToPop = nil;
    [[super viewControllers] enumerateObjectsUsingBlock:^(__kindof UIViewController * obj, NSUInteger idx, BOOL * stop) {
        if (LSSafeUnwrapViewController(obj) == viewController) {
            controllerToPop = obj;
            *stop = YES;
        }
    }];
    if (controllerToPop) {
        return [[super popToViewController:controllerToPop
                                  animated:animated] ls_map:^id(__kindof UIViewController * obj, __unused NSUInteger index) {
            return LSSafeUnwrapViewController(obj);
        }];
    }
    return nil;
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers
                  animated:(BOOL)animated
{
    [super setViewControllers:[viewControllers ls_map:^id(__kindof UIViewController * obj,  NSUInteger index) {
        if (self.useSystemBackBarButtonItem && index > 0) {
            return LSSafeWrapViewController(obj,
                                            obj.ls_navigationBarClass,
                                            self.useSystemBackBarButtonItem,
                                            viewControllers[index - 1].navigationItem.backBarButtonItem,
                                            viewControllers[index - 1].title);
        }
        else
            return LSSafeWrapViewController(obj, obj.ls_navigationBarClass);
    }]
                     animated:animated];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate
{
    self.ls_delegate = delegate;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return [self.topViewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotate
{
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (nullable UIView *)rotatingHeaderView
{
    return self.topViewController.rotatingHeaderView;
}

- (nullable UIView *)rotatingFooterView
{
    return self.topViewController.rotatingFooterView;
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    return [self.ls_delegate respondsToSelector:aSelector];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    return self.ls_delegate;
}

#pragma mark - Public Methods

- (UIViewController *)ls_topViewController
{
    return LSSafeUnwrapViewController([super topViewController]);
}

- (UIViewController *)ls_visibleViewController
{
    return LSSafeUnwrapViewController([super visibleViewController]);
}

- (NSArray <__kindof UIViewController *> *)ls_viewControllers
{
    return [[super viewControllers] ls_map:^id(id obj, __unused NSUInteger index) {
        return LSSafeUnwrapViewController(obj);
    }];
}

- (void)removeViewController:(UIViewController *)controller
{
    [self removeViewController:controller animated:NO];
}

- (void)removeViewController:(UIViewController *)controller animated:(BOOL)flag
{
    NSMutableArray<__kindof UIViewController *> *controllers = [self.viewControllers mutableCopy];
    __block UIViewController *controllerToRemove = nil;
    [controllers enumerateObjectsUsingBlock:^(__kindof UIViewController * obj, NSUInteger idx, BOOL * stop) {
        if (LSSafeUnwrapViewController(obj) == controller) {
            controllerToRemove = obj;
            *stop = YES;
        }
    }];
    if (controllerToRemove) {
        [controllers removeObject:controllerToRemove];
        [super setViewControllers:[NSArray arrayWithArray:controllers] animated:flag];
    }
}

- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                  complete:(void (^)(BOOL))block
{
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    [self pushViewController:viewController
                    animated:animated];
}

- (NSArray <__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController
                                                      animated:(BOOL)animated
                                                      complete:(void (^)(BOOL))block
{
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    NSArray <__kindof UIViewController *> *array = [self popToViewController:viewController
                                                                    animated:animated];
    if (!array.count) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return array;
}

- (NSArray <__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
                                                                  complete:(void (^)(BOOL))block
{
    if (self.animationBlock) {
        self.animationBlock(NO);
    }
    self.animationBlock = block;
    
    NSArray <__kindof UIViewController *> *array = [self popToRootViewControllerAnimated:animated];
    if (!array.count) {
        if (self.animationBlock) {
            self.animationBlock(YES);
            self.animationBlock = nil;
        }
    }
    return array;
}

#pragma mark - UINavigationController Delegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
    if (!isRootVC) {
        viewController = LSSafeUnwrapViewController(viewController);
        if (!self.useSystemBackBarButtonItem && !viewController.navigationItem.leftBarButtonItem) {
            viewController.navigationItem.leftBarButtonItem = [viewController customBackItemWithTarget:self action:@selector(onBack:)];
        }
    }
    
    if ([self.ls_delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)]) {
        [self.ls_delegate navigationController:navigationController
                        willShowViewController:viewController
                                      animated:animated];
    }
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated
{
    BOOL isRootVC = viewController == navigationController.viewControllers.firstObject;
    viewController = LSSafeUnwrapViewController(viewController);
    if (viewController.ls_disableInteractivePop) {
        self.interactivePopGestureRecognizer.delegate = nil;
        self.interactivePopGestureRecognizer.enabled = NO;
    } else {
        self.interactivePopGestureRecognizer.delaysTouchesBegan = YES;
        self.interactivePopGestureRecognizer.delegate = self;
        self.interactivePopGestureRecognizer.enabled = !isRootVC;
    }
    
    [LSRootNavigationController attemptRotationToDeviceOrientation];
    
    if (self.animationBlock) {
        self.animationBlock(YES);
        self.animationBlock = nil;
    }
    
    if ([self.ls_delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)]) {
        [self.ls_delegate navigationController:navigationController
                         didShowViewController:viewController
                                      animated:animated];
    }
}

- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController
{
    
    if ([self.ls_delegate respondsToSelector:@selector(navigationControllerSupportedInterfaceOrientations:)]) {
        return [self.ls_delegate navigationControllerSupportedInterfaceOrientations:navigationController];
    }
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController
{
    
    if ([self.ls_delegate respondsToSelector:@selector(navigationControllerPreferredInterfaceOrientationForPresentation:)]) {
        return [self.ls_delegate navigationControllerPreferredInterfaceOrientationForPresentation:navigationController];
    }
    return UIInterfaceOrientationPortrait;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    if ([self.ls_delegate respondsToSelector:@selector(navigationController:interactionControllerForAnimationController:)]) {
        return [self.ls_delegate navigationController:navigationController
          interactionControllerForAnimationController:animationController];
    }
    return nil;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{
    if ([self.ls_delegate respondsToSelector:@selector(navigationController:animationControllerForOperation:fromViewController:toViewController:)]) {
        return [self.ls_delegate navigationController:navigationController
                      animationControllerForOperation:operation
                                   fromViewController:fromVC
                                     toViewController:toVC];
    }
    return nil;
}



#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return (gestureRecognizer == self.interactivePopGestureRecognizer);
}

@end
