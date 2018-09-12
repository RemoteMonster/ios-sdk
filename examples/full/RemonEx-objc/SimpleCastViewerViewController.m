//
//  SimpleCastViewerViewController.m
//  verySimpleRomen-objc
//
//  Created by lhs on 2018. 9. 11..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

#import "SimpleCastViewerViewController.h"

@interface SimpleCastViewerViewController ()
@property (strong, nonatomic) IBOutlet RemonCast *remonCast;
@property (weak, nonatomic) IBOutlet UILabel *channelLabel;

@end

@implementation SimpleCastViewerViewController
- (IBAction)closeRemon:(id)sender {
    [self.remonCast closeRemon:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.toChId != nil) {
        [self.remonCast joinWithChId:self.toChId AndConfig:self.customConfig];
    }
    
    [self.remonCast onJoinWithBlock:^(NSString * _Nullable chId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.channelLabel setText:chId];
        });
    }];
    
    [self.remonCast onRemonStatReportWithBlock:^(RemonStatReport * _Nonnull stat) {
        
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.remonCast closeRemon:YES];
    
}

@end
