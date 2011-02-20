//
//  HotKey.m
//  Kimidi
//
//  Created by Richard Schreiber on 02.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HotKey.h"
#import "AppController.h"

@implementation HotKey
- (void) setController: (id) c
{
	controller = c;
}
/*
- (void) setMessage: (unsigned char*) m
{
	message = m;
}
*/
- (void) setChannel: (int) c
{
	channel = c;
}
- (void) setKey: (int) k
{
	key = k;
}
- (void) setValue: (int) v
{
	value = v;
}


- (void) pressed
{
	//NSLog(@"HotKey pressed");
	[self execute];
	
	
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
	//NSLog(@"HotKey released");
	//NSLog(timer);
	
	if ([timer isValid])
	{
		[timer invalidate];
		timer = nil;
	}
	
	/*
	if (isHold)
	{
		[self execute];
	}
	*/
}
- (void) execute
{
	NSLog(@"HotKey action");
	//NSLog(@"MIDI-message: %d", message);
	//[controller sendMIDINote:1:127];
	[controller sendMIDIMessage:channel:key:value];
}

- (void) setIsHold
{
	NSLog(@"setIsHold");
	isHold = true;
	timer = nil;
}

@end
