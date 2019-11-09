//
//  TrayMenu.h
//  Kimidi
//
//  Created by Richard Schreiber on 28.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface TrayMenu : NSObject <NSApplicationDelegate> {
    @private
        NSStatusItem *_statusItem;
}
@end
