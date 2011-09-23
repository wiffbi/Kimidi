//
//  HotkeyActionRetrigger.m
//  Kimidi
//
// implements a momentary toggle button, so you hold it for a certain time and when released, it triggers again


#import "HotkeyActionRetrigger.h"

@implementation HotkeyActionRetrigger

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
		[super released];
	}
}

- (void) setIsHold
{
	//NSLog(@"setIsHold");
	isHold = true;
	timer = nil;
}

@end
