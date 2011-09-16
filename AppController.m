//
//  AppController.m
//  SelectedTrackControl
//

#import "AppController.h"
//#import <Carbon/Carbon.h>
//#import <CoreServices/CoreServices.h>

//#import <CoreAudio/HostTime.h>
//#import <PYMIDI/PYMIDI.h>


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
	
	// create hotkeys-array to hold all the hotkeys
	hotkeys = [[NSMutableArray alloc] init];
	
	// create array for MIDIPacketTimed to check for feedback loop
	midiMessages = [[NSMutableArray alloc] init];

	
	//PYMIDIVirtualSource* 
	virtualInput = [[PYMIDIVirtualSource alloc] initWithName:@"STC Virtual IN"];
	[virtualInput addSender:self];
	//NSLog([virtualInput displayName]);
	
	virtualOutput = [[PYMIDIVirtualDestination alloc] initWithName:@"STC Virtual OUT"];
	[virtualOutput addReceiver:self];
	
    return self;
}

- (void) hotKeyPressed:(int) hotKeyId
{
	
	if (NSAlphaShiftKeyMask & [[NSApp currentEvent] modifierFlags]) {
		// Hotkeys aus den hotkeysCapsLock auslesen
		NSLog(@"CAPS LOCK");
	}
	
	//NSLog(@"Hotkey pressed: %d", hotKeyId);
	HotKey *hotkey = (HotKey *)[hotkeys objectAtIndex:hotKeyId];
	//NSLog(@"Hotkey: %@", hotkey);
	[hotkey pressed];
}
- (void) hotKeyReleased:(int) hotKeyId
{
	//NSLog(@"Hotkey released: %d", hotKeyId);
	[(HotKey *)[hotkeys objectAtIndex:hotKeyId] released];
}


- (void) sendMIDIMessage: (int) channel: (int) key: (int) value
{
	//NSLog(@"sendMIDI via ");
	//NSLog([virtualInput displayName]);
	
	MIDIPacketList packetList;
	MIDIPacket *packetPtr = MIDIPacketListInit(&packetList);
	unsigned char midiData[3];
	midiData[0] = channel;
	midiData[1] = key;
	midiData[2] = value;
	UInt64 timestamp = AudioGetCurrentHostTime();
	
	packetPtr = MIDIPacketListAdd(&packetList, sizeof packetList, packetPtr, timestamp, 3, (const Byte *)&midiData);
	
	
	
	//NSLog(@"%llX", timestamp);
	// suppress MIDI feedback-loop
	/*
	 add midiData to list with AudioGetCurrentHostTime()
	 if midiData is received, ignore it, if it is the same
	 the same is:
	 channel the same
	 key the same
	 value the same of if channel == 144: both values > 0 or both values == 0
	 during lookup, remove messages that are to old (usually older than 250ms)
	 */
	//NSArray *timedMIDIPacket;
	//timedMIDIPacket = [NSArray arrayWithObjects: midiData, nil];
	MIDIPacketTimed *mpt = [[MIDIPacketTimed alloc] init];
	[mpt setChannel:channel];
	[mpt setKey:key];
	[mpt setValue:value];
	[mpt setTimestamp:timestamp];
	
	
	NSMutableArray *itemsToKeep = [NSMutableArray arrayWithCapacity:[midiMessages count]];
	unsigned count = [midiMessages count];
	while (count--) {
	//for (MIDIPacketTimed *m in midiMessages) {
		MIDIPacketTimed *m = [midiMessages objectAtIndex:count];
		if (![m olderThan : timestamp]) {
			[itemsToKeep addObject:m];
		}
		else {
			[m autorelease];
		}
	}
	[midiMessages setArray:itemsToKeep];
	/*
	unsigned count = [midiMessages count];
	NSLog(@"send-count: %d", count);
	while (count--) {
		MIDIPacketTimed *m = [midiMessages objectAtIndex:count];
		if ([m olderThan : timestamp]) {
			[midiMessages removeObjectAtIndex:count];
			[m release];
			return;
		}
	}
	*/
	[midiMessages addObject:mpt];
	
	NSLog(@"send: %d, %d, %d", channel, key, value);
	[virtualInput processMIDIPacketList:&packetList sender:self];

}

