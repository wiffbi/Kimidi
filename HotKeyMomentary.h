//
//  HotKeyMomentary.h
//  Kimidi
//
//  Created by Richard Schreiber on 29.08.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HotKey.h"


@interface HotKeyMomentary : HotKey {
	NSTimer* timer;
	bool isHold;
}

- (void) setIsHold;

@end
