//
//  appletv.h
//  appletv
//

#import <Foundation/Foundation.h>

@interface appletv : NSObject

-(void) connectToAppleTVWithSettings:(NSDictionary *)settingsJSON andDevices:(NSArray *)devicesJSONArray;

@end
