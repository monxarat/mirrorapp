//
//  NSAlert+BlockMethods.h
//  Mirror
//
//  Copyright 2014, The Pennsylvania State University
//  Distributed under MIT License
//

#import <Cocoa/Cocoa.h>

@interface NSAlert (BlockMethods)

-(void)compatibleBeginSheetModalForWindow:(NSWindow *)sheetWindow completionHandler:(void (^)(NSInteger returnCode))handler;

@end
