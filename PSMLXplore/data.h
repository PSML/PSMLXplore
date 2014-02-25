//
//  data.h
//  PSMLXplore
//
//  Created by Jonathan Appavoo on 2/20/14.
//  Copyright (c) 2014 Jonathan Appavoo. All rights reserved.
//

#ifndef PSMLXplore_data_h
#define PSMLXplore_data_h

struct Data {
    void *mem;
    off_t filesize;
    uint64 numValues;
    uint64 maxValue;
};

extern struct Data data;

void mapData(const char *path, uint64 max);

#if 0
static inline
CGFloat dataXToViewX(uint64 x, CGFloat width)
{
    return width * (CGFloat)((CGFloat)x/(CGFloat)data.numValues);
}

static inline
CGFloat dataYToViewY(uint64 y, CGFloat height)
{
    return height * (CGFloat)((CGFloat)y/(CGFloat)data.maxValue);
}

static inline
NSPoint dataPointToView(NSPoint pt, NSSize size)
{
    NSPoint rtn;
    rtn.x = dataXToViewX(pt.x, size.width); rtn.y=dataYToViewY(pt.y, size.height);
    return rtn;
}
#endif
#endif
