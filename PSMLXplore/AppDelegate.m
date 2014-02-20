//
//  AppDelegate.m
//  PSMLXplore
//
//  Created by Jonathan Appavoo on 2/13/14.
//  Copyright (c) 2014 Jonathan Appavoo. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "TraceTilesLayer.h"
#import "traceTilesView.h"

#include <unistd.h>
#include <fcntl.h>
#include <dirent.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <stdio.h>
#include <math.h>

struct Data {
    void *mem;
    off_t filesize;
    uint64 numValues;
};
static struct Data data;

static void mapData() {
    int fd = open("/tmp/data", O_RDONLY);
    fcntl(fd, F_NOCACHE, 1);
    struct stat stats;
    fstat(fd, &stats);
    data.filesize = stats.st_size;
    data.numValues = data.filesize/2;
    data.mem = mmap(0, data.filesize, PROT_READ, MAP_PRIVATE, fd, 0);
//    for (int i=0; i<100; i++) {
//        NSLog(@"%d=%hu",i, ((unsigned short *)data.mem)[i]);
//   }
}



@implementation AppDelegate

- (void)awakeFromNib {
    
    // Note that as the owner you will get an awake from nib every time a new nib is instatiated.
    // It is important to be aware of this and to make sure you accidentally don't repeat your setup twice.
    static NSInteger awakeFromNibCount = 0;
    NSLog(@"awakeFromNib called %ld", (long)++awakeFromNibCount);
}

- (void)scrollViewContentBoundsDidChange:(NSNotification *)notification
{
 //   NSLog(@"scrollViewContentsBoundsDidChange");
    // get the changed content view from the notification
    NSClipView *changedContentView=[notification object];
    
    // get the origin of the NSClipView of the scroll view that
    // we're watching
    NSPoint changedBoundsOrigin = [changedContentView documentVisibleRect].origin;
    int64_t x = changedBoundsOrigin.x;
//    NSLog(@"origin.x=%f origin.y=%f", changedBoundsOrigin.x, changedBoundsOrigin.y);
    if (x<0) x=0;
    if (x<data.numValues) {
      [_inspectorOriginX setIntegerValue:(NSInteger)x];
      [_inspectorOriginY setIntValue:(int)((unsigned short *)data.mem)[x]];
    }
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    mapData();
    
    NSLog(@"Data Mapped %lld", data.filesize);
    

    NSSize wcsize;
    wcsize.height = 200;
    wcsize.width = 1000;
    
    off_t imageWidth = data.filesize/2;
    int imageHeight = 5000;
    
    CGRect scrollRect =  CGRectMake(0, 0, wcsize.width, wcsize.height);
    
    NSScrollView *scrollView = [[NSScrollView alloc] initWithFrame:scrollRect];
 //   [scrollView setFrameSize:CGSizeMake(imageWidth, imageHeight)];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setBorderType:NSNoBorder];
    scrollView.backgroundColor = [NSColor whiteColor];
    [scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    
    CGRect bigImageRect = CGRectMake(0, 0, imageWidth, imageHeight);
    
    TraceTilesView *tilesView = [[TraceTilesView alloc] initWithFrame:bigImageRect];
    [tilesView setWantsLayer:YES];
    TraceTilesLayer *hostedLayer = [TraceTilesLayer layer];
    [tilesView setLayer:hostedLayer];
  //  [tilesView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    tilesView.myScrollView = scrollView;
 
    [scrollView setDocumentView:tilesView];
    [self.window setContentView:scrollView];
    [self.window setContentSize:wcsize];
    [self.window acceptsMouseMovedEvents];
    [self.window setAcceptsMouseMovedEvents:YES];
    
    [[scrollView contentView] setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewContentBoundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:[scrollView contentView]];

    hostedLayer.delegate = self;
    // To provide multiple levels of content, you need to set the levelsOfDetail property.
	// For this sample, we have 5 levels of detail (1/4x - 4x).
	// By setting the value to 5, we establish that we have levels of 1/16x - 1x (2^-4 - 2^0)
	// we use the levelsOfDetailBias property we shift this up by 2 raised to the power
	// of the bias, changing the range to 1/4-4x (2^-2 - 2^2).
	hostedLayer.levelsOfDetail = 1;
	hostedLayer.levelsOfDetailBias = 1;

    NSLog(@"TraceTilesLayer %f", [TraceTilesLayer fadeDuration]);
    NSLog(@"hostedLayer tileSize %f %f", hostedLayer.tileSize.width, hostedLayer.tileSize.height);
    
    hostedLayer.backgroundColor = [NSColor clearColor].CGColor;
    hostedLayer.borderColor = [NSColor blackColor].CGColor;
    hostedLayer.borderWidth = 0.0;
    hostedLayer.frame = CGRectMake(0.0, 0, imageWidth, imageHeight);
    hostedLayer.contentsScale=1.0;
    
	// Layers start life validated (unlike views).
	// We request that the layer have its contents drawn so that it can display something.
	[hostedLayer setNeedsDisplay];
    
 }

- (void)dealloc
{
    NSLog(@"AppDelegate dalloc");
}

-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
//    CGContextSaveGState(context);
//    CGContextScaleCTM(context, 0.2, 0.2);
    CGRect bounds = CGContextGetClipBoundingBox(context);
//    NSLog(@"drawLayer inContext: Called x:%f y:%f w:%f h%f", bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
	CGRect myRect;
    //    myRect.origin.y=bounds.size.height/2;
    myRect.size.height=9; myRect.size.width=9;
    //myRect.size.height=1; myRect.size.width=1;
    int x, xstart=(int)bounds.origin.x,
        xend = bounds.origin.x + bounds.size.width + 4;
    if (xstart!=0) xstart-=4; // redraw overlapping points
    
    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
    for (x=xstart; x<xend; x++) {
        myRect.origin.x = x-4;
        if (x<data.numValues) {
            myRect.origin.y= (((unsigned short *)data.mem)[x])-4;
            CGContextFillEllipseInRect(context, myRect);
        }
    }
//    CGContextRestoreGState(context);
}



#if 0
- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    
 	CGRect bounds = CGContextGetClipBoundingBox(context);

//    NSLog(@"o.x=%f o.y=%f o.w=%f o.h=%f",bounds.origin.x, bounds.origin.y, bounds.size.width, bounds.size.height);
}
#endif
@end
