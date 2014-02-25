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

extern void ann_region(NSView *view,
                       uint64_t x, uint64_t y, uint64_t width, uint64_t height,
                       CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha,
                       char *label,
                       char *cmd);

extern void ann_vline(NSView *view,
                      int64_t x,
                      CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha,
                      char *label,
                      char *cmd);

extern int drawAnn;
extern TraceTilesLayer *annLayer;
extern TraceTilesLayer *dataLayer;
extern NSScrollView *scrollView;
extern TraceTilesView *tilesView;


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
        ann_vline(self, 200, 0,0,1,0.10, "Middle", "v 200 0 0 1 .10 Middle");
        [annLayer setNeedsDisplay];
    } else if ([characters isEqual:@"r"]) {
        handled = YES;
        ann_region(self, 800, 0, 3000, data.maxValue, 0.0, 1.0, 0, 0.25, "Rectangle", "r 800 0 3000 max 0 1 0 0.25 Rectangle");
        [annLayer setNeedsDisplay];
    } else if ([characters isEqual:@"m"]) {
        // Yes, it is
        handled = YES;
        NSPoint pt = {data.numValues/2, 0 };
        [self scrollPoint:pt];
          NSLog(@"ms: %f %f", pt.x, pt.y);
    } else if ([characters isEqual:@"f"]) {
        handled = YES;
        [scrollView setMagnification:1.0];
    //    [self resetScaling];
    } else if ([characters isEqual:@"v"]) {
            //        NSSize newSize;
        handled = YES;
        CGFloat mag = self.window.frame.size.height / data.maxValue;
        [scrollView setMagnification:mag];
    } else if ([characters isEqual:@"q"]) {
        handled = YES;
        NSLog(@"1/4 scale");
        [scrollView setMagnification:0.25];
    } else  if ([characters isEqual:@"b"]) {
        // Yes, it is
        handled = YES;
        NSPoint pt = {0,0};
        [self scrollPoint:pt];
    } else  if ([characters isEqual:@"e"]) {
        // Yes, it is
        handled = YES;
        NSPoint pt = {data.numValues, 0};
        [self scrollPoint:pt];
    } else if ([characters isEqual:@"+"]) {
        setPoint(self, getPointDiameter()+2);
        [dataLayer setNeedsDisplay];
        [annLayer setNeedsDisplay];
    } else if ([characters isEqual:@"="]) {
        setPoint(self, DEFAULT_POINTSIZE);
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
