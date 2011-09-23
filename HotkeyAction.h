//
//  HotkeyAction.h
//  Kimidi
//

#import <Cocoa/Cocoa.h>
#import "MIDIController.h"


@interface HotkeyAction : NSObject {
	MIDIController *controller;
	
	int channel;
	int key;
	int value;
}
- (void) setController: (MIDIController *) c;
- (void) setChannel: (int) c;
- (void) setKey: (int) k;
- (void) setValue: (int) v;

- (void) pressed;
- (void) released;
- (void) execute;
@end
