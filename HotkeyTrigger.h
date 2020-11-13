//
//  HotkeyTrigger.h
//  Kimidi
//
//  Created by Richard Schreiber on 18.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//  
//
/*
 * HotkeyTrigger registers the keycombo and triggers the HotkeyActions subscribed to it
 */

#import <Cocoa/Cocoa.h>

#import "HotkeyAction.h"


// We no longer use Carbon API, but for now I keep the bit-flags from Carbon API
//
typedef UInt16                          EventModifiers;
enum {
                                        /* modifiers */
  activeFlagBit                 = 0,    /* activate? (activateEvt and mouseDown)*/
  btnStateBit                   = 7,    /* state of button?*/
  cmdKeyBit                     = 8,    /* command key down?*/
  shiftKeyBit                   = 9,    /* shift key down?*/
  alphaLockBit                  = 10,   /* alpha lock down?*/
  optionKeyBit                  = 11,   /* option key down?*/
  controlKeyBit                 = 12,   /* control key down?*/
  rightShiftKeyBit              = 13,   /* right shift key down? Not supported on Mac OS X.*/
  rightOptionKeyBit             = 14,   /* right Option key down? Not supported on Mac OS X.*/
  rightControlKeyBit            = 15    /* right Control key down? Not supported on Mac OS X.*/
};

enum {
  activeFlag                    = 1 << activeFlagBit,
  btnState                      = 1 << btnStateBit,
  cmdKey                        = 1 << cmdKeyBit,
  shiftKey                      = 1 << shiftKeyBit,
  alphaLock                     = 1 << alphaLockBit,
  optionKey                     = 1 << optionKeyBit,
  controlKey                    = 1 << controlKeyBit,
  rightShiftKey                 = 1 << rightShiftKeyBit, /* Not supported on Mac OS X.*/
  rightOptionKey                = 1 << rightOptionKeyBit, /* Not supported on Mac OS X.*/
  rightControlKey               = 1 << rightControlKeyBit /* Not supported on Mac OS X.*/
};
// end Carbon

@interface HotkeyTrigger : NSObject {
	NSMutableArray *hotkeyActions;
	
	// note: alphaLock cannot be added to keyCombo - this has to be processed inside HotkeyAction
	int keyCode;
	int keyCombo;
    
    int hotkeyId;
	
	bool active;
	
    bool pressed;
}

- (void) setKeyCode: (int) code;
- (int) keyCode;
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
