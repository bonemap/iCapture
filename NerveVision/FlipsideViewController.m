//
//  FlipsideViewController.m
//  iCapture
//
//  Created by Residue on 13/11/12.
//  Copyright (c) 2012 bonemap. All rights reserved.
//

#import "FlipsideViewController.h"

static void* FlipsideViewControllerContext = &FlipsideViewControllerContext;

@implementation FlipsideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.networkSwitch.transform = CGAffineTransformMakeScale(1.1, 1.4);
    self.videoCaptureSwitch.transform = CGAffineTransformMakeScale(1.1, 1.4);
    
    // set the title based on the version
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSString *version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *label = [NSString stringWithFormat:@"%@ v%@ (build %@)",
                       name,version,build];
    self.titleItem.title = label;
    // set the state of the switches and the StatusView
    _videoCaptureSwitch.on = _videoOn;
    _statusDisplay.text = _statusMessages;
    _networkSwitch.on = _networkOn;
    
    // reset the service ID text if necessary
    NSString* serviceID = [[NSUserDefaults standardUserDefaults] stringForKey:@"ServiceID"];
    if (![serviceID isEqualToString:@""]) {
        self.serviceIDField.text = serviceID;
    }
    
    // reset the number of swipe gesture touches
    // necessary to show the setup view
    self.segmentedControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"NumberOfSwipeTouches"] - 1;
    self.segmentedControl.selected = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    // save the user defaults
    [[NSUserDefaults standardUserDefaults] setObject:self.serviceIDField.text forKey:@"ServiceID"];
    [[NSUserDefaults standardUserDefaults] setInteger: (self.segmentedControl.selectedSegmentIndex + 1) forKey:@"NumberOfSwipeTouches"];
    
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)segmentedControlPressed:(UISegmentedControl*)sender {
    [self.delegate flipsideViewController:self didSelectSwipeGestureTouches: (sender.selectedSegmentIndex + 1)];
}

- (IBAction)networkSwitchPressed:(UISwitch *)sender {
    if (sender.on) {
        if (_serviceIDField.text.length == 0) {
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Alert"
                                                            message:@"Please enter a the name of the service into the service ID field on this screen." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
            [alert show];
            sender.on = NO;
        } else {
            [_delegate flipsideViewController:self
                           didSwitchOnNetwork:sender.on];
        }
        [_serviceIDField resignFirstResponder];
    } else {
        [_delegate flipsideViewController:self
                       didSwitchOnNetwork:NO];
    }
}

- (IBAction)videoCaptureSwitchPressed:(UISwitch *)sender {
    [_delegate flipsideViewController:self didSwitchOnVideoCapture:sender.on];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
