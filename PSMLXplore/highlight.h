//
//  highlight.h
//  PSMLXplore
//
//  Created by Jonathan Appavoo on 2/27/14.
//  Copyright (c) 2014 Jonathan Appavoo. All rights reserved.
//

#ifndef PSMLXplore_highlight_h
#define PSMLXplore_highlight_h

#define HIGHLIGHT_WIDTH 8
#define HIGHLIGHT_HEIGHT 8

struct highlight {
    CGLayerRef layer;
    NSRect rect;
    NSPoint centerOffset;
};


extern struct highlight theHighlight;
void highlight(uint64_t x, uint16_t y);

#endif
