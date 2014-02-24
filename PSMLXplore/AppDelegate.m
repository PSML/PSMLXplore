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
#include "data.h"
#include "thepoint.h"

struct Data data = { NULL, 0, 0 };

void mapData(char *path, uint64 max) {
    int fd = open(path, O_RDONLY);
    fcntl(fd, F_NOCACHE, 1);
    struct stat stats;
    fstat(fd, &stats);
    data.filesize = stats.st_size;
    data.numValues = data.filesize/2;
    data.maxValue = max;
    data.mem = mmap(0, data.filesize, PROT_READ, MAP_PRIVATE, fd, 0);
}

struct ThePoint thePoint = { nil, 0, 0 };

void
setPoint(NSView *view, unsigned int diameter)
{
    CGRect ptRect;
    
    if (thePoint.layer != nil) {
        CGLayerRelease(thePoint.layer);
    }
    
    if (diameter<3) diameter=3;
    if ((diameter & 0x1) == 0) diameter++;
    
    thePoint.diameter = diameter;
    thePoint.radius = diameter / 2;
    
    ptRect.origin.x = 0; ptRect.origin.y = 0;
    ptRect.size.height = ptRect.size.width = diameter;
    
    [view lockFocus];
    CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]
                                          graphicsPort];
    thePoint.layer = CGLayerCreateWithContext(context,ptRect.size,NULL);
    CGContextRef ptCtx = CGLayerGetContext (thePoint.layer);
    
    CGContextSetRGBFillColor (ptCtx, 0, 0, 0, 0);
    CGContextFillRect (ptCtx, ptRect);
    CGContextSetRGBFillColor(ptCtx, 1.0, 0.0, 0.0, 1.0);
    CGContextFillEllipseInRect(ptCtx, ptRect);
    
    [view unlockFocus];
    NSLog(@"setPoint diameter:%u radius:%u", thePoint.diameter, thePoint.radius);
}

@interface NULLDraw : NSObject
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context;
@end

@implementation NULLDraw
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
}
@end

NULLDraw *nullDraw = nil;
@interface AnnotationsDelegate : NSObject
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context;
@end



NSScrollView *scrollView = nil;
TraceTilesView *tilesView = nil;
TraceTilesLayer *dataLayer = nil;
TraceTilesLayer *annLayer = nil;

#ifdef DATA_PRE_RENDER
CGLayerRef *dataLayers = NULL;
char *dataLayerRendered = NULL;
#endif

AnnotationsDelegate *theAnnotationsDelegate = nil;
CFMutableDictionaryRef annLayers = nil;

int drawAnn = 0;

// TILE WIDTH 1024
#define TILEWIDTH_LOG2BITS 10
#define TILEWIDTH (1<<10)
CGSize tileSize;


void
ann_point(int64_t x, int64_t y, RGBColor color, char *label)
{

}

void
ann_vline(int64_t x, int64_t len, RGBColor color, char *label)
{
    
    
}

void
ann_hline(int64_t y, int64_t len, RGBColor color, char *label)
{

}

