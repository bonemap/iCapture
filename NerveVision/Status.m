//
//  Status.m
//  iCapture
//
//  Created by Residue on 16/11/12.
//  Copyright (c) 2012 bonemap. All rights reserved.
//

#import "Status.h"

@implementation Status

- (id) init {
    
    if ((self = [super init]) != nil) {
        _messages = [NSMutableArray new];
    }
    return self;
}

- (NSString*) text {
    @synchronized (self) {
        NSMutableString* buffer = [NSMutableString new];
        
        for (NSString* message in _messages) {
            [buffer appendFormat:@"%@\n", message];
        }
        
        return buffer;
    }
}

-(void) setNextMessage:(NSString *) message {
    @synchronized (self) {
        
        if (_messages.count > 100) {
            [_messages removeLastObject];
        }
        NSDateFormatter* dateFormater = [NSDateFormatter new];
        dateFormater.dateFormat = @"hh:mm:ss";
        NSString* dateString = [dateFormater stringFromDate:[NSDate date]];
        NSString* timeStampedMessage = [NSString stringWithFormat:@"%@: %@",
                                        dateString,
                                        message];
        [_messages insertObject:timeStampedMessage atIndex:0];
        
        NSDictionary* info = [NSDictionary dictionaryWithObjectsAndKeys: self.text, @"messages", nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"StatusUpdated"
                                                            object:nil
                                                          userInfo:info];
    }
}

@end
