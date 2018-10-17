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

@implementation SimpleCallViewController

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
    
    for (UIView * view in self.view.subviews) {
        if (view.tag == 999) {
            self.remonCall.localView = view;
        }
    }
    
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

    }];
    
    [self.remonCall onCloseWithBlock:^(RemonCloseType type){
        NSLog(@"zzzz %ld" , type);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.boxView setHidden:NO];
            [self.closeButton setEnabled:NO];
            [self.ChannelIdLabel setText:@"connection closed"];
            [self.statusLabel setText:@"CLOSE"];
        });
    }];
    
    [self.remonCall onRemonStatReportWithBlock:^(RemonStatReport * _Nonnull stat) {
        RatingValue *remonRating = [stat getHealthRating];
        NSLog(@"xxxxx %f" , remonRating.value);
        
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
