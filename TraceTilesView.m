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
#include "highlight.h"
#include "AppDelegate.h"

extern AppDelegate *theAppDelegate;

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

extern CALayer *highlightLayer;

-(void)mouseMoved:(NSEvent *)theEvent {
   NSPoint event_location = [theEvent locationInWindow];
   NSPoint point = [self convertPoint:event_location fromView:nil];

   uint64_t x = (uint64_t)point.x;

    if (x<data.maxValue) {
      unsigned short y=((unsigned short *)data.mem)[x];
      highlight(x,y);
    }
    
//    NSLog(@"mouseMoved ev: %f,%f data: %llu,%hu w:%f,%f",
//          event_location.x, event_location.y,
//          x,y,
//          theHighlight.rect.origin.x, theHighlight.rect.origin.y);
          
}

-(void)mouseDragged:(NSEvent *)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSLog(@"mouseDragged %f,%f",event_location.x, event_location.y);
}

-(void)mouseUp:(NSEvent *)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSLog(@"mouseUp %f,%f",event_location.x, event_location.y);
}

uint64_t clickx = 0;
- (void)mouseDown:(NSEvent *)theEvent {
    NSPoint event_location = [theEvent locationInWindow];
    NSPoint point = [self convertPoint:event_location fromView:nil];
    clickx = (uint64_t)point.x;
    [theAppDelegate.inspectorClickXLabel setIntegerValue:(NSInteger)clickx];
    [theAppDelegate.inspectorClickYLabel setIntValue:(int)((unsigned short *)data.mem)[clickx]];
}

extern void ann_region(NSView *view,
                       uint64_t x, uint64_t y, uint64_t width, uint64_t height,
                       CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha,
                       char *label, char *cmd);

extern void ann_vline(NSView *view,
                      int64_t x,
                      CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha,
                      char *label, char *cmd);

extern void ann_hline(NSView *view,
                      int64_t x, int64_t y, int64_t width,
                      CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha,
                      char *label, char *cmd);

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
    } else if ([characters isEqual:@"i"])  {
        char cmd[128];
        handled = YES;
        unsigned short y=((unsigned short *)data.mem)[clickx];
        snprintf(cmd, 128, "open http://localhost:8000/sft?-s%hu%%20-N",y);
        system(cmd);
    } else if ([characters isEqual:@"h"])  {
        handled = YES;
        BOOL state = [theAppDelegate.window acceptsMouseMovedEvents];
        if (state==YES) [theAppDelegate.window setAcceptsMouseMovedEvents:NO];
        else [theAppDelegate.window setAcceptsMouseMovedEvents:YES];
     } else if ([characters isEqual:@"r"]) {
        handled = YES;
        ann_region(self, 800, 0, 3000, data.maxValue, 0.0, 1.0, 0, 0.25, "Rectangle", "r 800 0 3000 max 0 1 0 0.25 Rectangle");
        [annLayer setNeedsDisplay];
    } else if ([characters isEqual:@"m"]) {
        // Yes, it is
        handled = YES;
        NSPoint pt = {data.numValues/2, 0 };
        [scrollView.contentView scrollToPoint:pt];
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
        [scrollView.contentView scrollToPoint:pt];
    } else  if ([characters isEqual:@"e"]) {
        // Yes, it is
        handled = YES;
        NSPoint pt = {data.numValues, 0};
        [scrollView.contentView scrollToPoint:pt];
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
