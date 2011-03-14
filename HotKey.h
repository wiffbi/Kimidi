//
//  HotKey.h
//  Kimidi
//
//  Created by Richard Schreiber on 02.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
//


@interface HotKey : NSObject {
	id controller;
	//unsigned char* message;
	
	int channel;
	int key;
	int value;
	
	int keyCode;
	int keyCombo;
	
	EventHotKeyRef hotKeyRef;
	EventHotKeyID hotKeyID;
}

- (void) setController: (id) ac;
//- (void) setMessage: (unsigned char*) message;
- (void) setChannel: (int) c;
- (void) setKey: (int) k;
- (void) setValue: (int) v;

- (void) setKeyCode: (int) code;
- (void) setKeyCombo: (int) combo;
- (void) setEventHotKeyID: (int) i;

- (void) activate;
- (void) deactivate;


- (void) pressed;
- (void) released;
- (void) execute;

@end
