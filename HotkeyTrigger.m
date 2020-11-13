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

- (int) keyCode {
    return keyCode;
}

// not really needed I think
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
    
    NSLog(@"Released trigger %@",self);
    
    pressed=false;
    
	int i = [hotkeyActions count];
	while ( i-- ) {
		[(HotkeyAction *)[hotkeyActions objectAtIndex:i] released];
	}
}


- (NSString *)description {
    
    NSMutableArray* modifiers = [NSMutableArray array];
    
    if((keyCombo & cmdKey)==cmdKey)
        [modifiers addObject:@"cmd"];
    if((keyCombo & controlKey)==controlKey)
        [modifiers addObject:@"ctrl"];
    if((keyCombo & optionKey)==optionKey)
        [modifiers addObject:@"alt"];
    if((keyCombo & shiftKey)==shiftKey)
        [modifiers addObject:@"shift"];
    if((keyCombo & alphaLock)==alphaLock)
        [modifiers addObject:@"caps"];
    
    return [NSString stringWithFormat:@"Trigger: keyCode=%d, modifiers=%@",keyCode,modifiers];
}

@end
