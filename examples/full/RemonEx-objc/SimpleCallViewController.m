//
//  SimpleCallViewController.m
//  verySimpleRomen-objc
//
//  Created by lhs on 2018. 9. 11..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

#import "SimpleCallViewController.h"

@interface SimpleCallViewController ()
@property (weak, nonatomic) IBOutlet UILabel *ChannelIdLabel;
@property (weak, nonatomic) IBOutlet UITextField *ChannelIdField;
@property (weak, nonatomic) IBOutlet UIView *boxView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) IBOutlet RemonCall *remonCall;
@end

BOOL muted = NO;
@implementation SimpleCallViewController

- (IBAction)volumeRatioP:(id)sender {
    [self.remonCall setVolumeRatio:self.remonCall.volumeRatio + 0.1];
}

- (IBAction)volumeRatioM:(id)sender {
    [self.remonCall setVolumeRatio:self.remonCall.volumeRatio - 0.1];
}

- (IBAction)muteLocalAudio:(id)sender {
    [self.remonCall muteLocalAudioWithMute:!muted];
    muted = !muted;
}

- (IBAction)connectChannel:(id)sender {
    NSString *chId = self.ChannelIdField.text;
    if (chId == nil || chId.length == 0) {
        NSInteger rand = arc4random_uniform(9999);
        chId = [NSString stringWithFormat:@"%ld", (long)rand];
    }
    
    [self.remonCall connect:chId :self.customConfig];
}

- (IBAction)closeRemon:(id)sender {
    [self.remonCall closeRemon];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self.remonCall onInitWithBlock:^{
        [self.statusLabel setText:@"INIT"];
    }];
    
    [self.remonCall onConnectWithBlock:^(NSString * _Nullable chId) {
        [self.statusLabel setText:@"CONNECT"];
        if (chId != nil) {
            [self.closeButton setEnabled:YES];
            [self.ChannelIdLabel setText:chId];
        } else {
            [self.ChannelIdLabel setText:@"connection failed"];
        }
    }];
    
    [self.remonCall onCompleteWithBlock:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.statusLabel setText:@"COMPLETE"];
            [self.closeButton setEnabled:YES];
            [self.ChannelIdLabel setText:self.remonCall.channelID];
            [self.ChannelIdField setText:@""];
            [self.boxView setHidden:YES];
        });
        
        //덤프 기록 시작
//        [self.remonCall startDumpWithFileName:@"audio.aecdump" maxSizeInBytes:1000 * 1024* 1024];
    }];
    
    [self.remonCall onCloseWithBlock:^(RemonCloseType type){
        NSLog(@"zzzz %ld" , type);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.boxView setHidden:NO];
            [self.closeButton setEnabled:NO];
            [self.ChannelIdLabel setText:@"connection closed"];
            [self.statusLabel setText:@"CLOSE"];
        });
        
        //덤프 기록 중지
        //onClose()에서 하셔도 되고, 별도의 이벤트에서 하셔도 됩니다.
        [self.remonCall stopDump];
        
        //덤프 파일을 m4a 형식으로 인코딩 하는 메소드 입니다.
        //이 과정은 시간이 소요 됩니다. onClose()에서 하셔도 되고, 덤프 파일 위치만 알고 있다면 별도의 이벤트에서 하셔도 됩니다.
//        [RemonCall unpackAecDumpWithDumpName:@"audio.aecdump" resultFileName:@"unpack.m4a" progress:^(NSError * _Nullable erro, enum REMON_AECUNPACK_STATE state) {
//        }];
        
//        [RemonCall unpackAecDumpWithDumpName:@"audio.aecdump" resultFileName:@"unpack.m4a" avPreset:REMON_AECUNPACK_PRESETMP4MEDIUM progress:^(NSError * _Nullable erro, enum REMON_AECUNPACK_STATE state) {
//            
//        }];
    }];
    
    [self.remonCall onRemonStatReportWithBlock:^(RemonStatReport * _Nonnull stat) {
        RatingValue *remonRating = [stat getHealthRating];
    }];
    
    [self.remonCall onRemoteVideoSizeChangedWithBlock:^(UIView * _Nullable view, CGSize size) {
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
    [self.remonCall closeRemon];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
