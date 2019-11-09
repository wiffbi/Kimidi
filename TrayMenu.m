//
//  TrayMenu.m
//  Kimidi
//
//  Created by Richard Schreiber on 28.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TrayMenu.h"
#import "AppController.h"


@implementation TrayMenu
/* not possible with a Menubar item only
- (void) init
{
	NSLog(@"init");
}
*/

- (void) openWebsite:(id)sender {
  NSURL *url = [NSURL URLWithString:@"http://stc.wiffbi.com/"];
  [[NSWorkspace sharedWorkspace] openURL:url];
  //[url release];
}
/*
- (void) openFinder:(id)sender {
  [[NSWorkspace sharedWorkspace] launchApplication:@"Finder"];
}
*/

- (void) actionAbout:(id)sender {
	[NSApp orderFrontStandardAboutPanel:sender];
}

- (void) actionQuit:(id)sender {
  [NSApp terminate:sender];
}

- (NSMenu *) createMenu {

  NSZone *menuZone = [NSMenu menuZone];
  NSMenu *menu = [[NSMenu allocWithZone:menuZone] init];
  NSMenuItem *menuItem;

/*
  // Add To Items
  menuItem = [[NSMenuItem alloc] initWithTitle:@"transforms global hotkeys to MIDI \nmessages for Ableton Live track control"
                      action:NULL
                      keyEquivalent:@""];
  [menuItem setEnabled:false];
  [menu addItem:menuItem];
*/  
	// Add To Items
	menuItem = [menu addItemWithTitle:@"About Kimidi"
							   action:@selector(actionAbout:)
						keyEquivalent:@""];
	[menuItem setTarget:self];
  // Add To Items
  menuItem = [menu addItemWithTitle:@"Visit Website"
                      action:@selector(openWebsite:)
                      keyEquivalent:@""];
  [menuItem setTarget:self];
  /*
  menuItem = [menu addItemWithTitle:@"Open Finder"
                      action:@selector(openFinder:)
                      keyEquivalent:@""];
  [menuItem setTarget:self];
  */
  // Add Separator
  [menu addItem:[NSMenuItem separatorItem]];
  
  // Add Quit Action
  menuItem = [menu addItemWithTitle:@"Quit Kimidi"
                      action:@selector(actionQuit:)
                      keyEquivalent:@""];
  //[menuItem setToolTip:@"Quit"];
  [menuItem setTarget:self];

  return menu;
}

- (void) applicationDidFinishLaunching:(NSNotification *)notification {
  NSMenu *menu = [self createMenu];

  _statusItem = [[[NSStatusBar systemStatusBar]
                  statusItemWithLength:NSSquareStatusItemLength] retain];
  [_statusItem setMenu:menu];
  [_statusItem setHighlightMode:YES];
  [_statusItem setToolTip:@"Kimidi\nTransforms global hotkeys to MIDI messages\nfor selected track control in Ableton Live"];
  [_statusItem setImage:[NSImage imageNamed:@"menubar.png"]];
  [_statusItem setAlternateImage:[NSImage imageNamed:@"menubar-hover.png"]];

  [menu release];
    
  [self testAccessibility];
  
  [[[AppController alloc] init] awakeFromNib];
}


- (void) testAccessibility {
    
    NSDictionary* opts = @{(__bridge id)kAXTrustedCheckOptionPrompt: @YES};
    BOOL enabled = AXIsProcessTrustedWithOptions((__bridge CFDictionaryRef)opts);
    
    if (enabled) {
        NSLog(@"Accessibility Enabled");
    }
    else {
        NSLog(@"Accessibility Disabled");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Message text."];
        [alert setInformativeText:@"Informative text."];
        [alert addButtonWithTitle:@"Cancel"];
        [alert addButtonWithTitle:@"Ok"];
        [alert runModal];
    }
}


@end
