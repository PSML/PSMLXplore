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

void mapData(char *path, uint64 max);

#endif
