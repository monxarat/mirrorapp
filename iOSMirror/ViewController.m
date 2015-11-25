//
//  ViewController.m
//  Mirror
//
//  Copyright 2014, The Pennsylvania State University
//  Distributed under MIT License
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize campusPicker;
@synthesize buildingPicker;
@synthesize roomPicker;
@synthesize scrollBranding, pageControl;



static NSString *seeLabels;



- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self->loginURL.delegate = self;
    
    campusPicker.delegate = self;
    campusPicker.dataSource = self;
    buildingPicker.delegate = self;
    buildingPicker.dataSource = self;
    roomPicker.delegate = self;
    roomPicker.dataSource = self;
    
    campusValues = [[NSMutableArray alloc] initWithCapacity: 0];
    buildingValues = [[NSMutableArray alloc] initWithCapacity: 0];
    roomValues = [[NSMutableArray alloc] initWithCapacity: 0];
    
    connection = [appletv alloc];
    
    campusPicker.hidden = YES;
    buildingPicker.hidden = YES;
    roomPicker.hidden = YES;
    
    //ChooseBuildingButton.enabled = NO;
    //ChooseRoomButton.enabled = NO;
    
    ControlCenterIcon.hidden = YES;
    
    CampusCheck.hidden = YES;
    BuildingCheck.hidden = YES;
    RoomCheck.hidden = YES;
    
    CCLabel1.hidden = YES;
    changeURLView.hidden = YES;
    
    isInitialSettingSet = NO;
    
    prefs = [NSUserDefaults standardUserDefaults];
    mirrorURL = MIRRORAPP_HOST;
    
    
    NSLog(@"mirrorURL = %@", mirrorURL);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        // IPHONE INTERFACE ONLY
        ChooseCampusLabel.enabled = NO;
        ChooseBuildingButton.enabled = NO;
        ChooseRoomButton.enabled = NO;
        
        [scrollBranding setScrollEnabled:YES];
        [scrollBranding setContentSize:CGSizeMake(639, 128)];
    } else {
        // IPAD INTERFACE ONLY
        ChooseBuildingButton.enabled = NO;
        ChooseRoomButton.enabled = NO;
        ChooseCampusButton.enabled = NO;
        ChooseBuildingLabel.hidden = YES;
        ChooseRoomLabel.hidden = YES;
        CCLabel2.hidden = YES;
        
        [scrollBranding setScrollEnabled:YES];
        [scrollBranding setContentSize:CGSizeMake(1063, 133)];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(loadInitialSettings)
                                                 name: @"didBecomeActive"
                                               object: nil];
    
    
    
    
    
    
    
    
}
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollBranding.frame.size.width;
    int page = floor((self.scrollBranding.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}


- (void)resetUI {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        //IPHONE INTERFACE ONLY
        ChooseCampusButton.titleLabel.text = @"Choose Campus";
        ChooseBuildingButton.titleLabel.text = @"Choose Building";
        ChooseRoomButton.titleLabel.text = @"Choose Room";
        CampusCheck.hidden = YES;
        BuildingCheck.hidden = YES;
        RoomCheck.hidden = YES;
    } else {
        //IPAD INTERFACE ONLY
        ChooseCampusLabel.text = @"";
        ChooseBuildingLabel.text = @"";
        ChooseRoomLabel.text = @"";
        CampusCheck.hidden = YES;
        BuildingCheck.hidden = YES;
        RoomCheck.hidden = YES;
        CCLabel2.hidden = YES;
        
        [UIView animateWithDuration:0.4f animations:^{
            
            ChooseCampusButton.frame = CGRectMake(257.0f, 194.0f, ChooseCampusButton.frame.size.width, ChooseCampusButton.frame.size.height);
            
            ChooseBuildingButton.frame = CGRectMake(257.0f, 251.0f, ChooseBuildingButton.frame.size.width, ChooseBuildingButton.frame.size.height);
            
            ChooseRoomButton.frame = CGRectMake(257.0f, 308.0f, ChooseRoomButton.frame.size.width, ChooseRoomButton.frame.size.height);
            
            
        }];
    }
    
    campusPicker.hidden = YES;
    buildingPicker.hidden = YES;
    roomPicker.hidden = YES;
    
    ControlCenterIcon.hidden = YES;
    CCLabel1.hidden = YES;
    
    ChooseBuildingButton.enabled = NO;
    ChooseRoomButton.enabled = NO;
}

