//
//  Status.h
//  iCapture
//
//  Created by Residue on 16/11/12.
//  Copyright (c) 2012 bonemap. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Status : NSObject {
    NSMutableArray* _messages;
}

- (NSString*) text;
- (void) setNextMessage: (NSString*) message;

@end
