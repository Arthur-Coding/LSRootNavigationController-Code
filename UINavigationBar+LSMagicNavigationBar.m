//
//  UINavigationBar+LSMagicNavigationBar.m
//
//  Created by ArthurShuai on 2017/2/9.
//  Copyright © 2017年 ArthurShuai. All rights reserved.
//

#import <objc/runtime.h>
#import "UINavigationBar+LSMagicNavigationBar.h"

//@interface UIView (ChangeAplha)
//
//- (void)changeSubViewsAlpha:(CGFloat)alpha;
//
//@end
//@implementation UIView (ChangeAplha)
//
//- (void)changeSubViewsAlpha:(CGFloat)alpha {
//    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        obj.alpha = alpha;
//        [obj changeSubViewsAlpha:alpha];
//    }];
//}
//
//@end

@interface UINavigationBar () <UIScrollViewDelegate>

@property (nonatomic, strong) UIView *alphaView;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIColor *navBarColor;

@property (nonatomic, assign) CGFloat distance;

@property (nonatomic, assign) kShowType type;

@property (nonatomic, assign) CGFloat startAlpha;

@end

@implementation UINavigationBar (LSMagicNavigationBar)
- (UIView *)alphaView {
    return objc_getAssociatedObject(self, @selector(alphaView));
}

- (void)setAlphaView:(UIView *)alphaView {
    objc_setAssociatedObject(self, @selector(alphaView), alphaView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScrollView *)scrollView {
    return objc_getAssociatedObject(self, @selector(scrollView));
}

- (void)setScrollView:(UIScrollView *)scrollView {
    objc_setAssociatedObject(self, @selector(scrollView), scrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)navBarColor {
    return objc_getAssociatedObject(self, @selector(navBarColor));
}

- (void)setNavBarColor:(UIColor *)navBarColor {
    objc_setAssociatedObject(self, @selector(navBarColor), navBarColor, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CGFloat)distance {
    return [objc_getAssociatedObject(self, @selector(distance)) floatValue];
}

- (void)setDistance:(CGFloat)distance {
    objc_setAssociatedObject(self, @selector(distance), @(distance), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (kShowType)type {
    return [objc_getAssociatedObject(self, @selector(type)) integerValue];
}
- (void)setType:(kShowType)type {
    objc_setAssociatedObject(self, @selector(type), @(type), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (CGFloat)startAlpha {
    return [objc_getAssociatedObject(self, @selector(startAlpha)) floatValue];
}
- (void)setStartAlpha:(CGFloat)startAlpha {
    objc_setAssociatedObject(self, @selector(startAlpha), @(startAlpha), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setColor:(UIColor *)color andStartAlpha:(CGFloat)alpha andDistance:(CGFloat)distance andShowType:(kShowType)type andScrollView:(UIScrollView *)scrollView {
    self.translucent = YES;
    self.navBarColor = color?color:self.barTintColor;
    self.startAlpha = alpha;
    self.distance = distance;
    self.type = type;
    self.scrollView = scrollView;
    self.scrollView.contentInset = UIEdgeInsetsMake(-64, 0, 0, 0);
    self.scrollView.delegate = self;
    if (self.alphaView) {
        self.alphaView.alpha = alpha;
    }else {
        UIImage *image = [UIImage new];
        [self setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];
        [self setShadowImage:[UIImage new]];
        UIView *alphaView = [[UIView alloc] initWithFrame:CGRectMake(0, -20, [UIScreen mainScreen].bounds.size.width, 64)];
        alphaView.alpha = alpha;
        alphaView.backgroundColor = self.navBarColor;
        [self setAlphaView:alphaView];
        [self insertSubview:alphaView atIndex:0];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat alpha = self.type==kShowTypeDissolve?(1-offsetY/self.distance)*self.startAlpha:self.startAlpha+(offsetY*(1-self.startAlpha))/self.distance;
    if (alpha < 0) {
        alpha = 0;
    }else if (alpha > 1) {
        alpha = 1;
    }
    self.alphaView.alpha = alpha;
//    [self changeSubViewsAlpha:alpha];
    if (offsetY < 0) {// ofsetY小于0，导航栏向上移动
        self.transform = CGAffineTransformMakeTranslation(0, offsetY);
    }
}

@end
