//
//  HotKeyMomentary.m
//  Kimidi
//
//  Created by Richard Schreiber on 29.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
// implements a Momentary toggle button, so you hold it for a certain time and when released, it triggers again


#import "AppController.h"
//#import "HotKey.h"
#import "HotKeyMomentary.h"

@implementation HotKeyMomentary

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
	isHold = false;
	//timer = [[NSTimer alloc] init];
    timer = [NSTimer scheduledTimerWithTimeInterval:.25
											target:self
                                            selector:@selector(setIsHold)
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
	
	
	if (isHold)
	{
		[self execute];
		if (channel == 0x90 | 0)
		{
			// send note off event
			[controller sendMIDIMessage:0x80:key:0];
		}
	}
}

- (void) setIsHold
{
	//NSLog(@"setIsHold");
	isHold = true;
	timer = nil;
}

@end
