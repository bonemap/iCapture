//
//  MainViewController.h
//  iCapture
//
//  Created by Residue on 13/11/12.
//  Copyright (c) 2012 bonemap. All rights reserved.
//

#import "FlipsideViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "Status.h"
#import "ImageCapture.h"
#import "NetworkHandler.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate> {
    ImageCapture* _imageCapture;
    NetworkHandler* _networkHandler;
    Status* _status;
}
@property (weak, nonatomic) IBOutlet UISwipeGestureRecognizer *swipeGesture;

@property (strong, nonatomic) IBOutlet UIView *previewView;

@end
