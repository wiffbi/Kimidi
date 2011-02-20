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

OSStatus myHotKeyHandler(EventHandlerCallRef nextHandler, EventRef theEvent, void *userData)
{
	//NSLog(@"YEAY WE DID A GLOBAL HOTKEY");
	//return noErr;
	
	OSStatus theError;
	EventHotKeyID hkCom;
	
	theError = GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(hkCom),NULL,&hkCom);
	
	if( theError == noErr && GetEventClass(theEvent) == kEventClassKeyboard)
	{
		[(id)userData hotKeyPressed:hkCom.id];
	}

	/*
	UInt8	macCharCode = 0;
	OSStatus result = GetEventParameter (theEvent, kEventParamKeyMacCharCodes, typeChar, NULL, sizeof (UInt8), NULL, &macCharCode);
	NSLog(@"The result %@", result);
	//theError = GetEventParameter(theEvent,kEventParamDirectObject,typeEventHotKeyID,NULL,sizeof(hkCom),NULL,&hkCom);
	*/
	return theError;
	//[self sendMIDI];
	//[(id)userData logHotKey];
	/*
	switch (l) {
		case STC_HOTKEY_ARM: // arm safe track
			[(id)userData sendMIDINote:0:127];
			break;
		case STC_HOTKEY_ARM_SHIFT: // arm track
			[(id)userData sendMIDINote:0:0];
			break;

		case STC_HOTKEY_SOLO: // solo safe track
			[(id)userData sendMIDINote:1:127];
			break;
		case STC_HOTKEY_SOLO_SHIFT: // solo track
			[(id)userData sendMIDINote:1:0];
			break;

		case STC_HOTKEY_MUTE: // mute track
			[(id)userData sendMIDINote:2:127];
			break;
		
		
		case STC_HOTKEY_PANLEFT: // pan left
			[(id)userData sendMIDICC:10:123];
			break;
		case STC_HOTKEY_PANLEFT_SHIFT: // pan left more precise
			[(id)userData sendMIDICC:10:127];
			break;
		case STC_HOTKEY_PANRIGHT: // pan right
			[(id)userData sendMIDICC:10:5];
			break;
		case STC_HOTKEY_PANRIGHT_SHIFT: // pan right more precise
			[(id)userData sendMIDICC:10:1];
			break;
		
		
		case STC_HOTKEY_VOLUMEUP:
			[(id)userData sendMIDICC:7:5];
			break;
		case STC_HOTKEY_VOLUMEUP_SHIFT:
			[(id)userData sendMIDICC:7:1];
			break;
		case STC_HOTKEY_VOLUMEDOWN:
			[(id)userData sendMIDICC:7:123];
			break;
		case STC_HOTKEY_VOLUMEDOWN_SHIFT:
			[(id)userData sendMIDICC:7:127];
			break;
	}
	//NSLog([virtualInput displayName]);
	return noErr;
	*/
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
	NSLog(@"logHotKey");
}
- (id) init
{
	// create hotkeys-array to hold all the hotkeys
	hotkeys = [[NSMutableArray alloc] init];
	
	/*
	hotkey = [[HotKey alloc] init];
	[hotkey setController:self];
	*/
	/*
	// customizable hotkeys
	NSMutableDictionary *userDefaultsValuesDict = [NSMutableDictionary dictionary];
	[userDefaultsValuesDict setObject:[NSNumber numberWithInt:0] forKey:@"hotkeyCodeArm"];
	[userDefaultsValuesDict setObject:[NSNumber numberWithInt:controlKey] forKey:@"hotkeyModifiersArm"];
	
	[userDefaultsValuesDict setObject:[NSNumber numberWithInt:1] forKey:@"hotkeyCodeSolo"];
	[userDefaultsValuesDict setObject:[NSNumber numberWithInt:controlKey] forKey:@"hotkeyModifiersSolo"];

	[[NSUserDefaults standardUserDefaults] registerDefaults:userDefaultsValuesDict];      //Register the defaults
	[[NSUserDefaults standardUserDefaults] synchronize];  //And sync them
	*/
	

	//PYMIDIVirtualSource* 
	virtualInput = [[PYMIDIVirtualSource alloc] initWithName:@"STC Virtual IN"];//[PYMIDIVirtualSource initWithName:@"My virtual input"];
	//[virtualInput setName:@"Kimidi IN"];
	
	[virtualInput addSender:self];
	//NSLog([virtualInput displayName]);

	
    return self;
}

