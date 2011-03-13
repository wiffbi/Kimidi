//
//  HotKeyRepeat.h
//  Kimidi
//
//  Created by Studio on 14.05.10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HotKey.h"


@interface HotKeyRepeat : HotKey {
	NSTimer* timer;
}
- (void) executeRepeated;
@end
