//
//  HotkeyTrigger.m
//  Kimidi
//
//  Created by Richard Schreiber on 18.09.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "HotkeyTrigger.h"


@implementation HotkeyTrigger
- (id) init
{
	hotkeyActions = [[NSMutableArray alloc] init];
    return self;
}

- (void) addAction:(HotkeyAction*) hotkeyAction
{
	[hotkeyActions addObject:hotkeyAction];
}
- (void) removeAction:(HotkeyAction*) hotkeyAction
{
	[hotkeyActions removeObject:hotkeyAction];
}




- (void) setKeyCode: (int) code
{
	keyCode = code;
}
- (void) setKeyCombo: (int) combo
{
	keyCombo = combo;
}
- (void) setHotkeyId: (int) i
{
	hotkeyId.id = i;
}

- (bool) hasAlphaLock
{
	return (keyCombo & alphaLock) == alphaLock;
}

- (void) activate
{
	int keyComboWithoutAlphaLock = keyCombo;
	if ([self hasAlphaLock]) {
		keyComboWithoutAlphaLock-= alphaLock;
	}
	RegisterEventHotKey(keyCode, keyComboWithoutAlphaLock, hotkeyId, GetApplicationEventTarget(), 0, &hotKeyRef);
}
- (void) deactivate
{
	UnregisterEventHotKey(hotKeyRef);
}




- (void) pressed
{
	int i = [hotkeyActions count];
	while ( i-- ) {
		[(HotkeyAction *)[hotkeyActions objectAtIndex:i] pressed];
	}
}

- (void) released
{
	int i = [hotkeyActions count];
	while ( i-- ) {
		[(HotkeyAction *)[hotkeyActions objectAtIndex:i] released];
	}
}
@end
