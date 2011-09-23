//
//  HotkeyTrigger.h
//  Kimidi
//
//  Created by Richard Schreiber on 18.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
/*
 * HotkeyTrigger registers the keycombo and triggers the HotkeyActions subscribed to it
 */

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "HotkeyAction.h"


@interface HotkeyTrigger : NSObject {
	NSMutableArray *hotkeyActions;
	
	// note: alphaLock cannot be added to keyCombo - this has to be processed inside HotkeyAction
	int keyCode;
	int keyCombo;
	
	EventHotKeyRef hotKeyRef; // needed to unregister the hotkey
	EventHotKeyID hotkeyId; // needed to uniquely address the hotkey pressed
}

- (void) setKeyCode: (int) code;
- (void) setKeyCombo: (int) combo;
- (bool) hasAlphaLock;
- (void) setHotkeyId: (int) i;

// (un)subscribe HotkeyActions
- (void) addAction:(HotkeyAction*) hotkeyAction;
- (void) removeAction:(HotkeyAction*) hotkeyAction;

// (un)register keycombo
- (void) activate;
- (void) deactivate;

// react to keycombo
- (void) pressed;
- (void) released;

@end
