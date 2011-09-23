//
//  MIDIController.h
//  Kimidi
//
//  Created by Richard Schreiber on 21.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PYMIDI/PYMIDI.h>
#import "MIDIPacketTimed.h"


@interface MIDIController : NSObject {
	PYMIDIVirtualSource* virtualInput;
	PYMIDIVirtualDestination* virtualOutput;
	
	// keep some received MIDI messages so one can suppress MIDI feedback loop
	NSMutableArray *midiMessages;
}
- (void) send: (int) channel: (int) key: (int) value;//(unsigned char*) message;
- (void) processMIDIPacketList: (MIDIPacketList*)packetList sender:(id)sender;

@end
