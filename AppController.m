//
//  AppController.m
//  SelectedTrackControl
//

#import "AppController.h"
//#import <Carbon/Carbon.h>
//#import <CoreServices/CoreServices.h>

//#import <CoreAudio/HostTime.h>
//#import <PYMIDI/PYMIDI.h>


// How to monitor modifier key-state globally
// http://stackoverflow.com/questions/1603030/how-to-monitor-global-modifier-key-state-in-any-application
CGEventRef keyUpCallback (CGEventTapProxy proxy, CGEventType type, CGEventRef event, void* refcon)
{
	AppController *app = (AppController *)refcon;
	if (type == kCGEventFlagsChanged)
	{
		CGEventFlags newFlags = CGEventGetFlags(event);
		//NSLog(@"%d", newFlags);
		//NSLog(@"flags: 0x%llX",newFlags & kCGEventFlagMaskAlphaShift);
		// setAlphLock on app
		[app setAlphaLock: ((newFlags & kCGEventFlagMaskAlphaShift) == kCGEventFlagMaskAlphaShift)];
	}
	// just monitor the keystroke, always return the event
    return event;
}


OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	
	//NSLog(@"modifier flags: 0x%x", [[NSApp currentEvent] modifierFlags]);
	
	
	OSStatus theError;
	EventHotKeyID hkCom;
	
	//UInt32 modifierFlags = GetCurrentKeyModifiers();
	//NSUInteger modifierFlags = [theEvent modifierFlags];
	//NSLog(@"%d", modifierFlags);
	
	//NSLog(@"%d", [[NSApp currentEvent] modifierFlags]);
	/*
	if (NSAlphaShiftKeyMask & [[NSApp currentEvent] modifierFlags]) {
		NSLog(@"CAPS LOCK");
	}
	*/
	
	
	theError = GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(hkCom),NULL,&hkCom);
	
	if( theError == noErr && GetEventClass(theEvent) == kEventClassKeyboard)
	{
		[(id)userData hotKeyPressed:hkCom.id];
	}
	
	return theError;
}

OSStatus myHotKeyReleasedHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	EventHotKeyID hkCom;
	GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(hkCom),NULL,&hkCom);
	[(id)userData hotKeyReleased:hkCom.id];
	return noErr;
}

static OSStatus AppFrontSwitchedHandler(EventHandlerCallRef inHandlerCallRef, EventRef inEvent, void *inUserData)
{
    [(id)inUserData checkFrontAppForHotkeys];
    return 0;
}


@implementation AppController
- (id) init
{
	hotkeysBound = NO;
	
	// create hotkeys-dictionary to hold all the hotkeys by keycombo
	// each dict-entry is a NSMutableArray as a keycombo can be assigned to 
	// multiple hotkeys - ie. one with CAPS-Lock enabled and one without
	hotkeys = [[NSMutableArray alloc] init];
	//hotkeys = [[NSMutableDictionary alloc] init];
	
	midiController = [[MIDIController alloc] init];
	
    return self;
}

- (void) hotKeyPressed:(int) hotKeyId
{
	/*
	if (NSAlphaShiftKeyMask & [[NSApp currentEvent] modifierFlags]) {
		// Hotkeys aus den hotkeysCapsLock auslesen
		NSLog(@"CAPS LOCK");
	}
	NSLog(@"Hotkey pressed: %d", hotKeyId);
	HotKey *hotkey = (HotKey *)[hotkeys objectAtIndex:hotKeyId];
	NSLog(@"Hotkey: %@", hotkey);
	[hotkey pressed];
	*/
	[(HotkeyTrigger *)[hotkeys objectAtIndex:hotKeyId] pressed];
}
- (void) hotKeyReleased:(int) hotKeyId
{
	//NSLog(@"Hotkey released: %d", hotKeyId);
	[(HotkeyTrigger *)[hotkeys objectAtIndex:hotKeyId] released];
}




