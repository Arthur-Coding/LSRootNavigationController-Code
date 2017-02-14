//
//  UINavigationBar+LSMagicNavigationBar.h
//
//  Created by ArthurShuai on 2017/2/9.
//  Copyright © 2017年 ArthurShuai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, kShowType) {
    kShowTypeDissolve,//逐渐隐藏
    kShowTypeFadeIn,//逐渐显示
};

@interface UINavigationBar (LSMagicNavigationBar)

/**
 自定义navigationBar 显示方式

 @param color 自定义导航栏颜色
 @param alpha 起始透明度
 @param distance 极限距离，渐隐时，到此距离完全隐藏，渐显时，到此距离完全显示
 @param type 显示方式
 @param scrollView 滚动视图
 */
- (void)setColor:(UIColor *)color andStartAlpha:(CGFloat)alpha andDistance:(CGFloat)distance andShowType:(kShowType)type andScrollView:(UIScrollView *)scrollView;

@end
