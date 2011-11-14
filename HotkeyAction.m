//
//  HotkeyAction.m
//  Kimidi
//
//  Created by Richard Schreiber on 19.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HotkeyAction.h"


@implementation HotkeyAction
- (void) setController: (MIDIController *) c
{
	controller = c;
}
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



- (void) pressed
{
	//NSLog(@"HotKey pressed");
	[self execute];
}

- (void) released
{
	//NSLog(@"HotKey released");
	//NSLog(timer);
	
	// if this is a note-on event (first byte is 0x9), then send note-off (0x80)
	if (channel == 0x90 | 0)
	{
		// send note off event
		[controller send:0x80:key:0];
	}
	
}
- (void) execute
{
	//NSLog(@"HotKey action");
	//NSLog(@"MIDI-message: %d", key);
	//[controller sendMIDINote:1:127];
	[controller send:channel:key:value];
}
@end
