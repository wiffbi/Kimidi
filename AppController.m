//
//  AppController.m
//  SelectedTrackControl
//

#import "AppController.h"




@implementation AppController
- (id) init
{
	hotkeysBound = NO;
	
	hotkeys = [[NSMutableArray alloc] init];
    hotkeyIdexesByKeyCombo = [[NSMutableDictionary alloc] init];
	pressedTriggers = [[NSMutableSet alloc] init];
	midiController = [[MIDIController alloc] init];
	
    return self;
}


- (void) dealloc
{
    [hotkeys release];
    [hotkeyIdexesByKeyCombo release];
    [pressedTriggers release];
    [midiController release];
    [super dealloc];
}

- (void) hotKeyPressed:(int) hotKeyId
{
    HotkeyTrigger* trigger = (HotkeyTrigger *) [hotkeys objectAtIndex:hotKeyId];
	[trigger pressed];
    
    [pressedTriggers addObject:trigger];
}
- (void) hotKeyReleased:(int) hotKeyId
{
    HotkeyTrigger* trigger = (HotkeyTrigger *) [hotkeys objectAtIndex:hotKeyId];
	[trigger released];
    [pressedTriggers removeObject:trigger];
}


- (void) activateTriggers {
    int i = [hotkeys count];
    while ( i-- ) {
        HotkeyTrigger *hotkeyTrigger = (HotkeyTrigger *)[hotkeys objectAtIndex:i];
        [hotkeyTrigger activate];
    }
}

- (void) deactivateTriggers {
    
    [pressedTriggers makeObjectsPerformSelector:@selector(released)];
    [pressedTriggers removeAllObjects];
    
    
    int i = [hotkeys count];
    while ( i-- ) {
        HotkeyTrigger *hotkeyTrigger = (HotkeyTrigger *)[hotkeys objectAtIndex:i];
        [hotkeyTrigger deactivate];
    }
}

- (void) bindHotkeys {
    
    [self activateTriggers];
    
    NSLog(@"bind hotkeys");
	void (^block)(NSEvent*) = ^(NSEvent *event) {
        NSString *comboId = [self hotKeyComboId:event.keyCode flags:event.modifierFlags];
        NSNumber *num = [hotkeyIdexesByKeyCombo valueForKey:comboId];
        
        if(event.type == NSEventTypeKeyUp) {
            NSLog(@"keyup: %i", event.keyCode);
            if(num!=nil)
                [self hotKeyReleased: [num intValue]];
            [self releaseAllPressedTriggersWithKeyCode: event.keyCode];
        }
        else if(event.type == NSEventTypeKeyDown && ! event.ARepeat) {
            if(num != nil) {
                NSLog(@"keydown: %i", event.keyCode);
                [self hotKeyPressed: [num intValue]];
            }
        }
    };
    
    globalMonitor = [NSEvent addGlobalMonitorForEventsMatchingMask:(NSKeyUpMask|NSKeyDownMask)
                                           handler:block];
    
	hotkeysBound = YES;
}

-(void) releaseAllPressedTriggersWithKeyCode:(int) keyCode {
      id tmp = pressedTriggers;
      pressedTriggers = [[pressedTriggers objectsPassingTest:
                          ^BOOL (HotkeyTrigger* t,BOOL* stop){
          if([t keyCode] == keyCode){
              NSLog(@"also released %@",t);
              [t released];
              return YES; // remove trigger
          }
          return YES; // keep others
      }] mutableCopy];
      [tmp release];
}

- (void) unbindHotkeys: (BOOL) all {
    NSLog(@"unbind hotkeys");
     
    [self deactivateTriggers];
	
    [NSEvent removeMonitor:globalMonitor];
	hotkeysBound = NO;
}


- (BOOL) shouldHaveHotkeys {
	
	NSDictionary *activeApp = [[NSWorkspace sharedWorkspace] activeApplication];
	NSString *activeAppName = (NSString *)[activeApp objectForKey:@"NSApplicationName"];
	NSLog(@"The active app is %@", activeAppName);
	
	// TODO: optional add NSArray for multiple apps other than Live to have hotkeys enabled
	return [activeAppName isEqualToString: @"Live"];
}





- (void) checkFrontAppForHotkeys {
	if ([self shouldHaveHotkeys]) {
		if (!hotkeysBound) {
			[self bindHotkeys];
		}
	}
	else if (hotkeysBound) {
		[self unbindHotkeys:TRUE];
	}
}

- (void) foremostAppActivated: (NSNotification*) noti{
    [self checkFrontAppForHotkeys];
}

