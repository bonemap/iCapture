//
//  StatusView.m
//  iCapture
//
//  Created by Residue on 17/11/12.
//  Copyright (c) 2012 bonemap. All rights reserved.
//

#import "StatusView.h"

@implementation StatusView

-(void)awakeFromNib {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusUpdated:) name:@"StatusUpdated" object:nil];
}

- (void) statusUpdated: (NSNotification*) notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.text = [notification.userInfo objectForKey:@"messages"];
    });
}

@end
