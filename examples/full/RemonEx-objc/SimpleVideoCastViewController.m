//
//  SimpleVideoCastViewController.m
//  verySimpleRomen-objc
//
//  Created by lhs on 2018. 9. 11..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

#import "SimpleVideoCastViewController.h"
@import RemoteMonster;

@interface SimpleVideoCastViewController ()

@property (strong, nonatomic) IBOutlet RemonCast *remonCast;
@property (weak, nonatomic) IBOutlet UILabel *channelIdLabel;

@end

@implementation SimpleVideoCastViewController
- (IBAction)closeBroadcast:(id)sender {
    [self.remonCast closeRemon];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.remonCast create:self.customConfig];
    
    [self.remonCast onCreateWithBlock:^(NSString * _Nullable chId) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.channelIdLabel setText:chId];
        });
    }];
    
    [self.remonCast onCloseWithBlock:^(RemonCloseType type){ 
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.channelIdLabel setText:@"Broadcast Closed"];
        });
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.remonCast closeRemon];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
