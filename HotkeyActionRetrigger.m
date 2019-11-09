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
	
	
	isHold = false;
	
    timer = [NSTimer scheduledTimerWithTimeInterval:.25
											target:self
                                            selector:@selector(setIsHold)
                                            userInfo:NULL
                                            repeats:NO];
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
	NSLog(@"setIsHold");
	isHold = true;
	timer = nil;
}

@end
