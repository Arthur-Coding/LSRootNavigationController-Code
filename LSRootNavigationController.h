//  Copyright © 2017年 ArthurShuai. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIViewController+LSRootNavigationController.h"


@interface LSContainerController : UIViewController
@property (nonatomic, readonly, strong) __kindof UIViewController *contentViewController;
@end


/**
 *  @class LSContainerNavigationController
 *  @brief This Controller will forward all @a Navigation actions to its containing navigation controller, i.e. @b LSRootNavigationController.
 *  If you are using UITabBarController in your project, it's recommand to wrap it in @b LSRootNavigationController as follows:
 *  @code
tabController.viewControllers = @[[[LSContainerNavigationController alloc] initWithRootViewController:vc1],
                                  [[LSContainerNavigationController alloc] initWithRootViewController:vc2],
                                  [[LSContainerNavigationController alloc] initWithRootViewController:vc3],
                                  [[LSContainerNavigationController alloc] initWithRootViewController:vc4]];
self.window.rootViewController = [[LSRootNavigationController alloc] initWithRootViewControllerNoWrapping:tabController];
 *  @endcode
 */
@interface LSContainerNavigationController : UINavigationController
@end



/*!
 *  @class LSRootNavigationController
 *  @superclass UINavigationController
 *  @coclass LSContainerController
 *  @coclass LSContainerNavigationController
 */
IB_DESIGNABLE
@interface LSRootNavigationController : UINavigationController

/*!
 *  @brief use system original back bar item or custom back bar item returned by
 *  @c -(UIBarButtonItem*)customBackItemWithTarget:action: , default is YES
 *  @warning Set this to @b YES will @b INCREASE memory usage!
 */
@property (nonatomic, assign) IBInspectable BOOL useSystemBackBarButtonItem;

/// Weather each individual navigation bar uses the visual style of root navigation bar. Default is @b YES
@property (nonatomic, assign) IBInspectable BOOL transferNavigationBarAttributes;

/// Set each navigation bar tintColor
@property (nonatomic, strong) IBInspectable UIColor *barItemTintColor;

/*!
 *  @brief use this property instead of @c visibleViewController to get the current visiable content view controller
 */
@property (nonatomic, readonly, strong) UIViewController *ls_visibleViewController;

/*!
 *  @brief use this property instead of @c topViewController to get the content view controller on the stack top
 */
@property (nonatomic, readonly, strong) UIViewController *ls_topViewController;

/*!
 *  @brief use this property to get all the content view controllers;
 */
@property (nonatomic, readonly, strong) NSArray <__kindof UIViewController *> *ls_viewControllers;

/**
 *  Init with a root view controller without wrapping into a navigation controller
 *
 *  @param rootViewController The root view controller
 *
 *  @return new instance
 */
- (instancetype)initWithRootViewControllerNoWrapping:(UIViewController *)rootViewController;

/*!
 *  @brief Remove a content view controller from the stack
 *
 *  @param controller the content view controller
 */
- (void)removeViewController:(UIViewController *)controller NS_REQUIRES_SUPER;
- (void)removeViewController:(UIViewController *)controller animated:(BOOL)flag NS_REQUIRES_SUPER;

/*!
 *  @brief Push a view controller and do sth. when animation is done
 *
 *  @param viewController new view controller
 *  @param animated       use animation or not
 *  @param block          animation complete callback block
 */
- (void)pushViewController:(UIViewController *)viewController
                  animated:(BOOL)animated
                  complete:(void(^)(BOOL finished))block;

/*!
 *  @brief Pop to a specific view controller with a complete handler
 *
 *  @param viewController The view controller to pop  to
 *  @param animated       use animation or not
 *  @param block          complete handler
 *
 *  @return A array of UIViewControllers(content controller) poped from the stack
 */
- (NSArray <__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController
                                                      animated:(BOOL)animated
                                                      complete:(void(^)(BOOL finished))block;

/*!
 *  @brief Pop to root view controller with a complete handler
 *
 *  @param animated use animation or not
 *  @param block    complete handler
 *
 *  @return A array of UIViewControllers(content controller) poped from the stack
 */
- (NSArray <__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated
                                                                  complete:(void(^)(BOOL finished))block;
@end
