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
	MIDIController *midiController;
    NSMutableDictionary *hotkeyIdsByKeyCombo;
    
    // event handler ref
    id globalMonitor;
	
	BOOL hotkeysBound;

}

- (void) hotKeyPressed:(int) hotKeyId;
- (void) hotKeyReleased:(int) hotKeyId;

- (void) checkFrontAppForHotkeys;
- (void) awakeFromNib;
@end
