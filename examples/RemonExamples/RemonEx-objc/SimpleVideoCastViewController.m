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
    
    [self.remonCast onRemoteVideoSizeChangedWithBlock:^(UIView * _Nullable view, CGSize size) {
        CGFloat videoHeight = size.height;
        CGFloat videoWidth = size.width;
        CGFloat videoRatio = videoWidth / videoHeight;
        
        CGFloat myViewWidth = view.frame.size.width;
        CGFloat myViewHeight = view.frame.size.height;
        CGFloat myViewRatio = myViewWidth / myViewHeight;
        
        if (videoRatio < 1.0) { // 방송 영상이 세로입니다.
            if (myViewRatio < 1.0) { // 시청자 뷰가 세로 입니다.
                CGFloat computedWidth = myViewHeight * videoRatio;
                dispatch_async(dispatch_get_main_queue(), ^{
                    view.frame = CGRectMake(0.0, 0.0, computedWidth, myViewHeight);
                    view.center = self.view.center;
                });
            } else {
                //                    NOOP
            }
        } else {
            //                NOOP
        }
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
