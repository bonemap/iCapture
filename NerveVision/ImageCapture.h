//
//  ImageCapture.h
//  iCapture
//
//  Created by Residue on 14/11/12.
//  Copyright (c) 2012 bonemap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AVFoundation/AVVideoSettings.h>
#import "Status.h"

@interface ImageCapture : NSObject
<AVCaptureVideoDataOutputSampleBufferDelegate> {
    AVCaptureSession* captureSession;
    dispatch_queue_t videoCaptureQueue;
    AVCaptureDevice* frontVideoDevice;
    AVCaptureDeviceInput* frontVideoDeviceInput;
    AVCaptureVideoDataOutput* frontVideoDeviceOutput;
    Status* _status;
    BOOL _enabled;
}

- (id) initWithStatus: (Status*) status;
@property (assign) BOOL enabled;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer* previewLayer;

@end
