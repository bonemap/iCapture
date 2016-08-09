//
//  ImageCapture.m
//  iCapture
//
//  Created by Residue on 14/11/12.
//  Copyright (c) 2012 bonemap. All rights reserved.
//

#import "ImageCapture.h"

@implementation ImageCapture

- (id) initWithStatus: (Status*) status {
    if ((self = [super init]) != nil) {
        _status = status;
        [self setupCaptureSession];
    }
    return self;
}

- (BOOL) enabled {
    @synchronized (self) {
        return _enabled;
    }
}

- (void) setEnabled:(BOOL)isEnabled {
    @synchronized (self) {
        _enabled = isEnabled;
        if (_enabled) {
            [captureSession startRunning];
            _status.nextMessage = @"capture activated";
        } else {
            [captureSession stopRunning];
            _status.nextMessage = @"capture deactivated";
        }
    }
}

- (void) setupCaptureSession {
    
    // create a captureSession and try to assign video input and input to it
    // assumption: a front-facing camera is available
    captureSession = [AVCaptureSession new];
    captureSession.sessionPreset = AVCaptureSessionPreset352x288;
    
    frontVideoDevice = [self deviceWithMediaType: AVMediaTypeVideo andPosition: AVCaptureDevicePositionFront];
    
    NSError* error;
    frontVideoDeviceInput = [[AVCaptureDeviceInput alloc]
                             initWithDevice:frontVideoDevice error:&error];
    
    if (frontVideoDeviceInput == nil) {
//        NSLog(@"error during setup: %@", error);
        _status.nextMessage = @"could not find front camera";
        return;
    }
    
    if ([captureSession canAddInput:frontVideoDeviceInput]) {
        [captureSession addInput:frontVideoDeviceInput];
    } else {
//        NSLog(@"could not add input device %@",
//              [frontVideoDeviceInput description]);
        _status.nextMessage = @"could not add device input";
        return;
    }
    
    // setup the output frame capture - uses a custom serial queue
    frontVideoDeviceOutput = [AVCaptureVideoDataOutput new];
    frontVideoDeviceOutput.alwaysDiscardsLateVideoFrames = YES;
    frontVideoDeviceOutput.videoSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    videoCaptureQueue = dispatch_queue_create("com.bonemap.queue",
                                              DISPATCH_QUEUE_SERIAL);
    [frontVideoDeviceOutput setSampleBufferDelegate:self
                                              queue: videoCaptureQueue];
    
    if ([captureSession canAddOutput:frontVideoDeviceOutput]) {
        [captureSession addOutput:frontVideoDeviceOutput];
    } else {
//        NSLog(@"could not add output device %@",
//              [frontVideoDeviceOutput description]);
        _status.nextMessage = @"could not add output device";
        return;
    }
    
    // setup the previewlayer to use the captureSession
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    _status.nextMessage = @"video capture setup completed";
}

// find appropriate device matching given media-type and position
- (AVCaptureDevice *) deviceWithMediaType:(NSString *)mediaType
                              andPosition:(int)position {
    
    NSArray *devices = [AVCaptureDevice devices];
    for (AVCaptureDevice *device in devices) {
        if ([device hasMediaType:mediaType]) {
            if ([device position] == position) {
                return device;
            }
        }
    }
    return nil;
}

UIImage *imageFromSampleBuffer(CMSampleBufferRef sampleBuffer) {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer.
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    
    // Get the number of bytes per row for the pixel buffer.
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height.
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space.
    static CGColorSpaceRef colorSpace = NULL;
    if (colorSpace == NULL) {
        colorSpace = CGColorSpaceCreateDeviceRGB();
        if (colorSpace == NULL) {
            // Handle the error appropriately.
            return nil;
        }
    }
    
    // Get the base address of the pixel buffer.
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // Get the data size for contiguous planes of the pixel buffer.
    size_t bufferSize = CVPixelBufferGetDataSize(imageBuffer);
    
    // Create a Quartz direct-access data provider that uses data we supply.
    CGDataProviderRef dataProvider =
    CGDataProviderCreateWithData(NULL, baseAddress, bufferSize, NULL);
    // Create a bitmap image from data supplied by the data provider.
    CGImageRef cgImage =
    CGImageCreate(width, height, 8, 32, bytesPerRow,
                  colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Little,
                  dataProvider, NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    
    // Create and return an image object to represent the Quartz image.
    UIImage *image = [UIImage imageWithCGImage:cgImage];
    CGImageRelease(cgImage);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return image;
}

static BOOL frameRateNeedsSetup = YES;

- (void) captureOutput:(AVCaptureOutput *)captureOutput
 didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
        fromConnection:(AVCaptureConnection *)connection {
    
    @autoreleasepool {
        if (frameRateNeedsSetup) {
            frameRateNeedsSetup = NO;
            connection.videoMinFrameDuration = CMTimeMake(1,12);
            connection.videoMaxFrameDuration = CMTimeMake(1,30);
        }
        
        UIImage* image = imageFromSampleBuffer(sampleBuffer);
        [self sendImageData:UIImageJPEGRepresentation(image, 0.55)];
    }
}

- (void) sendImageData: (NSData*) imageData {
    NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys:imageData,
                          @"imageData", nil];
//    _status.nextMessage = @"sending frame to network handler";
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SendData"
                                                        object:nil
                                                      userInfo:info];
}

@end