- (void)receivingDataError{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Problem receiving data"
                                                      message:@"Please check internet connection and try again."
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    
    [self resetUI];
    
    [message show];
}

- (void)urlError:(NSString *)messageTxt{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Problem connecting"
                                                      message:messageTxt
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [message show];
    NSLog(@"\nProblem loading mirror url. Most likely wrong address entered.\n");
}

- (void)chooserErrorType:(NSString*)chooser name:(NSString*)name{
    UIAlertView *message = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@ error", chooser]
                                                      message:[NSString stringWithFormat:@"%@ not found", name]
                                                     delegate:self
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    currectChooser = chooser;
    [message show];
    NSLog(@"No %@ by the name of %@ found", chooser, name);
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSLog(@"currectChooser = %@", currectChooser);
    if ([currectChooser isEqualToString:@"Campus"]) {
        [self ChooseCampus];
    }
    else if ([currectChooser isEqualToString:@"Building"]){
        [self ChooseBuilding];
    }
    if ([currectChooser isEqualToString:@"Room"]){
        [self ChooseRoom];
    }
}

- (void) continueLoadingInitialSettings{
    if (JSONData == nil){
                    [self urlError:@"Please check with your Mirror Administrator."];
     
    }
    else{
        NSError *error = nil;
        
        campusesJsonArray = [NSJSONSerialization
                             JSONObjectWithData:JSONData
                             options:NSJSONReadingAllowFragments
                             error:&error];
        
        NSLog(@"campusesJsonArray = %@", campusesJsonArray);
        
        if (!campusesJsonArray) {
            NSLog(@"Error parsing JSON: %@", error);
        }
        else if ([campusesJsonArray count] < 1){
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Application error"
                                                              message:@"Please add campus"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil];
            [message show];
            NSLog(@"No campuses were returned.");
        }
        else {
            if ([campusesJsonArray count] == 1) {
                [self campusAnimation:campusesJsonArray[0]];
            }
            else
            {
                for(NSDictionary *json in campusesJsonArray) {
                    NSLog(@"Item: %@", json);
                    NSLog(@"name = %@", [json objectForKey:@"name"]);
                    [campusValues addObject:[json objectForKey:@"name"]];
                }
                [campusValues insertObject:@"Choose Campus" atIndex:0]; //It appears I have to have more then one choice for the picker to fire on click
                ChooseCampusButton.enabled = YES;
            }
            isInitialSettingSet = YES;
            NSLog(@"\nInitial setting loaded.\n");
        }
    }
}

- (void)loadInitialSettings{
    if ((!isInitialSettingSet) && (mirrorURL != nil)) {
        NSLog(@"\nBegin loading initial setting.\n");
        [campusValues removeAllObjects];
        jsonURL = [NSString stringWithFormat:@"https://%@/json/?response=", mirrorURL];
        
        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"%@campuses", jsonURL]];
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        
        [NSURLConnection sendAsynchronousRequest:urlRequest queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             if ([data length] > 0 && error == nil){
                 JSONData = data; //put rest of loadInitialSettings logic in continueLoadingInitialSettings because, execution of ChooseCampusButton.enabled = YES; was taking about 20 seconds even though JSONData = data; happenned immediately (relatively speaking).
             }
             else if ([data length] == 0 && error == nil){
                 NSLog(@"data empty");
             }
             else {
                 NSLog(@"error = %@", error);
             }
         }];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(continueLoadingInitialSettings) userInfo:nil repeats:NO];
    }
}

