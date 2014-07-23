//
//  NSAlert+BlockMethods.h
//

#import <Cocoa/Cocoa.h>

@interface NSAlert (BlockMethods)

-(void)compatibleBeginSheetModalForWindow:(NSWindow *)sheetWindow completionHandler:(void (^)(NSInteger returnCode))handler;

@end
