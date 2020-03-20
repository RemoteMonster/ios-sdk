//
//  SampleSerchTableViewController.m
//  verySimpleRomen-objc
//
//  Created by lhs on 2018. 9. 11..
//  Copyright © 2018년 Remote Monster. All rights reserved.
//

#import "SimpleSerchTableViewController.h"
#import "SimpleCastViewerViewController.h"

@interface SimpleSerchTableViewController () <UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet RemonCast *remonCast;
@property (weak, nonatomic) IBOutlet UITableView *roomsTableView;
@property (weak, nonatomic) IBOutlet UIButton *reloadButton;
@property NSArray<RemonSearchResult*> *rooms;
@end

@implementation SimpleSerchTableViewController
- (IBAction)reload:(id)sender {
    self.remonCast.serviceId = self.customConfig.serviceId;
    self.remonCast.serviceKey = self.customConfig.key;
    [self.remonCast fetchCastsWithComplete:
                                ^(NSArray<RemonSearchResult *> * _Nullable chs) {
                                    self.rooms = chs;
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                       [self.roomsTableView reloadData];
                                    });
                                }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reload:self.reloadButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.rooms != nil) {
        return self.rooms.count;
    } else {
        return 0;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    RemonSearchResult *item = [self.rooms objectAtIndex:indexPath.row];
    [cell.textLabel setText:item.chId];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    SimpleCastViewerViewController
    SimpleCastViewerViewController *viewerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"SimpleCastViewerViewController"];
    if (viewerVC != nil) {
        RemonSearchResult *item = [self.rooms objectAtIndex:indexPath.row];
        viewerVC.toChId = item.chId;
        viewerVC.customConfig = self.customConfig;
        [self showViewController:viewerVC sender:self];
    }
    
}
@end