- (void) awakeFromNib
{
	// event-handler for front app switched
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(foremostAppActivated:) name:NSWorkspaceDidActivateApplicationNotification object:nil];

	// read default Key-Commands and Actions from MIDIActions.plist
	NSString *errorDesc = nil;
	NSPropertyListFormat format;
	NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"MIDIActions" ofType:@"plist"];
	NSData *plistXML = [[NSFileManager defaultManager] contentsAtPath:plistPath];
	NSDictionary *hotKeyActions = (NSDictionary *)[NSPropertyListSerialization
		propertyListFromData:plistXML
        mutabilityOption:NSPropertyListMutableContainersAndLeaves
		format:&format
		errorDescription:&errorDesc];
	
	if (!hotKeyActions) {
        NSLog(@"%@", errorDesc);
		[errorDesc release];
	}
	
	
	NSEnumerator* actionsIterator = [[hotKeyActions allKeys] objectEnumerator];
	id key;
	while( key = [actionsIterator nextObject])
	{
		//NSLog(@"key: %@, value: %@", key, [hotKeyActions objectForKey:key]);
		NSDictionary *actionSettings = [hotKeyActions objectForKey:key];
		NSDictionary *hotkeySettings = [actionSettings objectForKey:@"hotkey"];
		
		int keyCode = [[hotkeySettings valueForKey:@"keyCode"] intValue];
		//NSLog(@"++ Register key-combo for: %d", keyCode);
		int keyCombo = 0;
		if ([[hotkeySettings valueForKey:@"cmdKey"] boolValue]) {
			keyCombo+= cmdKey;
		}
		if ([[hotkeySettings valueForKey:@"controlKey"] boolValue]) {
			keyCombo+= controlKey;
		}
		if ([[hotkeySettings valueForKey:@"optionKey"] boolValue]) {
			keyCombo+= optionKey;
		}
		if ([[hotkeySettings valueForKey:@"shiftKey"] boolValue]) {
			keyCombo+= shiftKey;
		}
		if ([[hotkeySettings valueForKey:@"alphaLock"] boolValue]) {
			keyCombo+= alphaLock;
		}
		
		
		// setup all the Hotkeys based on those actions
		HotkeyAction *hotkeyAction = nil;
		int channel = 0; // default channel is 0 (with channels ranging from 0 to 15)
		if ([[actionSettings objectForKey:@"channel"] boolValue]) {
			channel = [[actionSettings objectForKey:@"channel"] intValue];
			if (channel < 0 || channel > 15) {
				channel = 0;
				NSLog(@"channel not in range 0-15, set to default 0");
			}
		}
		if ([[actionSettings valueForKey:@"cc"] boolValue]) {
			hotkeyAction = [[HotkeyActionRepeat alloc] init];
			
			// binary addition: CC-Status (first byte) = 0xB; Channel (second byte) = 0-15 => send CC on first channel: 0x<status>0 | <channel>
			[hotkeyAction setChannel:0xB0 | channel];
			[hotkeyAction setKey:[[actionSettings valueForKey:@"cc"] intValue]];
			
			[hotkeyAction setValue:[[actionSettings valueForKey:@"value"] intValue]];
		}
		else {
			hotkeyAction = [[HotkeyActionRetrigger alloc] init];
			
			[hotkeyAction setChannel:0x90 | channel];
			[hotkeyAction setKey:[[actionSettings valueForKey:@"note"] intValue]];
			[hotkeyAction setValue:127];
		}
		[hotkeyAction setController:midiController];
		
        HotkeyTrigger *hotkeyTrigger = nil;
		NSString *hotkeyIdKeyCombo = [NSString stringWithFormat: @"0x%X", keyCombo*0x100 | keyCode];
		NSNumber *hotkeyIdNumber = [hotkeyIdexesByKeyCombo objectForKey:hotkeyIdKeyCombo];
		if (hotkeyIdNumber == nil) {
			// new hotkeyId at the end of hotkeys-array			
			hotkeyIdNumber = [[NSNumber alloc] initWithInt:[hotkeys count]];
			[hotkeyIdexesByKeyCombo setObject:hotkeyIdNumber forKey:hotkeyIdKeyCombo];
			
			hotkeyTrigger = [[HotkeyTrigger alloc] init];
			[hotkeyTrigger setKeyCombo:keyCombo];
			[hotkeyTrigger setKeyCode:keyCode];
			[hotkeyTrigger setHotkeyId:[hotkeyIdNumber intValue]];
			
			[hotkeys addObject:hotkeyTrigger];
		}
		else {
			hotkeyTrigger = (HotkeyTrigger *)[hotkeys objectAtIndex:[hotkeyIdNumber intValue]];
		}
		[hotkeyTrigger addAction:hotkeyAction];
		
	}
	
    
    if (checkAccessibility()) {
        NSLog(@"Accessibility Enabled");
    }
    else {
        // TODO alert
        NSLog(@"Accessibility Disabled");
    }
    
	// check which app is in front and if needed, bind hotkeys
	[self checkFrontAppForHotkeys];
    
}



// 10.9+ only, see this url for compatibility:
// http://stackoverflow.com/questions/17693408/enable-access-for-assistive-devices-programmatically-on-10-9
BOOL checkAccessibility()
{
    NSDictionary* opts = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    return AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts);
}

- (NSString*) hotKeyComboId:(int)keyCode flags:(NSEventModifierFlags)flags {
    
    int keyCombo = 0;
    if ((flags & NSEventModifierFlagCommand)==NSEventModifierFlagCommand) {
        keyCombo+= cmdKey;
    }
    if ((flags & NSEventModifierFlagControl)==NSEventModifierFlagControl) {
        keyCombo+= controlKey;
    }
    if ((flags & NSEventModifierFlagOption)==NSEventModifierFlagOption) {
        keyCombo+= optionKey;
    }
    if ((flags & NSEventModifierFlagShift)==NSEventModifierFlagShift) {
        keyCombo+= shiftKey;
    }
    if ((flags & NSEventModifierFlagCapsLock)==NSEventModifierFlagCapsLock) {
        keyCombo+= alphaLock;
    }
    
    return [NSString stringWithFormat: @"0x%X", keyCombo*0x100 | keyCode];
}

@end
