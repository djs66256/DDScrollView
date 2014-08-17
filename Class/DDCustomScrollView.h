//
//  TDCustomScrollView.h
//  TestDemo
//
//  Created by daniel on 14-8-14.
//  Copyright (c) 2014年 段家顺. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DDCustomScrollView : UIView

@property (nonatomic, strong) UIPanGestureRecognizer *tapGesture;

@property (nonatomic, assign, getter=isDragging) BOOL dragging;
@property (nonatomic, assign) CGPoint contentOffset;
@property (nonatomic, assign) CGSize contentSize;

@end