- (void)campusAnimation:(NSDictionary *)chosenCampus
{
    NSLog(@"\n\n\n\nIn Campus\n\n\n\n");
    
    JSONData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@buildings&id=%@", jsonURL, [chosenCampus objectForKey:@"id" ]]]];
    if (JSONData == nil) {
        [self receivingDataError];
    } else {
        
        NSError *error = nil;
        
        buildingsJsonArray = [NSJSONSerialization
                             JSONObjectWithData:JSONData
                             options:NSJSONReadingAllowFragments
                             error:&error];
        
        NSLog(@"buildingsJsonArray = %@", buildingsJsonArray);
        
        if (!buildingsJsonArray) {
            NSLog(@"Error parsing JSON: %@", error);
        }
        else if ([buildingsJsonArray count] < 1){
            [self chooserErrorType:@"Campus" name:[chosenCampus objectForKey:@"name"]];
        }
        else {
            [self campusCheckTimer];
            ChooseBuildingButton.enabled = YES;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                //IPHONE INTERFACE ONLY
                ChooseCampusButton.titleLabel.text = [chosenCampus objectForKey:@"name" ];
            } else {
                //IPAD INTERFACE ONLY
                ChooseCampusLabel.text = [chosenCampus objectForKey:@"name" ];
                ChooseBuildingLabel.hidden = NO;
                
                [UIView animateWithDuration:0.4f animations:^{
                    ChooseCampusButton.frame = CGRectMake(100.0f, 194.0f, ChooseCampusButton.frame.size.width, ChooseCampusButton.frame.size.height);
                    ChooseBuildingButton.frame = CGRectMake(100.0f, 251.0f, ChooseBuildingButton.frame.size.width, ChooseBuildingButton.frame.size.height);
                    ChooseRoomButton.frame = CGRectMake(100.0f, 308.0f, ChooseRoomButton.frame.size.width, ChooseRoomButton.frame.size.height);
                }];
            }
            
            [buildingValues removeAllObjects];
            [roomValues removeAllObjects];
            for(NSDictionary *json in buildingsJsonArray) {
                NSLog(@"Item: %@", json);
                NSLog(@"Building name = %@", [json objectForKey:@"name"]);
                [buildingValues addObject:[json objectForKey:@"name"]];
            }
            [buildingValues insertObject:@"Choose Building" atIndex:0]; //It appears I have to have more then one choice for the picker to fire on click
            [buildingPicker reloadAllComponents];
            [roomPicker reloadAllComponents];
            [buildingPicker selectRow:0 inComponent:0 animated:YES];
        }
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];

    
    loginURL.text = [[loginURL.text componentsSeparatedByString:@"://"] lastObject];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9-\\.]+$"
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    NSArray* matches = [regex matchesInString:loginURL.text options:0 range: NSMakeRange(0, [loginURL.text length])];
    
    if ((![loginURL.text isEqualToString:@""]) && ([loginURL.text length] > 2) && ([matches count] != 0) && (!([[loginURL.text substringToIndex:1] isEqualToString:@"-"] || [[loginURL.text substringFromIndex:[loginURL.text length] - 1] isEqualToString:@"-"]))) {
        
        [prefs setObject:loginURL.text forKey:@"url"];
        [prefs synchronize];
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9-\\.]+$"
                                                                               options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines
                                                                                 error:&error];
        NSArray* matches = [regex matchesInString:loginURL.text options:0 range: NSMakeRange(0, [loginURL.text length])];
        
        for (NSTextCheckingResult* match in matches){
            NSLog(@"match: %@", match);
        }
        
        mirrorURL = MIRRORAPP_HOST;
        
        isInitialSettingSet = NO;
        [self resetUI];
        [self loadInitialSettings];
        if (isInitialSettingSet) {

            return NO;
        }
        else{
            return YES;
        }
    }
    else {
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Invalid Mirror URL"
                                                          message:@"Please check with your Mirror Administrator."
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        
        [message show];
        return YES;
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.40];
            self.view.frame = CGRectMake(0, -80, 320, 480);
            [UIView commitAnimations];
            
        }
        if(result.height == 568)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.40];
            self.view.frame = CGRectMake(0, -10, 320, 568);
            [UIView commitAnimations];
        }
        
        
        
    }
    
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.0];
            self.view.frame = CGRectMake(0, 0, 320, 480);
            [UIView commitAnimations];
            
        }
        if(result.height == 568)
        {
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.0];
            self.view.frame = CGRectMake(0, 0, 320, 568);
            [UIView commitAnimations];
        }
        else {
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:0.0];
            self.view.frame = CGRectMake(0, 0, 768, 1024);
            [UIView commitAnimations];
        }
        
        
    }
}


