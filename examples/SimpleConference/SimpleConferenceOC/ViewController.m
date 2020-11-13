//
//  ViewController.m
//  SimpleConferenceOC
//
//  Created by chance.k on 2020/11/10.
//  Copyright © 2020 remote monster. All rights reserved.
//

#import "ViewController.h"
@import RemoteMonster;

// 이 샘플은 iOS SDK 2.7.13 이상 버전에서 정상 동작합니다.
@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIView *content;
@property (strong, nonatomic) RemonConference *remonConference;


@property (strong, nonatomic) NSMutableArray* viewArray;
@property (strong, nonatomic) NSMutableArray* availableViews;

@property (strong, nonatomic) NSError* error;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [RemonClient setAudioSessionConfigurationWithCategory:AVAudioSessionCategoryPlayAndRecord
                                                     mode:AVAudioSessionModeDefault
                                                  options:AVAudioSessionCategoryOptionMixWithOthers
                                                 delegate:self];

    
    
    // swift 샘플과는 다르게 직접 뷰를 구성하는 경우의 예입니다.
    _viewArray = [[NSMutableArray alloc] init];
    _availableViews = [[NSMutableArray alloc] init];
    
    for(int i = 0; i < 6; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [_content addSubview:view];
        [_viewArray addObject:view];
        [_availableViews addObject:[NSNumber numberWithBool:false]];
    }
}

-(void)viewDidLayoutSubviews {
    CGFloat width = self.content.bounds.size.width / 2;
    CGFloat height = self.content.bounds.size.height / 3;
    
    for(int i = 0; i < 6; i++)
    {
        UIView *view = _viewArray[i];
        view.frame = CGRectMake( i%2 * width, i/2 * height, width ,height);
    }
}


-(void)startConference {
    [self hideKeyboard];

    NSString *roomId = _nameField.text;    
    if (roomId.length == 0 ) {
        [self showToast:@"Please enter room name"];
    } else {
        [self joinConferenceWithName:roomId];
    }
}

-(int)getAvailableView {
    if (_availableViews != NULL) {
        for (int i=1;i< [_availableViews count]; i++) {
            if( [_availableViews[i] boolValue] == false) {
                _availableViews[i] = [NSNumber numberWithBool:true];
                return i;
            }
        }
    }
    return 0;
}

-(void)hideKeyboard {
    [self.view endEditing:true];
}

- (IBAction)onLeaveButton:(id)sender {
    [_remonConference leave];
    
    for(int i=0;i<[_availableViews count]; i++) {
        _availableViews[i] = [NSNumber numberWithBool:false];
    }
    
    _remonConference = nil;
}


- (IBAction)onConnectButton:(id)sender {
    [self startConference];
}

