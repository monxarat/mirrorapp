//
//  AppDelegate.h
//  Mirror
//
//  Copyright 2014, The Pennsylvania State University
//  Distributed under MIT License
//

#import <Cocoa/Cocoa.h>
#import "appletv.h"

#import "constants.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>{
    NSData * JSONData;
    
    NSArray * campusesJsonArray;
    NSArray * buildingsJsonArray;
    NSArray * roomsJsonArray;
    NSArray * devicesJsonArray;
    NSArray * jsonArray;
    
    NSDictionary * defaultJSON;
    NSString * domain;
    appletv * connection;
    
    NSString *jsonURL;
    
    NSMutableArray *campusValues;
    NSMutableArray *buildingValues;
    NSMutableArray *roomValues;
    
    
    
    IBOutlet NSView *deviceView;
    IBOutlet NSTextField *loginURL;
    IBOutlet NSTextField *statusLabel;
    IBOutlet NSButton *settingsButton;
    IBOutlet NSImageView *checkmark;
    //IBOutlet NSPopUpButton *chooseCampusButton;
    //IBOutlet NSPopUpButton *chooseBuildingButton;
    //IBOutlet NSPopUpButton *chooseRoomButton;
    
    NSUserDefaults *prefs;
    NSString *mirrorURL;
    BOOL isInitialSettingSet;

}

@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSPopUpButton *chooseCampusButton;
@property (weak) IBOutlet NSPopUpButton *chooseBuildingButton;
@property (weak) IBOutlet NSPopUpButton *chooseRoomButton;

-(IBAction)login:(id)sender;
- (IBAction)chooseCampus:(id)sender;
- (IBAction)chooseBuilding:(id)sender;
- (IBAction)chooseRoom:(id)sender;
- (IBAction)settings:(id)sender;


- (void)receivingDataError;
- (void)urlError:(NSString *)messageTxt;

- (void)continueLoadingInitialSettings;
- (void)loadInitialSettings;
- (void)resetUI;


@end
