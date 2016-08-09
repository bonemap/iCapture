//
//  NetworkHandler.h
//  iCapture
//
//  Created by Residue on 14/11/12.
//  Copyright (c) 2012 bonemap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"

@interface NetworkHandler : NSObject
<NSNetServiceBrowserDelegate, NSNetServiceDelegate> {
    NSNetServiceBrowser* networkBrowser;
    NSNetService* networkService;
    NSData* serviceAddress;
    Status* _status;
    NSString* _serviceID;
    BOOL _enabled;
    UInt8 frameID;
    int socketID;
}

- (BOOL) enabled;

- (id) initWithStatus: (Status*) status;
- (void) connectWithService: (NSString*) serviceID;
- (void) disconnect;

- (void) sendData: (NSData*) data;

@end
