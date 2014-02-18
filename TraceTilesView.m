//
//  TraceTilesView.m
//  PSMLXplore
//
//  Created by Jonathan Appavoo on 2/18/14.
//  Copyright (c) 2014 Jonathan Appavoo. All rights reserved.
//

#import "TraceTilesView.h"
#import "TraceTilesLayer.h"

@implementation TraceTilesView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
         NSLog(@"TraceTilesView initWithFrame: HERE I AM");
    }
    return self;
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint point = [self convertPoint:event_location fromView:nil];
    CGPoint point2 = [self convertPointToBacking:point];
    NSLog(@"mouseDown: epoint: %f,%f lpoint:%f,%f bpoint:%f,%f", event_location.x, event_location.y,
            point.x, point.y,
            point2.x, point2.y);
}


- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
    NSLog(@"drawRect: HERE I AM");
}

@end