- (void) bindHotkeys {
	//NSLog(@"bind hotkeys");
	int i = [hotkeys count];
	while ( i-- ) {
		HotkeyTrigger *hotkeyTrigger = (HotkeyTrigger *)[hotkeys objectAtIndex:i];
		/*
		if ([hotkeyTrigger hasAlphaLock] == alphaLockEnabled) {
			[hotkeyTrigger activate];
		}
		*/
		if (!alphaLockEnabled && [hotkeyTrigger hasAlphaLock]) {
			continue;
		}
		[hotkeyTrigger activate];
		
	}
	/*
	NSEnumerator *enumerator = [hotkeys keyEnumerator];
	id key;
	
	while ((key = [enumerator nextObject])) {
		NSMutableArray *hotkeysDict = [hotkeys objectForKey:key];
		// only bind first hotkey for that keycombo
		[[hotkeysDict objectAtIndex:0] activate];
	}
	*/
	hotkeysBound = YES;
}
- (void) unbindHotkeys: (BOOL) all {
	//NSLog(@"unbind hotkeys");
	
	int i = [hotkeys count];
	while ( i-- ) {
		//[(HotkeyTrigger *)[hotkeys objectAtIndex:i] deactivate];
		HotkeyTrigger *hotkeyTrigger = (HotkeyTrigger *)[hotkeys objectAtIndex:i];
		//if (all || [hotkeyTrigger hasAlphaLock] != alphaLockEnabled) {
		if (all || ([hotkeyTrigger hasAlphaLock] && !alphaLockEnabled)) {
			[hotkeyTrigger deactivate];
		}
	}
	hotkeysBound = NO;
}


- (BOOL) shouldHaveHotkeys {
	
	NSDictionary *activeApp = [[NSWorkspace sharedWorkspace] activeApplication];
	NSString *activeAppName = (NSString *)[activeApp objectForKey:@"NSApplicationName"];
	//NSLog(@"The active app is %@", activeAppName);
	
	// TODO: optional add NSArray for multiple apps other than Live to have hotkeys enabled
	return [activeAppName isEqualToString: @"Live"];
}






- (void) setAlphaLock: (BOOL) flag {
	if (alphaLockEnabled == flag) {
		// alphaLock is already set to flag, so no action required
		return;
	}
	alphaLockEnabled = flag;
	//NSLog(@"alphaLock has changed => rebind keyboard-shortcuts");
	
	if ([self shouldHaveHotkeys]) {
		[self unbindHotkeys:FALSE];
		[self bindHotkeys];
	}
}




- (void) checkFrontAppForHotkeys {
	if ([self shouldHaveHotkeys]) {
		if (!hotkeysBound) {
			[self bindHotkeys];
		}
	}
	else if (hotkeysBound) {
		[self unbindHotkeys:TRUE];
	}
}

