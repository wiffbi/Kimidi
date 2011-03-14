//
//  HotKey.m
//  Kimidi
//
//  Created by Richard Schreiber on 02.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HotKey.h"
#import "AppController.h"
#import <Carbon/Carbon.h>

@implementation HotKey

- (void) setController: (id) c
{
	controller = c;
}
/*
- (void) setMessage: (unsigned char*) m
{
	message = m;
}
*/
- (void) setChannel: (int) c
{
	channel = c;
}
- (void) setKey: (int) k
{
	key = k;
}
- (void) setValue: (int) v
{
	value = v;
}


- (void) setKeyCode: (int) code
{
	keyCode = code;
}
- (void) setKeyCombo: (int) combo
{
	keyCombo = combo;
}
- (void) setEventHotKeyID: (int) i
{
	hotKeyID.id = i;
}


- (void) activate
{
	RegisterEventHotKey(keyCode, keyCombo, hotKeyID, GetApplicationEventTarget(), 0, &hotKeyRef);
}
- (void) deactivate
{
	UnregisterEventHotKey(hotKeyRef);
}




- (void) pressed
{
	//NSLog(@"HotKey pressed");
	[self execute];
}

- (void) released
{
	//NSLog(@"HotKey released");
	//NSLog(timer);
	
	
	if (channel == 0x90 | 0)
	{
		// send note off event
		[controller sendMIDIMessage:0x80:key:0];
	}
	
}
- (void) execute
{
	//NSLog(@"HotKey action");
	//NSLog(@"MIDI-message: %d", key);
	//[controller sendMIDINote:1:127];
	[controller sendMIDIMessage:channel:key:value];
}


@end