- (void) hotKeyPressed:(int) hotKeyId
{
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
/*
- (void) sendMIDICC: (int) cc: (int) value
{
	int channel = 0xB0 | 0; // channel 1 for CC
	[self sendMIDIMessage:channel:cc:value];
}
- (void) sendMIDINote: (int) note: (int) velocity
{
	int channel = 0x90 | 0; // channel 1 for Notes
	[self sendMIDIMessage:channel:note:velocity];
}
*/


- (void) appFrontSwitched {
    NSLog(@"%@", [[NSWorkspace sharedWorkspace] activeApplication]);
}
-(void)awakeFromNib
{
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
		
		/*
		unsigned char midiData[3];
		midiData[0] = 0x90 | 0;
		midiData[1] = 0;
		midiData[2] = 127;
		*/
		
		// setup all the Hotkeys based on those actions
		HotKey *hotkey = [[HotKeyMomentary alloc] init];
		[hotkey setController:self];
		if ([[actionSettings valueForKey:@"cc"] boolValue]) {
			[hotkey setChannel:0xB0 | 0];
			[hotkey setKey:[[actionSettings valueForKey:@"cc"] intValue]];
		}
		else {
			[hotkey setChannel:0x90 | 0];
			[hotkey setKey:[[actionSettings valueForKey:@"note"] intValue]];
		}
		
		[hotkey setValue:[[actionSettings valueForKey:@"value"] intValue]];
		[hotkeys addObject:hotkey];
		
		RegisterEventHotKey([[hotkeySettings valueForKey:@"keyCode"] intValue], keyCombo, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
		myHotKeyID.id+=1;
	}
	
	//NSLog([[actions objectForKey:@"arm"] objectForKey:@"key"]);
	//for (id key in actionKeys) {
	//	NSLog(@"key: %@, value: %@", key, [actions objectForKey:key]);
	//}
	
	//RegisterEventHotKey(1024, 0, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	//myHotKeyID.id+=1;
	/*
	myHotKeyID.id=0;
	RegisterEventHotKey(0, controlKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	
	
	
	myHotKeyID.id=STC_HOTKEY_ARM;
	RegisterEventHotKey(STC_HOTKEY_ARM, controlKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);

	myHotKeyID.id=STC_HOTKEY_ARM_SHIFT;
	RegisterEventHotKey(STC_HOTKEY_ARM, controlKey+shiftKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	
	myHotKeyID.id=STC_HOTKEY_SOLO;
	RegisterEventHotKey(STC_HOTKEY_SOLO, controlKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	myHotKeyID.id=STC_HOTKEY_SOLO_SHIFT;
	RegisterEventHotKey(STC_HOTKEY_SOLO, controlKey+shiftKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	
	myHotKeyID.id=STC_HOTKEY_MUTE;
	RegisterEventHotKey(STC_HOTKEY_MUTE, controlKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);


	myHotKeyID.id=STC_HOTKEY_PANLEFT;
	RegisterEventHotKey(STC_HOTKEY_PANLEFT, controlKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	myHotKeyID.id=STC_HOTKEY_PANLEFT_SHIFT;
	RegisterEventHotKey(STC_HOTKEY_PANLEFT, controlKey+shiftKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);

	myHotKeyID.id=STC_HOTKEY_PANRIGHT;
	RegisterEventHotKey(STC_HOTKEY_PANRIGHT, controlKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	myHotKeyID.id=STC_HOTKEY_PANRIGHT_SHIFT;
	RegisterEventHotKey(STC_HOTKEY_PANRIGHT, controlKey+shiftKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	
	
	
	myHotKeyID.id=STC_HOTKEY_VOLUMEUP;
	RegisterEventHotKey(STC_HOTKEY_VOLUMEUP, controlKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	myHotKeyID.id=STC_HOTKEY_VOLUMEUP_SHIFT;
	RegisterEventHotKey(STC_HOTKEY_VOLUMEUP, controlKey+shiftKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	
	myHotKeyID.id=STC_HOTKEY_VOLUMEDOWN;
	RegisterEventHotKey(STC_HOTKEY_VOLUMEDOWN, controlKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	myHotKeyID.id=STC_HOTKEY_VOLUMEDOWN_SHIFT;
	RegisterEventHotKey(STC_HOTKEY_VOLUMEDOWN, controlKey+shiftKey, myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);	
	*/
	//NSArray
	//NSDictionary
	//NSArray *objects = [NSArray arrayWithObjects:@"String1", @"String2", @"String3", nil];
	/*
	if([[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyCodeArm"]!=-999) {
		myHotKeyID.id=STC_HOTKEY_ARM;
		
		RegisterEventHotKey([[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyCodeArm"], [[NSUserDefaults standardUserDefaults] integerForKey:
@"hotkeyModifiersArm"], myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	}

	if([[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyCodeSolo"]!=-999) {
		myHotKeyID.id=STC_HOTKEY_SOLO;
		
		RegisterEventHotKey([[NSUserDefaults standardUserDefaults] integerForKey:@"hotkeyCodeSolo"], [[NSUserDefaults standardUserDefaults] integerForKey:
@"hotkeyModifiersSolo"], myHotKeyID, GetApplicationEventTarget(), 0, &myHotKeyRef);
	}
	*/

}




@end
