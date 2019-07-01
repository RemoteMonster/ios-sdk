//
//  ViewController.m
//  verySimpleRomen-objc
//
//  Created by lhs on 2018. 9. 11..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

#import "objc_ConfigViewController.h"
@import RemoteMonster;

#import "SimpleCallViewController.h"
#import "SimpleSerchTableViewController.h"
#import "SimpleVideoCastViewController.h"

@interface objc_ConfigViewController ()
@property (weak, nonatomic) IBOutlet UITextField *serviceIdField;
@property (weak, nonatomic) IBOutlet UITextField *serviceKeyField;
@property (weak, nonatomic) IBOutlet UITextField *codecField;
@property (weak, nonatomic) IBOutlet UITextField *videoWidthField;
@property (weak, nonatomic) IBOutlet UITextField *videoHeightField;
@property (weak, nonatomic) IBOutlet UITextField *videoFpsField;

@property (weak, nonatomic) IBOutlet UISegmentedControl *channelTypeSegmentedController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *autoCaptureStartSegmentedController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *videoCallSegmentedController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *useFrontCameraSegmentedController;
@property (weak, nonatomic) IBOutlet UISegmentedControl *debugModeSegmentedController;

@property (strong, nonatomic) RemonConfig *remonConfig;

@end

@implementation objc_ConfigViewController

- (IBAction)hidenKeyboard:(id)sender {
    
}

- (IBAction)next:(id)sender {
    AudioServicesPlaySystemSound(1013);
//    self.remonConfig.serviceId = [self fieldText:self.serviceIdField];
//    self.remonConfig.key = [self fieldText:self.serviceKeyField];
    self.remonConfig.serviceId = [self fieldText:self.serviceIdField];
    self.remonConfig.key = [self fieldText:self.serviceKeyField];
    self.remonConfig.videoCodec = [self fieldText:self.codecField];
    self.remonConfig.videoWidth = [[self fieldText:self.videoWidthField] integerValue];
    self.remonConfig.videoHeight = [[self fieldText:self.videoHeightField] integerValue];
    self.remonConfig.videoFps = [[self fieldText:self.videoFpsField] integerValue];
    
    NSInteger chType = self.channelTypeSegmentedController.selectedSegmentIndex;
    switch (chType) {
    case 0:
            self.remonConfig.channelType = RemonChannelTypeP2p;
            break;
    case 1:
            self.remonConfig.channelType = RemonChannelTypeViewer;
            break;
    case 2:
            self.remonConfig.channelType = RemonChannelTypeBroadcast;
            break;
    default:
            self.remonConfig.channelType = RemonChannelTypeP2p;
            break;
    }
    
    self.remonConfig.restUrl = @"https://signal.remotemonster.com/rest/init";
    self.remonConfig.wsUrl = @"wss://signal.remotemonster.com/ws";
    
    self.remonConfig.autoCaptureStart = self.autoCaptureStartSegmentedController.selectedSegmentIndex == 0;
    self.remonConfig.videoCall = self.videoCallSegmentedController.selectedSegmentIndex == 0;
    self.remonConfig.useFrontCamera = self.useFrontCameraSegmentedController.selectedSegmentIndex == 0;
    self.remonConfig.debugMode = self.debugModeSegmentedController.selectedSegmentIndex == 0;
    
    if (self.remonConfig.channelType == RemonChannelTypeP2p) {
        SimpleCallViewController *callVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SimpleCallViewController"];
        if (callVC != nil) {
            callVC.customConfig = self.remonConfig;
            [self showViewController:callVC sender:self];
        }
    } else if (self.remonConfig.channelType == RemonChannelTypeBroadcast) {
        SimpleVideoCastViewController *castVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SimpleVideoCastViewController"];
        if (castVC != nil) {
            castVC.customConfig = self.remonConfig;
            [self showViewController:castVC sender:self];
        }
    } else {
        SimpleSerchTableViewController *searchVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SimpleSerchTableViewController"];
        if (searchVC != nil) {
            searchVC.customConfig = self.remonConfig;
            [self showViewController:searchVC sender:self];
        }
    }
}

- (NSString *)fieldText:(UITextField *)field {
    if (field.text != nil) {
        return field.text;
    } else {
        return @"";
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.remonConfig = [RemonConfig new];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
