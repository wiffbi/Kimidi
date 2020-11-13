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

- (void) openWebsite:(id)sender {
  NSURL *url = [NSURL URLWithString:@"https://github.com/matatata/Kimidi/blob/master/README.md"];
  [[NSWorkspace sharedWorkspace] openURL:url];
}


- (void) actionQuit:(id)sender {
  [NSApp terminate:sender];
}

- (NSMenu *) createMenu {

  NSZone *menuZone = [NSMenu menuZone];
  NSMenu *menu = [[NSMenu allocWithZone:menuZone] init];
  NSMenuItem *menuItem;

  menuItem = [menu addItemWithTitle:@"Visit Website"
                      action:@selector(openWebsite:)
                      keyEquivalent:@""];
  [menuItem setTarget:self];

  // Add Separator
  [menu addItem:[NSMenuItem separatorItem]];
  
  // Add Quit Action
  menuItem = [menu addItemWithTitle:@"Quit Kimidi"
                      action:@selector(actionQuit:)
                      keyEquivalent:@""];
    
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
  
    
  [[[AppController alloc] init] awakeFromNib];
  
  
}



@end
