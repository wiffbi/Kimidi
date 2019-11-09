//
//  AppController.h
//  SelectedTrackControl
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "MIDIController.h"
#import "HotkeyTrigger.h"
#import "HotkeyAction.h"
#import "HotkeyActionRepeat.h"
#import "HotkeyActionRetrigger.h"

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);
OSStatus myHotKeyReleasedHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);

@interface AppController : NSObject {
	NSMutableArray *hotkeys;
	MIDIController *midiController;
    NSMutableDictionary *hotkeyIdsByKeyCombo;
	
	BOOL hotkeysBound;
	
	BOOL alphaLockEnabled;
}
//- (void) sendMIDIMessage: (int) channel: (int) key: (int) value;//(unsigned char*) message;
//- (void) processMIDIPacketList: (MIDIPacketList*)packetList sender:(id)sender;

- (void) hotKeyPressed:(int) hotKeyId;
- (void) hotKeyReleased:(int) hotKeyId;

- (void) setAlphaLock: (BOOL) flag;

- (void) checkFrontAppForHotkeys;
- (void) awakeFromNib;
@end
