//
//  main.m
//  Kimidi
//
//  Created by Richard Schreiber on 28.07.09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TrayMenu.h"
/*
int main(int argc, char *argv[])
{
    return NSApplicationMain(argc,  (const char **) argv);
}
*/
int main(int argc, char *argv[]) {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [NSApplication sharedApplication];

    TrayMenu *menu = [[TrayMenu alloc] init];
    [NSApp setDelegate:menu];
    [NSApp run];

    [pool release];
    return EXIT_SUCCESS;
}