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
@property (weak, nonatomic) IBOutlet UILabel *fpsLabel;
@property BOOL tryRejoin;

@end

@implementation SimpleCastViewerViewController

- (IBAction)closeRemon:(id)sender {
    [self.remonCast closeRemon];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.remonCast setUserMeta:@"userMeta"];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.toChId != nil) {
        [self.remonCast joinWithChId:self.toChId AndConfig:self.customConfig];
    }
    
    [self.remonCast onJoinWithBlock:^(NSString * _Nullable chId) {
        self.tryRejoin = YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.channelLabel setText:chId];
            [self.remonCast setShowRemoteVideoStat:YES];
        });
        
        @try {
            NSError *error = nil;
            [AVAudioSession.sharedInstance setCategory:AVAudioSessionCategoryPlayback mode:AVAudioSessionModeDefault options:AVAudioSessionCategoryOptionInterruptSpokenAudioAndMixWithOthers error:&error];
            [AVAudioSession.sharedInstance setActive:YES error:&error];
            [AVAudioSession.sharedInstance overrideOutputAudioPort:AVAudioSessionPortOverrideSpeaker error:&error];
        } @catch (NSException *exception) {
            NSLog(@"error is %@",[exception description]);
        }
    }];
    
    [self.remonCast onObjcErrorWithBlock:^(NSError * _Nonnull error) {
        NSLog(@"onObjcError %@", error.localizedDescription);
        if (error.code == 912) {
            //912는 WEBSOCKET 에러로 wifi->cell 로 변경시 912 에러가 발생 하는 것으로 확인 되었습니다.
            self.tryRejoin = YES;
//            [self.remonCast closeRemon];
        }
    }];
    
    [self.remonCast onCloseWithBlock:^(enum RemonCloseType type) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *chid = self.channelLabel.text;
            if (self.tryRejoin && chid) {
                self.tryRejoin = NO;
//                [self.remonCast joinWithChId:chid];
            }
        });
    }];
    

    [self.remonCast onRemonStatReportWithBlock:^(RemonStatReport * _Nonnull stat) {
        NSLog(@"remonStat.remoteFrameRate %ld", [stat remoteFrameRate]);
        
        NSLog(@"[self.remonCast getCurruntStateString] %@", [self.remonCast getCurruntStateString]);
        if ([[self.remonCast getCurruntStateString] isEqualToString:@"COMPLETE"]) {
                    [self.remonCast switchCamera];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.fpsLabel setText:[NSString stringWithFormat:@"%ld", [stat remoteFrameRate]]];
        });
        
        if ( [stat remoteFrameRate] == 0 ) {
            NSLog(@"Remote frame rate is zero");
        }
        
        if ( [stat localFrameRate] == 0 ) {
            NSLog(@"Local frame rate is zero");
        }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.remonCast closeRemon];
}

@end