- (void)joinConferenceWithName:(NSString*)roomName  {
    _remonConference = [[RemonConference alloc] init];
    
    
    // 공통적으로 사용될 기본 설정
    RemonConfig *config = [[RemonConfig alloc] init];
    config.serviceId = @"SERVICEID1";
    config.key = @"1234567890";
    config.videoWidth = 320;
    config.videoHeight = 240;
    
    // 시뮬레이터의 경우 카메라가 없으므로 대체 재생할 mov 파일을 지정해 줍니다.
    config.videoFilePathForSimulator = @"samples.mov";


    
    RemonConferenceCallbacks *callbacks = [_remonConference createWithRoomName:roomName config:config callback:^(RemonParticipant* participant) {
        // escaping 콜백이 아닙니다.
        participant.localView = _viewArray[0];
        participant.localView.clipsToBounds = true;
        participant.localView.contentMode = UIViewContentModeScaleAspectFill;
        
    }];

    // 제약사항 : callback 설정은 바로 이루어져야 합니다.
    // 다른 쓰레드로 컨텍스트 스위칭이 발생한 이후 콜백을 등록하면 콜백이 정상 등록되지 않을 수 있습니다.
    // objective-c 특성상 체이닝 형태로 작성하는 대신 각 콜백을 각각 정의합니다.
    
    
    [callbacks onEvent:ConferenceEventOnRoomCreated callback:^(RemonParticipant* participant) {
        // 마스터 유저가 접속된 이후에 호출(실제 송출 시작)
        // TODO: 실제 유저 정보는 각 서비스에서 관리하므로, 서비스에서 채널과 실제 유저 매핑 작업 진행

        // tag 객체에 holder 형태로 객체를 지정해 사용할 수 있습니다.
        // 예제에서는 단순히 view의 index를 저장합니다.
        participant.tag = 0;
        
    }];
    
    [callbacks onEvent:ConferenceEventOnUserJoined callback:^(RemonParticipant* participant) {
        // 다른 사용자가 입장한 경우 초기화를 위해 호출됨
        // 초기화와 유저 매핑 등을 위해 호출되는 이벤트로 실제 peer 연결전에 호출됩니다.
        // TODO: 실제 유저 매핑 : participant.id 값으로 연결된 실제 유저를 얻습니다.

        // 뷰 설정
        int index = [self getAvailableView];
        if(index > 0 ) {
            participant.localView = nil;
            participant.remoteView = self->_viewArray[index];
            participant.remoteView.clipsToBounds = true;
            participant.remoteView.contentMode = UIViewContentModeScaleAspectFill;
            participant.tag = [NSNumber numberWithInt:index];
        }
        
        [self showToast: [NSString stringWithFormat:@"%@ has joined", participant.id]];
    }];
    
    [callbacks onEvent:ConferenceEventOnUserStreamConnected callback:^(RemonParticipant* participant) {
        
    }];
    
    [callbacks onEvent:ConferenceEventOnUserLeft callback:^(RemonParticipant* participant) {
        // 다른 사용자가 퇴장한 경우
        // participant.id 와 participant.tag 를 참조해 어떤 사용자가 퇴장했는지 확인후 퇴장 처리를 합니다.
        int index = [((NSNumber*)participant.tag) intValue];
        
        if (index>0) {
            self->_availableViews[index] = [NSNumber numberWithBool:false];
        }

        [self showToast: [NSString stringWithFormat:@"%@ has left", participant.id]];
    }];
    
    [callbacks closeWithCallback:^(){
        // 마스터 유저가 종료된 경우 호출됩니다.
        // 송출이 중단되면 그룹통화에서 끊어진 것이므로, 다른 유저와의 연결도 모두 끊어집니다.
        if( self->_error != nil ) {
            // 에러로 종료됨
        } else {
            // 종료됨
        }

        self.remonConference = nil;
    }];
    
    [callbacks errorWithCallback:^(NSError* error){
        // 마스터유저(송출 채널)의 오류 발생시 호출됩니다.
        // 오류로 연결이 종료되면 error -> close 순으로 호출됩니다.
        self->_error = error;
    }];
    
}


-(void) showToast:(NSString*)message {
    UILabel *toastLabel = [[UILabel alloc] initWithFrame:  CGRectMake( 50, self.view.frame.size.height-100, self.view.frame.size.width - 100, 70)];
    toastLabel.numberOfLines = 2;
    toastLabel.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.6];
    toastLabel.textColor = UIColor.whiteColor;
    toastLabel.textAlignment = NSTextAlignmentCenter;
    toastLabel.font = [UIFont fontWithName: @"Montserrat-Light" size: 10.0];
    toastLabel.text = message;
    toastLabel.alpha = 1.0;
    toastLabel.layer.cornerRadius = 10;
    toastLabel.clipsToBounds  =  true;
    [self.view addSubview:toastLabel];
    

    
    [UIView animateWithDuration:5.0
                          delay:0.1
                        options: UIViewAnimationOptionCurveLinear
                     animations:^(void) {
        toastLabel.alpha = 0.0;
    }
                     completion:^(BOOL completed) {
        
        [toastLabel removeFromSuperview];
    }];
}


-(void)audioSessionDidBeginInterruption:(RTCAudioSession*)session {
    //*********************** 오디오 인터럽트 *********************************
}

-(void)audioSessionDidEndInterruption:(RTCAudioSession*)session shouldResumeSession:(BOOL)shouldResumeSession{
    //*********************** 오디오 인터럽트 종료 *****************************

}

-(void)audioSessionMediaServerTerminated:(RTCAudioSession*)session {
    // ios의 미디어 서버가 종료(초기화 준비 등)
}

-(void)audioSessionMediaServerReset:(RTCAudioSession*)session {
    //*********************** 미디어서버 리셋 *********************************
    // ios의 미디어 서버가 초기화 되었으므로 앱 초기화 필요
    // AVAudioSession 도 다시 설정
    [RemonClient setAudioSessionConfigurationWithCategory:AVAudioSessionCategoryPlayAndRecord
                                                     mode:AVAudioSessionModeDefault
                                                  options:AVAudioSessionCategoryOptionMixWithOthers];
    

}

@end


