//  Copyright © 2017年 ArthurShuai. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LSRootNavigationController;

IB_DESIGNABLE
@interface UIViewController (LSRootNavigationController)

/*!
 *  @brief set this property to @b YES to disable interactive pop
 */
@property (nonatomic, assign) IBInspectable BOOL ls_disableInteractivePop;

/*!
 *  @brief @c self\.navigationControlle will get a wrapping @c UINavigationController, use this property to get the real navigation controller
 */
@property (nonatomic, readonly, strong) LSRootNavigationController *ls_navigationController;

/*!
 *  @brief Override this method to provide a custom subclass of @c UINavigationBar, defaults return nil
 *
 *  @return new UINavigationBar class
 */
- (Class)ls_navigationBarClass;

/*!
 *  @brief Override this method to provide a custom back bar item, default is a normal @c UIBarButtonItem with title @b "Back"
 *
 *  @param target the action target
 *  @param action the pop back action
 *
 *  @return a custom UIBarButtonItem
 */
- (UIBarButtonItem *)customBackItemWithTarget:(id)target action:(SEL)action;

@end
