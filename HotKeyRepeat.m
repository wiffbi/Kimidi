//
//  HotKeyRepeat.m
//  Kimidi
//
//  Created by Studio on 14.05.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import "HotKeyRepeat.h"


@implementation HotKeyRepeat

- (void) pressed
{
	[super pressed];
	
	
	/*
	[timer invalidate];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1
											target:self
                                            selector:@selector(execute)
                                            userInfo:NULL
                                            repeats:YES];
	*/
	//isHold = false;
	//timer = [[NSTimer alloc] init];
    timer = [NSTimer scheduledTimerWithTimeInterval:.4
											target:self
                                            selector:@selector(startRepeated)
                                            userInfo:NULL
                                            repeats:NO];
	//[timer invalidate];
	//timer = nil;
}

- (void) released
{
	[super released];
	
	if ([timer isValid])
	{
		[timer invalidate];
		timer = nil;
	}
}
- (void) startRepeated
{
    timer = [NSTimer scheduledTimerWithTimeInterval:.1
											target:self
                                            selector:@selector(executeRepeated)
                                            userInfo:NULL
                                            repeats:YES];
}

- (void) executeRepeated
{
	[super released];
	[super execute];
}

@end
