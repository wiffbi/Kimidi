//
//  HotkeyActionRepeat.h
//  Kimidi
//

#import <Cocoa/Cocoa.h>
#import "HotkeyAction.h"


@interface HotkeyActionRepeat : HotkeyAction {
	NSTimer* timer;
}
- (void) executeRepeated;
@end
