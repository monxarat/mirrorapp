//
//  ViewController.h
//  Mirror
//
//  Copyright 2014, The Pennsylvania State University
//  Distributed under MIT License
//

#import <UIKit/UIKit.h>
#import "appletv.h"

#import "constants.h"
#import "iOSconstants.h"

@interface ViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIScrollViewDelegate>{
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
    
    IBOutlet UIView *ChooseCampusView;
    IBOutlet UILabel *ChooseCampusLabel;
    IBOutlet UIButton *ChooseCampusButton;
    
    IBOutlet UIView *ChooseBuildingView;
    IBOutlet UILabel *ChooseBuildingLabel;
    IBOutlet UIButton *ChooseBuildingButton;
    
    IBOutlet UIView *ChooseRoomView;
    IBOutlet UILabel *ChooseRoomLabel;
    IBOutlet UIButton *ChooseRoomButton;
    
    IBOutlet UIImageView *ControlCenterIcon;
    
    IBOutlet UILabel *CCLabel1;
    IBOutlet UILabel *CCLabel2;
    
    IBOutlet UIImageView *CampusCheck;
    IBOutlet UIImageView *BuildingCheck;
    IBOutlet UIImageView *RoomCheck;
    
    IBOutlet UIScrollView *scrollBranding;
    IBOutlet UIPageControl *pageControl;
    
    NSTimer *showTimer;
    BOOL isInitialSettingSet;
    

    IBOutlet UIButton *loginButton;
    IBOutlet UITextField *loginURL;
    
    IBOutlet UIView *changeURLView;
    
    
    NSUserDefaults *prefs;
    NSString *mirrorURL;
    NSString *currectChooser;    
    
}

-(IBAction)ChooseCampus;
-(IBAction)ChooseBuilding;
-(IBAction)ChooseRoom;
-(IBAction)changeURL;
-(IBAction)infoButton;
-(IBAction)cancelinfoButton;
-(IBAction)brandingURL;


//-(IBAction)changelabel:(id)sender;






@property (strong, nonatomic) IBOutlet UIPickerView *campusPicker;
@property (strong, nonatomic) IBOutlet UIPickerView *buildingPicker;
@property (strong, nonatomic) IBOutlet UIPickerView *roomPicker;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollBranding;
@property (strong, nonatomic) IBOutlet UIPageControl *pageControl;



- (void)populatePicker;

- (void)campusCheckTimer;
- (void)campusCheckShow;
- (void)receivingDataError;
- (void)urlError:(NSString *)messageTxt;
- (void)chooserErrorType:(NSString*)chooser name:(NSString*)name;

- (void)continueLoadingInitialSettings;
- (void)loadInitialSettings;
- (void)resetUI;
- (void)campusAnimation:(NSDictionary *)chosenCampus;

@end
