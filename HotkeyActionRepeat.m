//
//  HotkeyActionRepeat.m
//  Kimidi
//

#import "HotkeyActionRepeat.h"


@implementation HotkeyActionRepeat

- (void) pressed
{
	[super pressed];
	// wait 400ms before triggering action repeatedly
    timer = [NSTimer scheduledTimerWithTimeInterval:.4
											target:self
                                            selector:@selector(startRepeated)
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
}
- (void) startRepeated
{
	// repeat action every 100ms
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