void
ann_region(NSView *view, uint64_t x, uint64_t y, uint64_t width, uint64_t height, CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha, char *label)
{
    uint64_t startTile = x >> TILEWIDTH_LOG2BITS;
    uint64_t endTile = (x + width) >> TILEWIDTH_LOG2BITS;
    CGLayerRef tileLayer;
    CGContextRef layerCtx;
    
 //   CGRect annRect = CGRectMake (dataXToViewX(x,view.frame.size.width),
//                                 dataYToViewY(y,view.frame.size.height),
//                                 dataXToViewX(width,view.frame.size.width),
//                                 dataYToViewY(height,view.frame.size.height));

    CGRect annRect = CGRectMake(x,y,width,height);
    CGRect tileRect = CGRectMake(0,0,tileSize.width,tileSize.height);
    CGRect annTileIntersect;
    
    [view lockFocus];
    for (uint64_t i=startTile; i<=endTile; i++) {
        tileRect.origin.x = i << TILEWIDTH_LOG2BITS;
        annTileIntersect = CGRectIntersection(annRect, tileRect);
        tileLayer = (CGLayerRef)CFDictionaryGetValue(annLayers, (void *)i);
        if (tileLayer==NULL) {
          CGContextRef context = (CGContextRef)[[NSGraphicsContext currentContext]
                                                  graphicsPort];
          tileLayer = CGLayerCreateWithContext(context,tileSize,NULL);
          layerCtx = CGLayerGetContext (tileLayer);
          CGContextClearRect(layerCtx, CGRectMake(0,0,tileSize.width,tileSize.height));
          CFDictionarySetValue(annLayers, (void *)i, tileLayer);
        }
        layerCtx = CGLayerGetContext (tileLayer);
        CGContextSetRGBFillColor(layerCtx, red, green, blue, alpha);
        annTileIntersect.origin.x -= tileRect.origin.x;
        CGContextFillRect(layerCtx,annTileIntersect);

    }
    [view unlockFocus];
}


@implementation AnnotationsDelegate
-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context {
    CGRect bounds = CGContextGetClipBoundingBox(context);
    uint64_t i = ((uint64_t)bounds.origin.x >> TILEWIDTH_LOG2BITS);
    
//    CGAffineTransform ctm = CGContextGetCTM(context);
//    NSLog(@"Ann: drawLayer bounds.x=%f CTM is: %g %g %g %g %g %g", bounds.origin.x, ctm.a, ctm.b, ctm.c, ctm.d, ctm.tx, ctm.ty);
  
    CGLayerRef tileLayer = (CGLayerRef)CFDictionaryGetValue(annLayers, (void *)i);
    if (tileLayer) {
        CGContextBeginTransparencyLayer (context, NULL);
        CGContextDrawLayerAtPoint(context, CGPointMake(bounds.origin.x,0), tileLayer);
        CGContextEndTransparencyLayer (context);
    }
//    if (drawAnn) {
//        NSLog(@"drawing Annoation");
//        drawAnnOnTransparencyLayer(context, thePoint.diameter);
//    }
}
@end



@implementation AppDelegate

- (void)awakeFromNib {
    
    // Note that as the owner you will get an awake from nib every time a new nib is instatiated.
    // It is important to be aware of this and to make sure you accidentally don't repeat your setup twice.
    static NSInteger awakeFromNibCount = 0;
    NSLog(@"awakeFromNib called %ld", (long)++awakeFromNibCount);
}

