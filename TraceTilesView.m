//
//  TraceTilesView.m
//  PSMLXplore
//
//  Created by Jonathan Appavoo on 2/18/14.
//  Copyright (c) 2014 Jonathan Appavoo. All rights reserved.
//

#import "TraceTilesView.h"
#import "TraceTilesLayer.h"
#include "data.h"
#include "thepoint.h"

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

- (BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)mouseMoved:(NSEvent *)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSLog(@"mouseMoved %f,%f",event_location.x, event_location.y);
}

-(void)mouseDragged:(NSEvent *)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSLog(@"mouseDragged %f,%f",event_location.x, event_location.y);
}

-(void)mouseUp:(NSEvent *)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSLog(@"mouseUp %f,%f",event_location.x, event_location.y);
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint point = [self convertPoint:event_location fromView:nil];
    CGPoint point2 = [self convertPointToBacking:point];
    NSLog(@"mouseDown: epoint: %f,%f lpoint:%f,%f bpoint:%f,%f", event_location.x, event_location.y,
            point.x, point.y,
            point2.x, point2.y);
    
 

}

- (void)magnifyWithEvent:(NSEvent *)event {
    NSLog(@"Magnification value is %f", [event magnification]);
    NSSize newSize;
    newSize.height = self.frame.size.height * ([event magnification] + 1.0);
    newSize.width = self.frame.size.width * ([event magnification] + 1.0);
    [self setFrameSize:newSize];
}

extern int drawAnn;
extern TraceTilesLayer *annLayer;
extern TraceTilesLayer *dataLayer;
extern NSScrollView *scrollView;

- (void)keyDown:(NSEvent *)theEvent {
    NSLog(@"keyDown");
    BOOL handled = NO;
    NSString  *characters;
    
    // get the pressed key
    characters = [theEvent charactersIgnoringModifiers];
    
    // is the "r" key pressed?
    // is the "r" key pressed?
    if ([characters isEqual:@"a"]) {
        // Yes, it is
        handled = YES;
        drawAnn = 1;
        [annLayer setNeedsDisplay];
      } else if ([characters isEqual:@"m"]) {
        // Yes, it is
        handled = YES;
        // test of programmatic scrolling
        NSView *dv = [scrollView documentView];
        NSPoint mid = {data.numValues/2, 0 };
  //      mid.x = [dv frame].size.width/2;
//        mid.y = 0;
        [dv scrollPoint:mid];
    } else  if ([characters isEqual:@"b"]) {
        // Yes, it is
        handled = YES;
        // test of programmatic scrolling
        NSView *dv = [scrollView documentView];
        NSPoint pt = {0,0};
        [dv scrollPoint:pt];
    } else  if ([characters isEqual:@"e"]) {
        // Yes, it is
        handled = YES;
        // test of programmatic scrolling
        NSView *dv = [scrollView documentView];
        NSPoint pt = {data.numValues - 1, 0};
//        pt.x = [dv frame].size.width;
//        pt.y = 0;
        [dv scrollPoint:pt];
    } else if ([characters isEqual:@"+"]) {
        setPoint(self, getPointDiameter()+2);
        [dataLayer setNeedsDisplay];
        [annLayer setNeedsDisplay];
    } else if ([characters isEqual:@"="]) {
        setPoint(self, 9);
        [dataLayer setNeedsDisplay];
        [annLayer setNeedsDisplay];
    } else if ([characters isEqual:@"-"]) {
        setPoint(self, getPointDiameter()-2);
        [dataLayer setNeedsDisplay];
        [annLayer setNeedsDisplay];
    }
    if (!handled)
        [super keyDown:theEvent];
}

- (void)drawRect:(NSRect)dirtyRect
{
	[super drawRect:dirtyRect];
	
    // Drawing code here.
    NSLog(@"drawRect: HERE I AM");
}

@end
