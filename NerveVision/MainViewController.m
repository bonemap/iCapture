//
//  MainViewController.m
//  iCapture
//
//  Created by Residue on 13/11/12.
//  Copyright (c) 2012 bonemap. All rights reserved.
//

#import "MainViewController.h"

@implementation MainViewController

static BOOL firstTime = YES;

- (void)viewDidLoad
{
    [super viewDidLoad];

	// additional setup after loading the view, typically from a nib.
    _status = [Status new];
    
    _imageCapture = [[ImageCapture alloc] initWithStatus:_status];
    _imageCapture.previewLayer.frame = _previewView.bounds;
    [_previewView.layer addSublayer:_imageCapture.previewLayer];

    _imageCapture.enabled = YES;
    
    _networkHandler = [[NetworkHandler alloc] initWithStatus:_status];
    
    self.swipeGesture.numberOfTouchesRequired = [[NSUserDefaults standardUserDefaults] integerForKey:@"NumberOfSwipeTouches"];
}

- (void)viewDidAppear:(BOOL)animated {
    if (firstTime) {
        firstTime = NO;
        [self performSegueWithIdentifier:@"showSetup" sender:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Flipside View

-(void)flipsideViewController:(FlipsideViewController *)flipsideViewController
      didSwitchOnVideoCapture:(BOOL)isOn {
    _imageCapture.enabled = isOn;
}

- (void)flipsideViewController:(FlipsideViewController *)flipsideViewController
            didSwitchOnNetwork:(BOOL)isOn {
    if (isOn) {
        [_networkHandler connectWithService:flipsideViewController.serviceIDField.text];
    } else {
        [_networkHandler disconnect];
    }
}

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)flipsideViewController:(FlipsideViewController *)flipsideViewController didSelectSwipeGestureTouches:(NSInteger)touches {
    
    self.swipeGesture.numberOfTouchesRequired = touches;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showSetup"]) {
        FlipsideViewController* flipsideVC = [segue destinationViewController];
        flipsideVC.delegate = self;
        flipsideVC.videoOn = _imageCapture.enabled;
        flipsideVC.networkOn = _networkHandler.enabled;
        flipsideVC.statusMessages = _status.text;
    }
}

@end
