//
//  MIDIPacketTimed.h
//  Kimidi
//
//  Created by Richard Schreiber on 10.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MIDIPacketTimed : NSObject {
	int channel;
	int key;
	int value;
	
	UInt64 timestamp;
}

- (void) setChannel: (int) c;
- (void) setKey: (int) k;
- (void) setValue: (int) v;
- (void) setTimestamp: (UInt64) t;

- (int) getChannel;
- (int) getKey;
- (int) getValue;
- (UInt64) getTimestamp;


- (bool) equals: (MIDIPacketTimed*) m;
- (bool) olderThan: (UInt64) t;

@end
