//
//  TDCustomScrollView.m
//  TestDemo
//
//  Created by daniel on 14-8-14.
//  Copyright (c) 2014年 段家顺. All rights reserved.
//

#import "DDCustomScrollView.h"
#import "DDScrollAnimation.h"


#define TransCoefficientOutContent(p) (500/((p)+1000));

@interface DDCustomScrollView ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) DDScrollBaseAnimation *xAnimation;
@property (nonatomic, strong) DDScrollBaseAnimation *yAnimation;

@end

@implementation DDCustomScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _tapGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:_tapGesture];
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _tapGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:_tapGesture];
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (void)setContentOffset:(CGPoint)contentOffset
{
    self.layer.bounds = CGRectMake(contentOffset.x, contentOffset.y, CGRectGetWidth(self.layer.bounds), CGRectGetHeight(self.layer.bounds));
}

- (CGPoint)contentOffset
{
    return CGPointMake(CGRectGetMinX(self.layer.bounds), CGRectGetMinY(self.layer.bounds));
}

- (CGFloat)trans:(CGFloat)trans withCurrent:(CGFloat)p min:(CGFloat)min max:(CGFloat)max
{
    if (p < min) {
        return p - trans*TransCoefficientOutContent(fabs(p-min));
    }
    else if (p > max) {
        return p - trans*TransCoefficientOutContent(fabs(p-max));
    }
    else {
        return p - trans;
    }
}

- (void)transInView:(CGPoint)trans
{
    CGPoint offset = self.contentOffset;
    offset.x = [self trans:trans.x withCurrent:offset.x min:0 max:self.contentSize.width];
    offset.y = [self trans:trans.y withCurrent:offset.y min:0 max:self.contentSize.height];
    self.contentOffset = offset;
}

- (DDScrollBaseAnimation *)animationWhenPanEndWithSpeed:(CGFloat)speed current:(CGFloat)p min:(CGFloat)min max:(CGFloat)max
{
    CGFloat endP = p;
    BOOL needScrollBack = NO;
    if (p < min) {
        needScrollBack = YES;
        endP = min;
    }
    else if (p > max) {
        needScrollBack = YES;
        endP = max;
    }
    
    if (needScrollBack) {
        return [DDScrollDeceleratingAnimation animationWithStart:p end:endP];
    }
    else {
        return [DDInertiaAnimation animationWithStart:p min:min max:max speed:speed];
    }
}

- (void)panEndWithVector:(CGPoint)vector
{
    self.xAnimation = [self animationWhenPanEndWithSpeed:vector.x current:self.contentOffset.x min:0 max:self.contentSize.width-CGRectGetWidth(self.frame)];
    self.yAnimation = [self animationWhenPanEndWithSpeed:vector.y current:self.contentOffset.y min:0 max:self.contentSize.height-CGRectGetHeight(self.frame)];
    [self startAnimation];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    CGPoint trans = [panGesture translationInView:panGesture.view];
    CGPoint vector = [panGesture velocityInView:panGesture.view];
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            _dragging = YES;
            [self stopAnimation];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            [self transInView:trans];
        }
            break;
        case UIGestureRecognizerStateCancelled: {
            _dragging = NO;
            [self stopAnimation];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            _dragging = NO;
            
            [self panEndWithVector:vector];
        }
            break;
        default:
            break;
    }
    
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self stopAnimation];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self panEndWithVector:CGPointZero];
}

#pragma mark - animation
- (void)setDisplayLink:(CADisplayLink *)displayLink
{
    [_displayLink invalidate];
    _displayLink = displayLink;
}

- (void)startAnimation
{
    if (self.xAnimation || self.yAnimation) {
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(handleDisplayLink:)];
        [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)stopAnimation
{
    [_displayLink invalidate];
    self.displayLink = nil;
    self.xAnimation = nil;
    self.yAnimation = nil;
}

- (void)handleDisplayLink:(CADisplayLink *)displayLink
{
    CGPoint offset = self.contentOffset;
    if (self.xAnimation) {
        offset.x = [self.xAnimation floatWithTimeStamp:displayLink.timestamp duration:displayLink.duration];
    }
    if (self.yAnimation) {
        offset.y = [self.yAnimation floatWithTimeStamp:displayLink.timestamp duration:displayLink.duration];
    }
    if (self.xAnimation && self.xAnimation.isFinished) {
        self.xAnimation = nil;
    }
    if (self.yAnimation && self.yAnimation.isFinished) {
        self.yAnimation = nil;
    }
    
    if (self.xAnimation == nil && self.yAnimation == nil) {
        [self stopAnimation];
        return ;
    }
    
    self.contentOffset = offset;
}

@end
