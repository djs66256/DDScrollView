//
//  TDScrollAnimation.m
//  TestDemo
//
//  Created by daniel on 14-8-15.
//  Copyright (c) 2014年 段家顺. All rights reserved.
//

#import "DDScrollAnimation.h"

@implementation DDScrollBaseAnimation

- (CGFloat)floatWithTimeStamp:(NSTimeInterval)timeStamp duration:(NSTimeInterval)duration
{
    _time += duration;
    return 0;
}

- (BOOL)isFinished
{
    return _finished;
}

- (void)invalidate
{
    _finished = YES;
}

@end


static const double kDeceleratingAnimtionDuration = .33;
@implementation DDScrollDeceleratingAnimation

- (instancetype)initWithStart:(CGFloat)start end:(CGFloat)end
{
    return [self initWithStart:start end:end duration:kDeceleratingAnimtionDuration];
}

- (instancetype)initWithStart:(CGFloat)start end:(CGFloat)end duration:(NSTimeInterval)duration
{
    self = [super init];
    if (self) {
        _duration = duration;
        _start = start;
        _end = end;
        _a = 2 * (_end-_start) / (duration*duration);
        _v = _a * duration;
    }
    return self;
}

+ (instancetype)animationWithStart:(CGFloat)start end:(CGFloat)end
{
    return [self animationWithStart:start end:end duration:kDeceleratingAnimtionDuration];
}

+ (instancetype)animationWithStart:(CGFloat)start end:(CGFloat)end duration:(NSTimeInterval)duration
{
    if (fabs(start - end) < 0.5) {
        return nil;
    }
    DDScrollDeceleratingAnimation *anim = [[DDScrollDeceleratingAnimation alloc] initWithStart:start end:end duration:duration];
    return anim;
}

- (CGFloat)floatWithTimeStamp:(NSTimeInterval)timeStamp duration:(NSTimeInterval)duration
{
    if (_finished) {
        return _end;
    }
    
    _time+=duration;
    if (_time > _duration) {
        _finished = YES;
        return _end;
    }
    
    CGFloat p = _v*_time - _a*_time*_time/2 + _start;
    if (fabs(p-_start) > fabs(_end - _start)) {
        _finished = YES;
        return _end;
    }
    
    return p;
}

@end

@implementation DDInertiaAnimation

- (instancetype)initWithStart:(CGFloat)start min:(CGFloat)min max:(CGFloat)max speed:(CGFloat)speed
{
    self = [super init];
    if (self) {
        _start = start;
        _v = -speed;
        _maxAndMin = _v>0 ? MAX(max, min) : MIN(max, min);
        _a = _v>0 ? -1000-_v*0.5 : 1000+_v*0.5;
    }
    return self;
}

+ (instancetype)animationWithStart:(CGFloat)start min:(CGFloat)min max:(CGFloat)max speed:(CGFloat)speed
{
    if (fabs(speed) < 50) {
        return nil;
    }
    DDInertiaAnimation *anim = [[DDInertiaAnimation alloc] initWithStart:start min:min max:max speed:speed];
    return anim;
}

- (CGFloat)floatWithTimeStamp:(NSTimeInterval)timeStamp duration:(NSTimeInterval)duration
{
    if (_finished) {
        return _end;
    }
    
    if (_deceleratingAnimation && !_deceleratingAnimation.isFinished) {
        _end = [_deceleratingAnimation floatWithTimeStamp:timeStamp duration:duration];
        if (_deceleratingAnimation.isFinished) {
            _finished = YES;
        }
        return _end;
    }
    
    _time += duration;
    if (fabs(_v) < fabs(_a*_time)) {
        _finished = YES;
    }
    
    CGFloat p = _v*_time + _a*_time*_time/2;
    
    if (fabs(p) > fabs(_maxAndMin-_start)) {
        _deceleratingAnimation = [DDInertiaDeceleratingAnimation animationWithStart:_maxAndMin speed:_v+_a*_time duration:kDeceleratingAnimtionDuration];
        if (_deceleratingAnimation == nil) {
            _finished = YES;
            return _end;
        }
        _end = [_deceleratingAnimation floatWithTimeStamp:timeStamp duration:duration];
        return _end;
    }
    _end = p + _start;
    return _end;
}

@end


@implementation DDInertiaDeceleratingAnimation

- (instancetype)initWithStart:(CGFloat)start speed:(CGFloat)speed duration:(NSTimeInterval)duration
{
    self = [super init];
    if (self) {
        _duration = duration;
        _start = start;
        CGFloat realSpeed = speed/2;
        _a = -realSpeed / duration;
        _v = realSpeed;
        _midTime = duration * (1-1.414026/2);
    }
    return self;
}

+ (instancetype)animationWithStart:(CGFloat)start speed:(CGFloat)speed duration:(NSTimeInterval)duration
{
    if (fabs(speed) < 100) {
        return nil;
    }
    DDInertiaDeceleratingAnimation *anim = [[DDInertiaDeceleratingAnimation alloc] initWithStart:start speed:speed duration:duration];
    return anim;
}

- (CGFloat)floatWithTimeStamp:(NSTimeInterval)timeStamp duration:(NSTimeInterval)duration
{
    if (_finished) {
        return _start;
    }
    _time += duration;
    
    if (_deceleratingAnimation) {
        _end = [_deceleratingAnimation floatWithTimeStamp:timeStamp duration:duration];
        if (_deceleratingAnimation.isFinished) {
            _finished = YES;
        }
        return _end;
    }
    
    CGFloat p = _v*_time - _a*_time*_time/2;
    _end = p+_start;
    
    if (_time > _midTime) {
        _deceleratingAnimation = [DDScrollDeceleratingAnimation animationWithStart:_end end:_start duration:kDeceleratingAnimtionDuration];
    }
    
    return p+_start;
}

@end