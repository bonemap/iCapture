//
//  NetworkHandler.m
//  iCapture
//
//  Created by Residue on 14/11/12.
//  Copyright (c) 2012 bonemap. All rights reserved.
//

#import "NetworkHandler.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <unistd.h>
#include <arpa/inet.h>


@implementation NetworkHandler

- (id) initWithStatus: (Status*) status {
    if ((self = [super init]) != nil) {
        _status = status;
        frameID = 0;

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendData:) name:@"SendData" object:nil];
    }
    return self;
}

- (BOOL) enabled {
    @synchronized (self) {
        return _enabled;
    }
}

- (void)connectWithService:(NSString*) serviceID {
    _enabled = NO;
    _serviceID = serviceID;
    networkBrowser = [NSNetServiceBrowser new];
    networkBrowser.delegate = self;
    [networkBrowser searchForServicesOfType:@"_bonemap._udp."
                                   inDomain:@"local."];
    
    // send the frame
    socketID = socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP);
    
    if (socketID < 0) {
        _status.nextMessage = [NSString stringWithFormat:@"%s\n", strerror(errno)];
    }
}

- (void)disconnect {
    _enabled = NO;
    serviceAddress = nil;
    [networkService stop];
    networkService.delegate = nil;
    networkService = nil;
    
    [networkBrowser stop];
    networkBrowser.delegate = nil;
    networkBrowser = nil;
    _status.nextMessage = @"network deactivated";
    
    close(socketID);
}

- (void)sendData:(NSNotification *) notification {
    if (!self.enabled) return;
    
    NSData* data = [notification.userInfo objectForKey:@"imageData"];
    if (data != nil) {
        const int BUFFER_SIZE = 32*1024;
        
        if (data.length > BUFFER_SIZE) {
//            printf("ignoring frame, too large: %d\n", data.length);
            _status.nextMessage = [NSString stringWithFormat:@"large frame %lu ignore\n",
                                   (unsigned long)data.length];
            return;
        }
//        printf("using frame of size: %d\n", data.length);
        
        UInt8 buffer[BUFFER_SIZE];
        UInt8* bufferPtr = buffer;
        memset(buffer, 0, BUFFER_SIZE);
        
        
        UInt16 dataBytesRemaining = data.length;
        UInt8* dataBytes = (UInt8*) data.bytes;
        const int DATAGRAM_SIZE = 512 * 16;
        for (UInt8 pos = 0; pos < 64/16; ++pos) {
            
            // setup the DGRAM (ID, pos, data)
            bufferPtr[0] = frameID;
            bufferPtr[1] = pos;
            
            for (int i = 0; i < DATAGRAM_SIZE - 2; ++i) {
                if (dataBytesRemaining > 0) {
                    bufferPtr[2 + i] = dataBytes[i];
                    --dataBytesRemaining;
                } else {
                    break;
                }
            }
            
            int retval = (int)sendto(socketID, bufferPtr, DATAGRAM_SIZE, 0, (struct sockaddr*) serviceAddress.bytes, (socklen_t)serviceAddress.length);
            
            if (retval == -1) {
//                printf("error: %s\n", strerror(errno));
                _status.nextMessage = [NSString stringWithFormat:@"%s\n", strerror(errno)];
            }
            
            bufferPtr += DATAGRAM_SIZE;
            dataBytes += DATAGRAM_SIZE - 2;
        }
        
        
//        frameID = (frameID + 1) % 32;
        ++frameID;
    }
}

#pragma mark - network service browsing methods

-(void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)aNetServiceBrowser {
    _status.nextMessage = @"browsing...";
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict {
    _status.nextMessage = @"can't search...";
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
          didFindService:(NSNetService *)aNetService
              moreComing:(BOOL)moreComing {
    
    serviceAddress = nil;
    _status.nextMessage = [NSString stringWithFormat:@"found %@", _serviceID];
    if ([aNetService.name isEqualToString:_serviceID]) {
        _status.nextMessage = [NSString stringWithFormat:@"resolving %@", _serviceID];
        networkService = aNetService;
        networkService.delegate = self;
        [networkService resolveWithTimeout:3];
    } else {
        _status.nextMessage = @"no service found yet...";
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser
         didRemoveService:(NSNetService *)aNetService
               moreComing:(BOOL)moreComing {
    
    _status.nextMessage = [NSString stringWithFormat:@"removed: %@", aNetService.name];
}

-(void)netServiceDidResolveAddress:(NSNetService *) aNetService {
    
    _status.nextMessage = [NSString stringWithFormat: @"resolved addresses: %@", _serviceID];
    
    if (aNetService.addresses.count > 0) {
        _status.nextMessage = @"saving service address";
        serviceAddress = [aNetService.addresses objectAtIndex:0]; // the IP4 socket info
    } else {
        _status.nextMessage = @"no service addresses found";
    }
    
    [networkBrowser stop];
    networkBrowser.delegate = nil;
    networkBrowser = nil;
    _status.nextMessage = @"service discovery completed";
    _enabled = YES;
}

-(void)netServiceDidStop:(NSNetService *)sender {
    _status.nextMessage = @"net service stopped!!!";
}

-(void)netService:(NSNetService *)sender
    didNotResolve:(NSDictionary *)errorDict {
    
    _status.nextMessage = [NSString stringWithFormat: @"could not resolve: %@", errorDict];
}


@end