- (void) awakeFromNib
{
	// event-handler for front app switched
	EventTypeSpec spec = { kEventClassApplication,  kEventAppFrontSwitched };
    InstallApplicationEventHandler(NewEventHandlerUPP(AppFrontSwitchedHandler), 1, &spec, (void*)self, NULL);
	
	
	// event-handlers for KeyPressed and KeyReleased
	EventTypeSpec eventType;
	eventType.eventClass=kEventClassKeyboard;
	
	// eventType for KeyPressed
	eventType.eventKind=kEventHotKeyPressed;
	InstallApplicationEventHandler(&myHotKeyHandler,1,&eventType,(void *)self,NULL);
	// eventType for KeyReleased
	eventType.eventKind=kEventHotKeyReleased;
	InstallApplicationEventHandler(&myHotKeyReleasedHandler,1,&eventType,(void *)self,NULL);
	
	//EventTypeSpec keyboardHandlerEvents = { kEventClassKeyboard, kEventRawKeyModifiersChanged /*kEventRawKeyDown*/ };
	//eventType.eventClass=kEventRawKeyUp;
	//eventType.eventKind=kEventRawKeyDown;
	//InstallApplicationEventHandler(NewEventHandlerUPP(myHotKeyRawHandler),1,&keyboardHandlerEvents,(void *)self,NULL);
	//InstallEventHandler(GetEventMonitorTarget(), NewEventHandlerUPP(myHotKeyRawHandler),1,&keyboardHandlerEvents,(void *)self,NULL);
	
	/*
	EventHandlerRef      sHandler;
	EventTypeSpec   kEvents[] =
	{
		// use an event that isn't monitored just so we have a valid EventTypeSpec to install
		{ kEventClassCommand, kEventCommandUpdateStatus }
	};
	InstallEventHandler( GetEventMonitorTarget(), myHotKeyRawHandler, GetEventTypeCount( kEvents ),
						kEvents, (void *)self, NULL);
	*/
	//CFMachPortRef keyUpEventTap = CGEventTapCreate(kCGHIDEventTap,kCGHeadInsertEventTap,kCGEventTapOptionListenOnly,kCGEventKeyUp,&keyUpCallback,NULL);
	CFMachPortRef keyUpEventTap = CGEventTapCreate(kCGHIDEventTap,kCGHeadInsertEventTap,kCGEventTapOptionListenOnly,CGEventMaskBit(kCGEventFlagsChanged),&keyUpCallback,self);
	CFRunLoopSourceRef keyUpRunLoopSourceRef = CFMachPortCreateRunLoopSource(NULL, keyUpEventTap, 0);
	CFRelease(keyUpEventTap);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), keyUpRunLoopSourceRef, kCFRunLoopDefaultMode);
	CFRelease(keyUpRunLoopSourceRef);
	
	
	
	
	
	
	
	
	
	
	
	
	// read default Key-Commands and Actions from MIDIActions.plist
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MIDIActions" ofType:@"plist"];
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *hotKeyActions = (NSDictionary *)[NSPropertyListSerialization
		propertyListFromData:plistXML
        mutabilityOption:NSPropertyListMutableContainersAndLeaves
		format:&format
		errorDescription:&errorDesc];
	
	if (!hotKeyActions) {
		NSLog(errorDesc);
		[errorDesc release];
	}
	
	
	
	// temporary lookup of hotkeyId by keycombo; auto-released at end of function
	NSMutableDictionary *hotkeyIdsByKeyCombo = [NSMutableDictionary dictionary];
	
	NSEnumerator* actionsIterator = [[hotKeyActions allKeys] objectEnumerator];
	id key;
	while( key = [actionsIterator nextObject])
	{
		//NSLog(@"key: %@, value: %@", key, [hotKeyActions objectForKey:key]);
		NSDictionary *actionSettings = [hotKeyActions objectForKey:key];
		NSDictionary *hotkeySettings = [actionSettings objectForKey:@"hotkey"];
		
		int keyCode = [[hotkeySettings valueForKey:@"keyCode"] intValue];
		//NSLog(@"++ Register key-combo for: %d", keyCode);
		int keyCombo = 0;
		if ([[hotkeySettings valueForKey:@"cmdKey"] boolValue]) {
			keyCombo+= cmdKey;
		}
		if ([[hotkeySettings valueForKey:@"controlKey"] boolValue]) {
			keyCombo+= controlKey;
		}
		if ([[hotkeySettings valueForKey:@"optionKey"] boolValue]) {
			keyCombo+= optionKey;
		}
		if ([[hotkeySettings valueForKey:@"shiftKey"] boolValue]) {
			keyCombo+= shiftKey;
		}
		if ([[hotkeySettings valueForKey:@"alphaLock"] boolValue]) {
			keyCombo+= alphaLock;
		}
		
		/*
		//NSLog(@"KeyCombo: 0x%X", keyCombo);
		if ((keyCombo & alphaLock) == alphaLock) {
			keyCombo-= alphaLock;
			NSLog(@"KeyCombo alphaLock removed for subscription: 0x%X", keyCombo);
		}
		 */
		
		
		// setup all the Hotkeys based on those actions
		HotkeyAction *hotkeyAction = nil;
		int channel = 0; // default channel is 0 (with channels ranging from 0 to 15)
		if ([[actionSettings objectForKey:@"channel"] boolValue]) {
			channel = [[actionSettings objectForKey:@"channel"] intValue];
			if (channel < 0 || channel > 15) {
				channel = 0;
				NSLog(@"channel not in range 0-15, set to default 0");
			}
		}
		if ([[actionSettings valueForKey:@"cc"] boolValue]) {
			hotkeyAction = [[HotkeyActionRepeat alloc] init];
			
			// binary addition: CC-Status (first byte) = 0xB; Channel (second byte) = 0-15 => send CC on first channel: 0x<status>0 | <channel>
			[hotkeyAction setChannel:0xB0 | channel];
			[hotkeyAction setKey:[[actionSettings valueForKey:@"cc"] intValue]];
			
			[hotkeyAction setValue:[[actionSettings valueForKey:@"value"] intValue]];
		}
		else {
			hotkeyAction = [[HotkeyActionRetrigger alloc] init];
			
			[hotkeyAction setChannel:0x90 | channel];
			[hotkeyAction setKey:[[actionSettings valueForKey:@"note"] intValue]];
			[hotkeyAction setValue:127];
		}
		[hotkeyAction setController:midiController];
		
		
		
		
		HotkeyTrigger *hotkeyTrigger = nil;
		NSString *hotkeyIdKeyCombo = [NSString stringWithFormat: @"0x%X", keyCombo*0x100 | keyCode];
		NSNumber *hotkeyIdNumber = [hotkeyIdsByKeyCombo objectForKey:hotkeyIdKeyCombo];
		if (hotkeyIdNumber == nil) {
			// new hotkeyId at the end of hotkeys-array			
			hotkeyIdNumber = [[NSNumber alloc] initWithInt:[hotkeys count]];
			[hotkeyIdsByKeyCombo setObject:hotkeyIdNumber forKey:hotkeyIdKeyCombo];
			
			hotkeyTrigger = [[HotkeyTrigger alloc] init];
			[hotkeyTrigger setKeyCombo:keyCombo];
			[hotkeyTrigger setKeyCode:keyCode];
			[hotkeyTrigger setHotkeyId:[hotkeyIdNumber intValue]];
			
			[hotkeys addObject:hotkeyTrigger];
		}
		else {
			hotkeyTrigger = (HotkeyTrigger *)[hotkeys objectAtIndex:[hotkeyIdNumber intValue]];
		}
		[hotkeyTrigger addAction:hotkeyAction];
		
		/*
		[hotkey setKeyCode:keyCode];
		if ([[hotkeySettings valueForKey:@"alphaLock"] boolValue]) {
			[hotkey setAlphaLock:true];
			NSLog(@"alphaLock");
		}
		else {
			[hotkey setAlphaLock:false];
		}
		[hotkey setKeyCombo:keyCombo];
		 */
		
		//[hotkey setValue:[[actionSettings valueForKey:@"value"] intValue]];
		
		//[hotkey setEventHotKeyID:hotKeyID];
		//[hotkeys addObject:hotkey];
		
		//NSLog(@"%d", keyCombo & keyCode);
		/*
		NSString *eventHotKeyId = [NSString stringWithFormat: @"%d", keyCombo & keyCode];
		[hotkey setEventHotKeyID:keyCombo];
		NSMutableArray *hotkeysDict = [hotkeys objectForKey:eventHotKeyId];
		if (hotkeysDict == nil) {
			hotkeysDict = [[NSMutableArray alloc] init];
			[hotkeys setObject:hotkeysDict forKey:eventHotKeyId];
		}
		[hotkeysDict addObject:hotkey];
		*/
		
		//hotkeyId += 1;
		
		
		// do not register hotkey yet
		//RegisterEventHotKey(keyCode, keyCombo, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	}
	
	// check which app is in front and if needed, bind hotkeys
	[self checkFrontAppForHotkeys];
}




@end