-(IBAction)ChooseCampus {
    if (campusValues.count > 0) {
        [campusPicker reloadAllComponents];
        campusPicker.hidden = NO;
        buildingPicker.hidden = YES;
        roomPicker.hidden = YES;
        ChooseBuildingButton.enabled = NO;
        ChooseRoomButton.enabled = NO;
        CCLabel1.hidden = YES;
        ControlCenterIcon.hidden = YES;
        CampusCheck.hidden = YES;
        BuildingCheck.hidden = YES;
        RoomCheck.hidden = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
            // IPHONE INTERFACE ONLY
            ChooseCampusButton.titleLabel.text = @"Choose Campus";
            if (!((([ChooseBuildingButton.titleLabel.text isEqualToString:@"Choose Building"])) || ([ChooseRoomButton.titleLabel.text isEqualToString:@"Choose Room"]))){
                ChooseBuildingButton.titleLabel.text = @"Choose Building";
                ChooseRoomButton.titleLabel.text = @"Choose Room";
            }
        } else {
            // IPAD INTERFACE ONLY
            ChooseCampusLabel.text = @"";
            if (![ChooseBuildingLabel.text isEqualToString:@""]) {
                ChooseBuildingLabel.text = @"";
                ChooseRoomLabel.text = @"";
                CCLabel2.hidden = YES;
            }
        }
    }
}


-(IBAction)ChooseBuilding {
    if (buildingValues.count > 0) {
        campusPicker.hidden = YES;
        buildingPicker.hidden = NO;
        roomPicker.hidden = YES;
        
        BuildingCheck.hidden = YES;
        RoomCheck.hidden = YES;
        
        ChooseRoomButton.enabled = NO;
        CCLabel1.hidden = YES;
        ControlCenterIcon.hidden = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            //IPHONE INTERFACE ONLY
            ChooseBuildingButton.titleLabel.text = @"Choose Building";
            if (![ChooseRoomButton.titleLabel.text isEqualToString:@"Choose Room"]) {
                ChooseRoomButton.titleLabel.text = @"Choose Room";
            }
            
        } else {
            //IPAD INTERFACE ONLY
            ChooseBuildingLabel.text = @"";
            if (![ChooseRoomLabel.text isEqualToString:@""]) {
                ChooseRoomLabel.text = @"";
                CCLabel2.hidden = YES;
            }
        }
    }
}


-(IBAction)ChooseRoom {
    if (roomValues.count > 0) {
        
        campusPicker.hidden = YES;
        buildingPicker.hidden = YES;
        roomPicker.hidden = NO;
        CCLabel1.hidden = YES;
        ControlCenterIcon.hidden = YES;
        RoomCheck.hidden = YES;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            //IPHONE INTERFACE ONLY
            ChooseRoomButton.titleLabel.text = @"Choose Room";
            
        } else {
            //IPAD INTERFACE ONLY
            ChooseRoomLabel.text = @"";
            CCLabel2.hidden = YES;
        }
    }
}

-(IBAction)changeURL {
    
    changeURLView.hidden = YES;
    if ((![mirrorURL isEqualToString:@""]) && (mirrorURL != nil)) {
        loginURL.text = mirrorURL;
    }
}

-(IBAction)infoButton {
    
    changeURLView.hidden = NO;
    
}

-(IBAction)cancelinfoButton {
    
    changeURLView.hidden = YES;
}




- (void) campusCheckTimer {
    showTimer = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(campusCheckShow) userInfo:nil repeats:NO];
}

- (void) campusCheckShow {
    
    CampusCheck.hidden = NO;
}


-(IBAction)brandingURL {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://bit.ly/1mqEg9L"]];
    
    
    
}


#pragma mark - UIPickerView DataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray *values;
    if (pickerView == campusPicker){
        values = campusValues;
    }
    else if (pickerView == buildingPicker){
        values = buildingValues;
    }
    else if (pickerView == roomPicker){
        values = roomValues;
    }
    else{
        values = nil;
    }
    return [values count];
}

#pragma mark - UIPickerView Delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30.0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView == campusPicker){
        return [campusValues objectAtIndex:row];
    }
    else if (pickerView == buildingPicker){
        return [buildingValues objectAtIndex:row];
    }
    else{ // if (pickerView == roomPicker){
        return [roomValues objectAtIndex:row];
    }
}

