//
//  AppController.h
//  SelectedTrackControl
//

#import <Cocoa/Cocoa.h>

#import "MIDIController.h"
#import "HotkeyTrigger.h"
#import "HotkeyAction.h"
#import "HotkeyActionRepeat.h"
#import "HotkeyActionRetrigger.h"


@interface AppController : NSObject {
    
	NSMutableArray *hotkeys;
    // indexes to the hotkeys array by keyCombo (keyCode combined with modifier bit flags)
    NSMutableDictionary *hotkeyIdexesByKeyCombo;
    
    // keep track of all currently pressed triggers
    NSMutableSet<HotkeyTrigger*> *pressedTriggers;
    
	MIDIController *midiController;

    
    // event handler ref
    id globalMonitor;
	
	BOOL hotkeysBound;

}

- (void) hotKeyPressed:(int) hotKeyId;
- (void) hotKeyReleased:(int) hotKeyId;

- (void) checkFrontAppForHotkeys;
- (void) awakeFromNib;
@end
