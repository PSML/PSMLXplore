//
//  main.m
//  PSMLXplore
//
//  Created by Jonathan Appavoo on 2/13/14.
//  Copyright (c) 2014 Jonathan Appavoo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern const char **theArgv;
extern int64_t theArgc;

int main(int argc, const char * argv[])
{
    theArgc = argc;
    theArgv  = argv;
    return NSApplicationMain(argc, argv);
}
