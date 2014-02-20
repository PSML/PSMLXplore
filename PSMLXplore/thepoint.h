//
//  thepoint.h
//  PSMLXplore
//
//  Created by Jonathan Appavoo on 2/20/14.
//  Copyright (c) 2014 Jonathan Appavoo. All rights reserved.
//

#ifndef PSMLXplore_thepoint_h
#define PSMLXplore_thepoint_h

struct ThePoint {
    CGLayerRef layer;
    unsigned int diameter;
    unsigned int radius;
};

extern struct ThePoint thePoint;
static inline int getPointDiameter(void) { return thePoint.diameter; }
extern void setPoint(NSView *view, unsigned int diameter);

#endif
