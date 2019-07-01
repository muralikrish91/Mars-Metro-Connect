//
//  MetroiPhoneOutputViewController.m
//  Mars Metro Connect
//
//  Created by Murali Krishnan Govindarajulu on 10/25/15.
//  Copyright © 2015 EasyMetro. All rights reserved.
//

#import "MetroiPhoneOutputViewController.h"

@interface MetroiPhoneOutputViewController ()
@property (strong, nonatomic) IBOutlet UITextView *outputTextView;

@end

@implementation MetroiPhoneOutputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.outputTextView.text=self.routeDetails;
    [_outputTextView setFont:[UIFont systemFontOfSize:18]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
