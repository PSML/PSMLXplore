//
//  AppDelegate.h
//  PSMLXplore
//
//  Created by Jonathan Appavoo on 2/13/14.
//  Copyright (c) 2014 Jonathan Appavoo. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSTextField *inspectorOriginX;
@property (weak) IBOutlet NSTextField *inspectorOriginY;
@property (strong) IBOutlet NSWindow *window;

- (void)scrollViewContentBoundsDidChange:(NSNotification *)notification;

@end
