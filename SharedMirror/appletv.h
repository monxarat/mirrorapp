//
//  appletv.h
//  Mirror
//
//  Copyright 2014, The Pennsylvania State University
//  Distributed under MIT License
//

#import <Foundation/Foundation.h>

@interface appletv : NSObject

-(void) connectToAppleTVWithSettings:(NSDictionary *)settingsJSON andDevices:(NSArray *)devicesJSONArray;

@end