- (void)scrollViewContentBoundsDidChange:(NSNotification *)notification
{
     // get the changed content view from the notification
    NSClipView *changedContentView=[notification object];
    
    // get the origin of the NSClipView of the scroll view that
    // we're watching
    NSPoint changedBoundsOrigin = [changedContentView documentVisibleRect].origin;
    int64_t x = changedBoundsOrigin.x;

    if (x<0) x=0;
    if (x<data.numValues) {
      [_inspectorOriginX setIntegerValue:(NSInteger)x];
      [_inspectorOriginY setIntValue:(int)((unsigned short *)data.mem)[x]];
    }
 //   [annLayer setNeedsDisplay];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
   // do global initializations
    mapData("/tmp/data", 2823);
    
    NSLog(@"Data Mapped %lld", data.filesize);
   
    nullDraw = [NULLDraw alloc];

#ifdef DATA_PRE_RENDER
    dataLayers = (CGLayerRef *)calloc(data.numValues, sizeof(CGLayerRef));  // automatically zeroed
    dataLayerRendered = (char *)calloc(data.numValues, sizeof(char)); // automatically zeroed
#endif
    annLayers = CFDictionaryCreateMutable(NULL, (data.numValues >> TILEWIDTH_LOG2BITS)+1, NULL, &kCFTypeDictionaryValueCallBacks);
    
    NSSize wcsize;
    wcsize.height = 400;
    wcsize.width = 1440;
    
    CGRect scrollRect =  CGRectMake(0, 0, wcsize.width, wcsize.height);
    
    scrollView = [[NSScrollView alloc] initWithFrame:scrollRect];
    [scrollView setHasVerticalScroller:YES];
    [scrollView setHasHorizontalScroller:YES];
    [scrollView setBorderType:NSNoBorder];
    scrollView.backgroundColor = [NSColor whiteColor];
    [scrollView setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    scrollView.allowsMagnification=YES;
    scrollView.minMagnification = wcsize.height/data.maxValue - 0.10;
    [scrollView setWantsLayer:YES];
    [scrollView setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
    [scrollView.contentView setWantsLayer:YES];
    [scrollView.contentView setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
    
    CGRect bigImageRect = CGRectMake(0, 0, data.numValues, data.maxValue);
    
    tilesView = [[TraceTilesView alloc] initWithFrame:bigImageRect];
    [tilesView setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
    [tilesView setWantsLayer:YES];

    dataLayer = [[TraceTilesLayer layer] init];
    theAnnotationsDelegate = [[AnnotationsDelegate alloc] init];
    annLayer = [[TraceTilesLayer alloc] init];
    
  
    // If no trace specified then these should be set to NULLDraw delegate
    dataLayer.delegate = self;
    annLayer.delegate = theAnnotationsDelegate;

    tileSize = CGSizeMake( TILEWIDTH, data.maxValue );
    [dataLayer setTileSize:tileSize];
    dataLayer.layoutManager=[CAConstraintLayoutManager layoutManager];
    dataLayer.backgroundColor = [NSColor clearColor].CGColor;
    dataLayer.borderColor = [NSColor blackColor].CGColor;
    dataLayer.borderWidth = 0.0;
    dataLayer.frame = bigImageRect;
    dataLayer.contentsScale=1.0;
    dataLayer.levelsOfDetail = 1;
	dataLayer.levelsOfDetailBias = 0;
    [dataLayer setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    
    [annLayer setTileSize:tileSize];
    annLayer.name = @"annLayer";
    annLayer.backgroundColor = [NSColor clearColor].CGColor;
    annLayer.borderColor = [NSColor blackColor].CGColor;
    annLayer.borderWidth = 0.0;
    annLayer.bounds = bigImageRect;
    annLayer.contentsScale=1.0;
    annLayer.levelsOfDetail = 1;
    annLayer.levelsOfDetailBias = 0;

    [annLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidY
                                                     relativeTo:@"superlayer"
                                                      attribute:kCAConstraintMidY]];
    [annLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintMidX
                                                     relativeTo:@"superlayer"
                                                      attribute:kCAConstraintMidX]];
    [annLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintWidth
                                                       relativeTo:@"superlayer"
                                                        attribute:kCAConstraintWidth]];
    [annLayer addConstraint:[CAConstraint constraintWithAttribute:kCAConstraintHeight
                                                       relativeTo:@"superlayer"
                                                        attribute:kCAConstraintHeight]];
    [annLayer setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    [dataLayer addSublayer:annLayer];
    
    [tilesView setLayer:dataLayer];
    
    

    [scrollView setDocumentView:tilesView];
    [self.window setContentView:scrollView];
    [self.window setContentSize:wcsize];
    [self.window acceptsMouseMovedEvents];
    //[self.window setAcceptsMouseMovedEvents:YES];
    
    NSLog(@"TraceTilesLayer %f", [TraceTilesLayer fadeDuration]);
    NSLog(@"dataLayer tileSize %f %f", dataLayer.tileSize.width, dataLayer.tileSize.height);
    NSLog(@"annLayer tileSize %f %f", annLayer.tileSize.width, annLayer.tileSize.height);

    [[scrollView contentView] setPostsBoundsChangedNotifications:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollViewContentBoundsDidChange:)
                                                 name:NSViewBoundsDidChangeNotification
                                               object:[scrollView contentView]];

    
    setPoint(tilesView, 9);
    // Layers start life validated (unlike views).
	// We request that the layer have its contents drawn so that it can display something.
	[dataLayer setNeedsDisplay];
    [annLayer setNeedsDisplay];

    NSLog(@"window: size: %f %f scrollView: %f %f tilesView: %f %f dataLayer: %f %f annLayer: %f %f",
          self.window.frame.size.width, self.window.frame.size.height,
          scrollView.frame.size.width, scrollView.frame.size.height,
          tilesView.frame.size.width, tilesView.frame.size.height,
          dataLayer.frame.size.width, dataLayer.frame.size.height,
          annLayer.frame.size.width, annLayer.frame.size.height);    
 }

- (void)dealloc
{
    NSLog(@"AppDelegate dalloc");
}


-(void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    CGRect bounds = CGContextGetClipBoundingBox(context);
#ifdef DATA_PRE_RENDER
    uint64_t i = ((uint64_t)bounds.origin.x >> TILEWIDTH_LOG2BITS);
    
    CGLayerRef tileLayer = dataLayers[i];
    if (tileLayer && dataLayerRendered[i]==1) {
        CGContextDrawLayerAtPoint(context, CGPointMake(bounds.origin.x,0), tileLayer);
    } else {
        if (tileLayer==NULL) {
            tileLayer = CGLayerCreateWithContext(context,tileSize,NULL);
            dataLayers[i] = tileLayer;
        }
        if (dataLayerRendered[i]==0) {
            CGContextRef tileLayerCtx = CGLayerGetContext (tileLayer);
            CGContextClearRect(tileLayerCtx, CGRectMake(0,0,tileSize.width,tileSize.height));
            CGPoint loc;
            //   CGAffineTransform ctm = CGContextGetCTM(context);
            //    NSLog(@"Data: drawLayer bounds.x=%f CTM is: %g %g %g %g %g %g", bounds.origin.x, ctm.a, ctm.b, ctm.c, ctm.d, ctm.tx, ctm.ty);
            
            // Adjust start and end to redraw overlapping points
            int x,
            xstart=(int)bounds.origin.x,
            xend = bounds.origin.x + bounds.size.width + thePoint.radius;
            
            if (xstart!=0) xstart-=thePoint.radius;
            
            for (x=xstart; x<xend; x++) {
                loc.x = x - thePoint.radius;
                if (x<data.numValues) {
                    loc.y  = (((unsigned short *)data.mem)[x])-thePoint.radius;
                    CGContextDrawLayerAtPoint(tileLayerCtx, loc, thePoint.layer);
                }
            }
            dataLayerRendered[i]=1;
            CGContextDrawLayerAtPoint(context, CGPointMake(bounds.origin.x,0), tileLayer);
        }
    }

#else
    CGPoint loc;
 //   CGAffineTransform ctm = CGContextGetCTM(context);
//    NSLog(@"Data: drawLayer bounds.x=%f CTM is: %g %g %g %g %g %g", bounds.origin.x, ctm.a, ctm.b, ctm.c, ctm.d, ctm.tx, ctm.ty);
 
    // Adjust start and end to redraw overlapping points
    int x,
        xstart=(int)bounds.origin.x,
        xend = bounds.origin.x + bounds.size.width + thePoint.radius;
    
    if (xstart!=0) xstart-=thePoint.radius;
    
    for (x=xstart; x<xend; x++) {
        loc.x = x - thePoint.radius;
        if (x<data.numValues) {
            loc.y  = (((unsigned short *)data.mem)[x])-thePoint.radius;
            CGContextDrawLayerAtPoint(context, loc, thePoint.layer);
        }
    }
#endif
  }


@end