- (void)processMIDIPacketList:(MIDIPacketList*)packetList sender:(id)sender
{
    // route MIDI in back to out - feedback loop, as Live always sends MIDI in to MIDI out for controllers
	//NSLog(@"receiveMIDI via ");
	//NSLog([virtualOutput displayName]);
	MIDIPacket *packet = &packetList->packet[0];
	//NSLog(@"packet: %d", packet->data[0]);
	int channel, key, value;
	channel = packet->data[0];
	key = packet->data[1];
	value = packet->data[2];
	if (channel == 144 && value > 0)
	{
		// values over 0 fix at 127
		value = 127;
	}
	NSLog(@"received: %d, %d, %d", channel, key, value);
	
	MIDIPacketTimed *mpt = [[MIDIPacketTimed alloc] init];
	[mpt setChannel:channel];
	[mpt setKey:key];
	[mpt setValue:value];
	[mpt setTimestamp:AudioGetCurrentHostTime()];
	
	bool forwardMIDI = TRUE;
	NSMutableArray *itemsToKeep = [NSMutableArray arrayWithCapacity:[midiMessages count]];
	unsigned count = [midiMessages count];
	while (count--) {
		//for (MIDIPacketTimed *m in midiMessages) {
		MIDIPacketTimed *m = [midiMessages objectAtIndex:count];
		if (![mpt equals: m]) {
			[itemsToKeep addObject:m];
		}
		else {
			[m autorelease];
			forwardMIDI = FALSE;
		}
	}
	[midiMessages setArray:itemsToKeep];
	/*
	unsigned count = [midiMessages count];
	NSLog(@"count: %d", count);
	while (count--) {
		MIDIPacketTimed *m = [midiMessages objectAtIndex:count];
		if ([mpt equals:m]) {
			NSLog(@"break feedback loop");
			[midiMessages removeObjectAtIndex:count];
			[m autorelease];
			return;
		}
	}
	*/
	if (forwardMIDI) {
		NSLog(@"forward MIDI");
		[self sendMIDIMessage: channel : key : value];
	}
}

- (void) bindHotkeys {
	//NSLog(@"bind hotkeys");
	
	int i = [hotkeys count];
	while ( i-- ) {
		[[hotkeys objectAtIndex:i] activate];
	}
	
	hotkeysBound = YES;
}
- (void) unbindHotkeys {
	//NSLog(@"unbind hotkeys");
	
	int i = [hotkeys count];
	while ( i-- ) {
		[[hotkeys objectAtIndex:i] deactivate];
	}
	
	hotkeysBound = NO;
}


- (BOOL) shouldHaveHotkeys {
	
	NSDictionary *activeApp = [[NSWorkspace sharedWorkspace] activeApplication];
	NSString *activeAppName = (NSString *)[activeApp objectForKey:@"NSApplicationName"];
	//NSLog(@"The active app is %@", activeAppName);
	
	// TODO: optional add NSArray for multiple apps other than Live to have hotkeys enabled
	return true;//[activeAppName isEqualToString: @"Live"];
}


- (void) checkFrontAppForHotkeys {
	if ([self shouldHaveHotkeys] && !hotkeysBound) {
		[self bindHotkeys];
	}
	else if (hotkeysBound) {
		[self unbindHotkeys];
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
	
	//eventType.eventKind=kEventRawKeyDown;
	//InstallApplicationEventHandler(NewEventHandlerUPP(&myHotKeyRawHandler),1,&eventType,(void *)self,NULL);
	
	
	
	
	
	
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
	
	
	int hotKeyID = 0;
	
	//NSArray *actionKeys = [actions allKeys];
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
			//NSLog(@"cmdKey");
		}
		if ([[hotkeySettings valueForKey:@"controlKey"] boolValue]) {
			keyCombo+= controlKey;
			//NSLog(@"controlKey");
		}
		if ([[hotkeySettings valueForKey:@"optionKey"] boolValue]) {
			keyCombo+= optionKey;
			//NSLog(@"optionKey");
		}
		if ([[hotkeySettings valueForKey:@"shiftKey"] boolValue]) {
			keyCombo+= shiftKey;
			//NSLog(@"shiftKey");
		}
		/*
		 if ([[hotkeySettings valueForKey:@"alphaLock"] boolValue]) {
		 keyCombo+= alphaLock;
		 //NSLog(@"alphaLock");
		 }
		 */
		/*
		 if (keyCombo == 0) {
		 NSLog(@"key: %@, value: %@", key, [hotKeyActions objectForKey:key]);
		 }
		 */
		//NSLog(@"-- key-combo registered");
		
		/*
		 unsigned char midiData[3];
		 midiData[0] = 0x90 | 0;
		 midiData[1] = 0;
		 midiData[2] = 127;
		 */
		
		// setup all the Hotkeys based on those actions
		//HotKey *hotkey = [[HotKeyRepeat alloc] init];
		HotKey *hotkey = nil;
		if ([[actionSettings valueForKey:@"cc"] boolValue]) {
			hotkey = [[HotKeyRepeat alloc] init];
			
			[hotkey setChannel:0xB0 | 0];
			[hotkey setKey:[[actionSettings valueForKey:@"cc"] intValue]];
			
			[hotkey setValue:[[actionSettings valueForKey:@"value"] intValue]];
		}
		else {
			hotkey = [[HotKeyMomentary alloc] init];
			
			[hotkey setChannel:0x90 | 0];
			[hotkey setKey:[[actionSettings valueForKey:@"note"] intValue]];
			[hotkey setValue:127];
		}
		[hotkey setKeyCode:keyCode];
		[hotkey setKeyCombo:keyCombo];
		
		[hotkey setEventHotKeyID:hotKeyID];
		
		[hotkey setController:self];
		
		//[hotkey setValue:[[actionSettings valueForKey:@"value"] intValue]];
		[hotkeys addObject:hotkey];
		
		// do not register hotkey yet
		//RegisterEventHotKey(keyCode, keyCombo, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
		hotKeyID += 1;
	}
	
	
	
	
	
	
	// check which app is in front and if needed, bind hotkeys
	[self checkFrontAppForHotkeys];
}




@end
