//
//  AppController.m
//  SelectedTrackControl
//
//  Created by Richard Schreiber on 22.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"
#import <Carbon/Carbon.h>
#import <CoreServices/CoreServices.h>

#import <CoreAudio/HostTime.h>
#import <PYMIDI/PYMIDI.h>

//#import "HotKey.h"
//#import "HotKeyMomentary.h"
//#import "HotKeyRepeat.h"

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	NSLog(@"modifier flags: 0x%x", [[NSApp currentEvent] modifierFlags]);
	
	OSStatus theError;
	EventHotKeyID hkCom;
	
	//UInt32 modifierFlags = GetCurrentKeyModifiers();
	//NSUInteger modifierFlags = [theEvent modifierFlags];
	//NSLog(@"%d", modifierFlags);
	NSLog(@"%d", [[NSApp currentEvent] modifierFlags]);
	
	if (NSAlphaShiftKeyMask & [[NSApp currentEvent] modifierFlags]) {
		NSLog(@"CAPS LOCK");
	}
	
	
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
    [(id)inUserData appFrontSwitched];
    return 0;
}

@implementation AppController
- (void) logHotKey
{
	//NSLog(@"logHotKey");
}
- (id) init
{
	hotkeysBound = NO;
	
	// create hotkeys-array to hold all the hotkeys
	hotkeys = [[NSMutableArray alloc] init];

	//PYMIDIVirtualSource* 
	virtualInput = [[PYMIDIVirtualSource alloc] initWithName:@"STC Virtual IN"];
	[virtualInput addSender:self];
	//NSLog([virtualInput displayName]);
	
	//virtualOutput = [[PYMIDIVirtualDestination alloc] initWithName:@"STC Virtual OUT"];
	//[virtualOutput addReceiver:self];
	
    return self;
}

- (void) hotKeyPressed:(int) hotKeyId
{
	if (NSAlphaShiftKeyMask & [[NSApp currentEvent] modifierFlags]) {
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
	
	packetPtr = MIDIPacketListAdd(&packetList, sizeof packetList, packetPtr, AudioGetCurrentHostTime(), 3, (const Byte *)&midiData);

	[virtualInput processMIDIPacketList:&packetList sender:self];

}

- (void) bindHotkeys {
	NSLog(@"bind hotkeys");
	
	hotkeysBound = YES;
}
- (void) unbindHotkeys {
	NSLog(@"unbind hotkeys");
	
	
	hotkeysBound = NO;
}




- (void) appFrontSwitched {
	NSDictionary *activeApp = [[NSWorkspace sharedWorkspace] activeApplication];
	//NSString *
	activeAppName = (NSString *)[activeApp objectForKey:@"NSApplicationName"];
	NSLog(@"The active app is %@", activeAppName);
	
	if ([activeAppName isEqualToString: @"Live"] && !hotkeysBound) {
		[self bindHotkeys];
	}
	else if (hotkeysBound) {
		[self unbindHotkeys];
	}
}

- (void) awakeFromNib
{
	// appFrontSwitched
	EventTypeSpec spec = { kEventClassApplication,  kEventAppFrontSwitched };
    InstallApplicationEventHandler(NewEventHandlerUPP(AppFrontSwitchedHandler), 1, &spec, (void*)self, NULL);
	
	
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
	
	// check which app is in front and if needed, bind hotkeys
	[self appFrontSwitched];
	
	
	//[hotKeyActions release]

	/*
	Install event-handlers for KeyPressed and KeyReleased
	*/
	
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
	
	
	// setup hotkeyref
	EventHotKeyRef myHotKeyRef;
	EventHotKeyID myHotKeyID;
	myHotKeyID.id=0;
	
	
	// iterate all 
	
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
		
		[hotkey setController:self];
		
		//[hotkey setValue:[[actionSettings valueForKey:@"value"] intValue]];
		[hotkeys addObject:hotkey];
		
		RegisterEventHotKey(keyCode, keyCombo, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
		myHotKeyID.id+=1;
	}
}




@end
