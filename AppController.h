//
//  AppController.h
//  SelectedTrackControl
//
//  Created by Richard Schreiber on 22.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import <PYMIDI/PYMIDI.h>
#import "HotKey.h"
#import "HotKeyMomentary.h"
#import "HotKeyRepeat.h"

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);
OSStatus myHotKeyReleasedHandler(EventHandlerCallRef nextHandler, EventRef anEvent, void *userData);

@interface AppController : NSObject {
	PYMIDIVirtualSource* virtualInput;
	//NSDictionary *hotKeyActions;
	NSMutableArray *hotkeys;
	
	//id hotkey;
	NSString *activeAppName;
	
	BOOL hotkeysBound;
}
- (void) sendMIDIMessage: (int) channel: (int) key: (int) value;//(unsigned char*) message;

//- (void) sendMIDICC: (int) cc: (int) value;
//- (void) sendMIDINote: (int) note: (int) velocity;

- (void) hotKeyPressed:(int) hotKeyId;
- (void) hotKeyReleased:(int) hotKeyId;

- (void) logHotKey;
- (void) appFrontSwitched;
- (void) awakeFromNib;
@end
