//
//  TDScrollAnimation.h
//  TestDemo
//
//  Created by daniel on 14-8-15.
//  Copyright (c) 2014年 段家顺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDScrollBaseAnimation : NSObject {
    BOOL _finished;
    NSTimeInterval _time;
}
@property (nonatomic, readonly) BOOL isFinished;
- (CGFloat)floatWithTimeStamp:(NSTimeInterval)timeStamp duration:(NSTimeInterval)duration;
- (void)invalidate;

@end

// 弹性效果，模拟摩擦力效果
@interface DDScrollDeceleratingAnimation : DDScrollBaseAnimation {
    CGFloat _start;
    CGFloat _end;
    double _a, _v;
    NSTimeInterval _duration;
}

+ (instancetype)animationWithStart:(CGFloat)start end:(CGFloat)end;
+ (instancetype)animationWithStart:(CGFloat)start end:(CGFloat)end duration:(NSTimeInterval)duration;

@end


// 惯性效果
@class DDInertiaDeceleratingAnimation;
@interface DDInertiaAnimation : DDScrollBaseAnimation {
    CGFloat _start;
    CGFloat _end;
    CGFloat _maxAndMin;
    double _a, _v;
    DDInertiaDeceleratingAnimation *_deceleratingAnimation;
}

+ (instancetype)animationWithStart:(CGFloat)start min:(CGFloat)min max:(CGFloat)max speed:(CGFloat)speed;

@end


// 惯性效果碰撞后的弹性效果
@interface DDInertiaDeceleratingAnimation : DDScrollBaseAnimation {
    CGFloat _start, _end;
    double _v, _a;
    NSTimeInterval _midTime;
    NSTimeInterval _duration;
    DDScrollDeceleratingAnimation *_deceleratingAnimation;
}

+ (instancetype)animationWithStart:(CGFloat)start speed:(CGFloat)speed duration:(NSTimeInterval)duration;;

@end