//If the user chooses from the pickerview, it calls this function;
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == campusPicker){
        NSLog(@"Chosen item: %@", [campusValues objectAtIndex:row]);
        for(NSDictionary *json in campusesJsonArray) {
            if ([[campusValues objectAtIndex:row] isEqual: [json objectForKey:@"name" ]]) {
                [self campusAnimation:json];
                break;
            }
        }
    }
    else if (pickerView == buildingPicker){
        NSLog(@"Chosen item: %@", [buildingValues objectAtIndex:row]);
        for(NSDictionary *json in buildingsJsonArray) {
            if ([[buildingValues objectAtIndex:row] isEqual:[json objectForKey:@"name"]]){
                NSLog(@"\n\n\n\nIn Building\n\n\n\n");
                
                JSONData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@rooms&id=%@", jsonURL, [json objectForKey:@"id" ]]]];
                if (JSONData == nil) {
                    [self receivingDataError];
                } else {
                    
                    NSError *error = nil;
                    
                    roomsJsonArray = [NSJSONSerialization
                                     JSONObjectWithData:JSONData
                                     options:NSJSONReadingAllowFragments
                                     error:&error];
                    
                    NSLog(@"roomsJsonArray = %@", roomsJsonArray);
                    
                    if (!roomsJsonArray) {
                        NSLog(@"Error parsing JSON: %@", error);
                    }
                    else if ([roomsJsonArray count] < 1){
                        [self chooserErrorType:@"Building" name:[json objectForKey:@"name"]];
                    }
                    else {
                        BuildingCheck.hidden = NO;
                        ChooseRoomButton.enabled = YES;
                        
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                        {
                            //IPHONE INTERFACE ONLY
                            ChooseBuildingButton.titleLabel.text = [buildingValues objectAtIndex:row];
                        } else {
                            //IPAD INTERFACE ONLY
                            ChooseBuildingLabel.text = [buildingValues objectAtIndex:row];
                            ChooseRoomLabel.hidden = NO;
                        }
                        
                        [roomValues removeAllObjects];
                        for(NSDictionary *json in roomsJsonArray) {
                            NSLog(@"Item: %@", json);
                            NSLog(@"Room name = %@", [json objectForKey:@"name"]);
                            [roomValues addObject:[json objectForKey:@"name"]];
                        }
                        [roomValues insertObject:@"Choose Room" atIndex:0]; //It appears I have to have more then one choice for the picker to fire on click
                        [roomPicker reloadAllComponents];
                        [roomPicker selectRow:0 inComponent:0 animated:YES];
                    }
                }
                break;
            }
        }
    }
    else if (pickerView == roomPicker){
        for(NSDictionary *json in roomsJsonArray) {
            if ([[roomValues objectAtIndex:row] isEqual:[json objectForKey:@"name"]]) {
                NSLog(@"\n\n\n\nIn Room\n\n\n\n");
                
                JSONData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@devices&id=%@", jsonURL, [json objectForKey:@"id" ]]]];
                if (JSONData == nil) {
                    [self receivingDataError];
                } else {
                    
                    NSError *error = nil;
                    
                    devicesJsonArray = [NSJSONSerialization
                                       JSONObjectWithData:JSONData
                                       options:NSJSONReadingAllowFragments
                                       error:&error];
                    
                    
                    if (!devicesJsonArray) {
                        NSLog(@"Error parsing JSON: %@", error);
                    }
                    else if ([devicesJsonArray count] < 1){
                        [self chooserErrorType:@"Room" name:[json objectForKey:@"name"]];
                    }
                    else {
                        RoomCheck.hidden = NO;
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                        {
                            //IPHONE INTERFACE ONLY
                            ChooseRoomButton.titleLabel.text = [roomValues objectAtIndex:row];
                            [UIView animateWithDuration:0.9f animations:^{
                                ControlCenterIcon.frame = CGRectMake(145.0f, 515.0f, ControlCenterIcon.frame.size.width, ControlCenterIcon.frame.size.height);
                                CCLabel1.hidden = NO;
                            }];
                            
                        } else {
                            //IPAD INTERFACE ONLY
                            ChooseRoomLabel.text = [roomValues objectAtIndex:row];
                            ChooseRoomLabel.hidden = NO;
                            [UIView animateWithDuration:0.9f animations:^{
                                
                                ControlCenterIcon.frame = CGRectMake(363.0f, 965.0f, ControlCenterIcon.frame.size.width, ControlCenterIcon.frame.size.height);
                                CCLabel2.hidden = NO;
                                
                            }];
                        }
                        
                        CCLabel1.hidden = NO;
                        
                        ChooseRoomButton.enabled = YES;
                        ControlCenterIcon.hidden = NO;
                        
                        NSString *model = [devicesJsonArray[0] objectForKey:@"model"];
                        
                        if ([model isEqualToString:@"AppleTV2,1"]) {
                            JSONData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@devicetype&id=%@", jsonURL, @"1"]]];
                        }
                        else if ([model isEqualToString:@"AirServer"]) {
                            JSONData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@devicetype&id=%@", jsonURL, @"2"]]];
                        }
                        else if ([model isEqualToString:@"Reflector"]) {
                            JSONData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@devicetype&id=%@", jsonURL, @"3"]]];
                        }
                        else if ([model isEqualToString:@"AppleTV5"]) {
                            JSONData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@devicetype&id=%@", jsonURL, @"4"]]];
                        }
                        else { // model = AppleTV3,2
                            JSONData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@devicetype&id=%@", jsonURL, @"0"]]];
                        }
                        
                        if (JSONData == nil) {
                            [self receivingDataError];
                        } else {
                            NSError *error = nil;
                            
                            defaultJSON = [NSJSONSerialization
                                           JSONObjectWithData:JSONData
                                           options:NSJSONReadingAllowFragments
                                           error:&error];

                            if(error) { /* JSON was malformed, act appropriately here */
                                NSLog(@"\n\n\n\nmalformed JSON\n\n\n\n");
                            }
                            else {
                                [connection connectToAppleTVWithSettings:defaultJSON andDevices:devicesJsonArray];
                                //When history UI is ready, uncomment the code below and use history array to populate history UI.
                                /*
                                 NSDictionary* individualHistory;
                                 BOOL addIndividualHistory = YES;
                                 if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                                 {
                                 //IPHONE INTERFACE ONLY
                                 NSLog(@"campus = %@, building = %@, room = %@", ChooseCampusButton.titleLabel.text, ChooseBuildingButton.titleLabel.text, ChooseRoomButton.titleLabel.text);
                                 individualHistory = @{@"campus": ChooseCampusButton.titleLabel.text, @"building":ChooseBuildingButton.titleLabel.text, @"rooms":ChooseRoomButton.titleLabel.text};
                                 } else {
                                 //IPAD INTERFACE ONLY
                                 NSLog(@"campus = %@, building = %@, room = %@", ChooseCampusLabel.text, ChooseBuildingLabel.text, ChooseBuildingLabel.text);
                                 individualHistory = @{@"campus": ChooseCampusLabel.text, @"building":ChooseBuildingLabel.text, @"rooms":ChooseRoomLabel.text};
                                 }
                                 NSMutableArray* history = [NSMutableArray arrayWithArray:[prefs objectForKey:@"history"]];
                                 if (!history) {
                                 history = [NSMutableArray arrayWithCapacity:0];
                                 }
                                 NSLog(@"before checks history = %@", history);
                                 for (NSDictionary* formerIndividaulHistory in history) {
                                 if ([formerIndividaulHistory isEqualToDictionary:individualHistory]) {
                                 addIndividualHistory = NO;
                                 NSLog(@"formerIndividaulHistory = %@ is equal to individualHistory = %@", formerIndividaulHistory, individualHistory);
                                 break;
                                 }
                                 }
                                 if (addIndividualHistory) {
                                 [history insertObject: individualHistory atIndex:0];
                                 if ([history count] > 5) {
                                 [history removeLastObject];
                                 NSLog(@"after remove history = %@", history);
                                 }
                                 NSLog(@"after add history = %@", history);
                                 [prefs setObject:history forKey:@"history"];
                                 [prefs synchronize];
                                 }*/
                            }
                        }
                    }
                }
                break;
            }
        }
    }
    else {
        NSLog(@"pickerView:didSelectRow:inComponent was called on a picker it should not have beend called on.  That picker is %@", pickerView);
    }
}

- (void)populatePicker{
}

@end
