//
//  FirstViewController.m
//  DDScrollView
//
//  Created by daniel on 14-8-17.
//  Copyright (c) 2014年 daniel. All rights reserved.
//

#import "FirstViewController.h"
#import "DDCustomScrollView.h"

@interface FirstViewController ()
@property (nonatomic, strong) DDCustomScrollView *scrollView;
@end

@implementation FirstViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [[DDCustomScrollView alloc] initWithFrame:CGRectMake(20, 20, CGRectGetWidth(self.view.frame) - 40, CGRectGetHeight(self.view.frame) - 40 - 44)];
    [self.view addSubview:self.scrollView];
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width*3, CGRectGetHeight(self.scrollView.frame)*3);
    
    for (int i=0; i<self.scrollView.contentSize.width-100; i+=100) {
        for (int j=0; j<self.scrollView.contentSize.height-50; j+=50) {
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(i, j, 100, 50)];
            l.text = [NSString stringWithFormat:@"R%d C%d", i, j];
            [self.scrollView addSubview:l];
        }
    }
    self.scrollView.layer.borderWidth = 1;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
