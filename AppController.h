//
//  AppController.h
//  SelectedTrackControl
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <PYMIDI/PYMIDI.h>
#import "HotKey.h"
#import "HotKeyMomentary.h"
#import "HotKeyRepeat.h"
#import "MIDIPacketTimed.h"

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);
OSStatus myHotKeyReleasedHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);

@interface AppController : NSObject {
	PYMIDIVirtualSource* virtualInput;
	PYMIDIVirtualDestination* virtualOutput;
	NSMutableArray *hotkeys;
	NSMutableArray *midiMessages;
	
	BOOL hotkeysBound;
}
- (void) sendMIDIMessage: (int) channel: (int) key: (int) value;//(unsigned char*) message;
- (void) processMIDIPacketList: (MIDIPacketList*)packetList sender:(id)sender;

- (void) hotKeyPressed:(int) hotKeyId;
- (void) hotKeyReleased:(int) hotKeyId;

- (void) checkFrontAppForHotkeys;
- (void) awakeFromNib;
@end
