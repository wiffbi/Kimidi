//
//  HotKeyMomentary.m
//  Kimidi
//
//  Created by Richard Schreiber on 29.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//
// implements a Momentary toggle button, so you hold it for a certain time and when released, it triggers again

//#import "HotKey.h"
#import "HotKeyMomentary.h"

@implementation HotKeyMomentary

- (void) released
{
	[super released];
	//NSLog(@"HotKey released");
	//NSLog(timer);
	
	
	if (isHold)
	{
		[self execute];
	}
}

@end
