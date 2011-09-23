//
//  HotkeyActionRetrigger.h
//  Kimidi
//

#import <Cocoa/Cocoa.h>
#import "HotkeyAction.h"


@interface HotkeyActionRetrigger : HotkeyAction {
	NSTimer* timer;
	bool isHold;
}

- (void) setIsHold;

@end
