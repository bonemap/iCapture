//
//  FlipsideViewController.h
//  iCapture
//
//  Created by Residue on 13/11/12.
//  Copyright (c) 2012 bonemap. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetworkHandler.h"
#import "ImageCapture.h"

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
- (void)flipsideViewController: (FlipsideViewController*) flipsideViewController didSwitchOnVideoCapture: (BOOL) isOn;
- (void)flipsideViewController: (FlipsideViewController*) flipsideViewController didSwitchOnNetwork: (BOOL) isOn;
- (void) flipsideViewController:(FlipsideViewController *)flipsideViewController didSelectSwipeGestureTouches:(NSInteger)touches;
@end

@interface FlipsideViewController : UIViewController
<UITextFieldDelegate>

@property (weak, nonatomic) id <FlipsideViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITextView *statusDisplay;
@property (weak, nonatomic) IBOutlet UISwitch *videoCaptureSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *networkSwitch;
@property (weak, nonatomic) IBOutlet UITextField *serviceIDField;
@property (weak, nonatomic) IBOutlet UINavigationItem *titleItem;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (assign) BOOL videoOn;
@property (assign) BOOL networkOn;
@property (weak) NSString* statusMessages;

- (IBAction)done:(id)sender;
- (IBAction)segmentedControlPressed:(UISegmentedControl*)sender;
- (IBAction)networkSwitchPressed:(UISwitch *)sender;
- (IBAction)videoCaptureSwitchPressed:(UISwitch *)sender;

@end
