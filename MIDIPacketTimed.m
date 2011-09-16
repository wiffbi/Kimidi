//
//  MIDIPacketTimed.m
//  Kimidi
//
//  Created by Richard Schreiber on 10.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MIDIPacketTimed.h"


@implementation MIDIPacketTimed

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
- (void) setTimestamp: (UInt64) t
{
	timestamp = t;
}
- (int) getChannel
{
	return channel;
}
- (int) getKey
{
	return key;
}
- (int) getValue
{
	return value;
}
- (UInt64) getTimestamp
{
	return timestamp;
}


- (bool) equals: (MIDIPacketTimed*) m
{
	int c = [m getChannel];
	int k = [m getKey];
	int v = [m getValue];
	
	//NSLog(@"1. %d == %d", channel, c);
	//NSLog(@"2. %d == %d", key, k);
	//NSLog(@"3. %d == %d", value, v);
	if (channel == c && key == k && value == v && ![self olderThan : [m getTimestamp]])
	{
		NSLog(@"equal");
		return TRUE;
	}
	NSLog(@"NOT equal");
	return FALSE;
}

- (bool) olderThan: (UInt64) t
{
	if (timestamp + 250 * 1000000 < t || t + 250 * 1000000 < timestamp)
	{
		NSLog(@"older");
		return TRUE;
	}
	return FALSE;
}


@end
