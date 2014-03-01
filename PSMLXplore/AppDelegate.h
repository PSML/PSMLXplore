//
//  AppDelegate.h
//  PSMLXplore
//
//  Created by Jonathan Appavoo on 2/13/14.
//  Copyright (c) 2014 Jonathan Appavoo. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AppDelegate : NSObject <NSApplicationDelegate,NSTableViewDataSource,NSTableViewDelegate>

@property (weak) IBOutlet NSTextField *inspectorOriginX;
@property (weak) IBOutlet NSTextField *inspectorOriginY;
@property (strong) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTableView *annTable;
@property (strong) NSMutableArray * annCmdArray;
@property (strong)NSMutableData *annCmdData;
@property (weak) IBOutlet NSTextField *inspectorClickXLabel;
@property (weak) IBOutlet NSTextField *inspectorClickYLabel;

- (void)scrollViewContentBoundsDidChange:(NSNotification *)notification;
- (int)numberOfRowsInTableView:(NSTableView *)tbvj;
- (id) tableView:(NSTableView *)tbv objectValueForTableColumn:(NSTableColumn *)tc
             row:(int)row;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;

@end
