//
//  MIDIController.m
//  Kimidi
//
//  Created by Richard Schreiber on 21.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MIDIController.h"



@implementation MIDIController
- (id) init
{
	virtualInput = [[PYMIDIVirtualSource alloc] initWithName:@"Kimidi Input"];
	[virtualInput addSender:self];
	
	virtualOutput = [[PYMIDIVirtualDestination alloc] initWithName:@"Kimidi Output"];
	[virtualOutput addReceiver:self];
	
	
	// create array for MIDIPacketTimed to check for feedback loop
	midiMessages = [[NSMutableArray alloc] init];
	
    return self;
}

- (void) send: (int) channel: (int) key: (int) value
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
	
	//NSLog(@"send: %d, %d, %d", channel, key, value);
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
	//NSLog(@"received: %d, %d, %d", channel, key, value);
	
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
		//NSLog(@"forward MIDI");
		[self send: channel : key : value];
	}
}
@end
