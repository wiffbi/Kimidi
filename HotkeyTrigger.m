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
    pressed = false;
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
	hotkeyId = i;
}

- (bool) hasAlphaLock
{
	return (keyCombo & alphaLock) == alphaLock;
}

- (void) activate
{
	if (active) return;
	active = TRUE;
}

- (void) deactivate
{
	if (active) {
		active = FALSE;
	}
}




- (void) pressed
{
    if(pressed)
        return;
    
    pressed=true;
    
	int i = [hotkeyActions count];
	while ( i-- ) {
		[(HotkeyAction *)[hotkeyActions objectAtIndex:i] pressed];
	}
}

- (void) released
{
    
    if(!pressed)
        return;
    
    pressed=false;
    
	int i = [hotkeyActions count];
	while ( i-- ) {
		[(HotkeyAction *)[hotkeyActions objectAtIndex:i] released];
	}
}
@end
