//
//  AppDelegate.m
//  OSXMirror
//

#import "AppDelegate.h"
#import "NSAlert+BlockMethods.h"

@implementation AppDelegate

@synthesize chooseCampusButton;
@synthesize chooseBuildingButton;
@synthesize chooseRoomButton;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    

    [self.window setTitle:@" "];
    [self.window setBackgroundColor: NSColor.whiteColor];
    
    
    
    [chooseCampusButton setHidden:YES];
    [chooseBuildingButton setHidden:YES];
    [chooseRoomButton setHidden:YES];
    [statusLabel setHidden:YES];
    [settingsButton setHidden:YES];
    [checkmark setHidden:YES];
    
    campusValues = [[NSMutableArray alloc] initWithCapacity: 0];
    buildingValues = [[NSMutableArray alloc] initWithCapacity: 0];
    roomValues = [[NSMutableArray alloc] initWithCapacity: 0];
    
    connection = [appletv alloc];
    
    mirrorURL = MIRRORAPP_HOST;
    
    [deviceView setHidden:NO];
    [chooseCampusButton setHidden:NO];
    [loginURL setHidden:YES];
    [settingsButton setHidden:YES];
        
    [self loadInitialSettings];
 

}

-(IBAction)login:(id)sender {
    
    [deviceView setHidden:NO];
    [chooseCampusButton setHidden:NO];
    [loginURL setHidden:YES];
    
    
    [[self window] makeFirstResponder:nil];
    
    loginURL.stringValue = [[loginURL.stringValue componentsSeparatedByString:@"://"] lastObject];
    
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9-\\.]+$"
                                                                           options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines
                                                                             error:&error];
    NSArray* matches = [regex matchesInString:loginURL.stringValue options:0 range: NSMakeRange(0, [loginURL.stringValue length])];
    
    if ((![loginURL.stringValue isEqualToString:@""]) && ([loginURL.stringValue length] > 2) && ([matches count] != 0) && (!([[loginURL.stringValue substringToIndex:1] isEqualToString:@"-"] || [[loginURL.stringValue substringFromIndex:[loginURL.stringValue length] - 1] isEqualToString:@"-"]))) {
        
        NSError *error = NULL;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^[a-zA-Z0-9-\\.]+$"
                                                                               options:NSRegularExpressionCaseInsensitive | NSRegularExpressionAnchorsMatchLines
                                                                                 error:&error];
        NSArray* matches = [regex matchesInString:loginURL.stringValue options:0 range: NSMakeRange(0, [loginURL.stringValue length])];
        
        for (NSTextCheckingResult* match in matches){
            NSLog(@"match: %@", match);
        }
        
        //mirrorURL = loginURL.stringValue;
        mirrorURL = MIRRORAPP_HOST;
        
        isInitialSettingSet = NO;
        [self resetUI];
        [self loadInitialSettings];
        if (isInitialSettingSet) {
            [deviceView setHidden:NO];
            
            //return NO;
        }
        else{
            //return YES;
        }
    }
    else {
        [NSAlert alertWithMessageText:@"Invalid Mirror URL" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please check with your Mirror Administrator."];
    }
}

- (void)receivingDataError {
    NSAlert *alert = [NSAlert alertWithMessageText: @"Problem receiving data"
                                     defaultButton: nil
                                   alternateButton: nil
                                       otherButton: nil
                         informativeTextWithFormat: @"Please check internet connection and try again."];
    
    [alert compatibleBeginSheetModalForWindow: self.window completionHandler: ^(NSInteger returnCode){}];

}

- (void)urlError:(NSString *)messageTxt{
    
}

- (void) continueLoadingInitialSettings{
    if (JSONData == nil) {
        if ([deviceView isHidden] == NO) {
            [self urlError:@"Click info button to change Mirror URL."];
        }
        else{
            [self urlError:@"Please check with your Mirror Administrator."];
        }
    }
    else {
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
            [NSAlert alertWithMessageText:@"Application error" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please add campus."];
            NSLog(@"No campuses were returned.");
        } else {
            if ([campusesJsonArray count] == 1) {
                [chooseCampusButton removeAllItems];
                [chooseCampusButton addItemWithTitle:[campusesJsonArray[0] objectForKey:@"name"]];
            }
            else
            {
                [chooseCampusButton removeAllItems];
                [chooseCampusButton addItemWithTitle:@"Choose your campus"];
                for(NSDictionary *json in campusesJsonArray) {
                    NSLog(@"Item: %@", json);
                    NSLog(@"name = %@", [json objectForKey:@"name"]);
                    [chooseCampusButton addItemWithTitle:[json objectForKey:@"name"]];
                }
            }
            
            chooseCampusButton.enabled = YES;
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
                 JSONData = data; //see note for respective code in iOS app ViewController
             }
             else if ([data length] == 0 && error == nil){
                 [self receivingDataError];
                 NSLog(@"data empty");
             }
             else{
                 [self receivingDataError];
                 NSLog(@"error = %@", error);
             }
         }];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(continueLoadingInitialSettings) userInfo:nil repeats:NO];
    }
}

- (IBAction)settings:(id)sender {
    
    [deviceView setHidden:YES];
    [chooseCampusButton setHidden:YES];
    [chooseBuildingButton setHidden:YES];
    [chooseRoomButton setHidden:YES];
    [loginURL setHidden:NO];
    [statusLabel setHidden:YES];
    [checkmark setHidden:YES];
}


- (void)resetUI{
    
}

- (IBAction)chooseCampus:(id)sender{
    
    NSLog(@"\n\n\n\nIn Campus\n\n\n\n");
    
    if ([[[chooseCampusButton selectedItem] title] isEqual:@"Choose your campus"]){
        [chooseBuildingButton removeAllItems];
        [chooseBuildingButton setHidden:YES];
        [chooseRoomButton removeAllItems];
        [chooseRoomButton setHidden:YES];
    }
    else{
        for (NSDictionary* json in campusesJsonArray){
            if ([[[chooseCampusButton selectedItem] title] isEqual:[json objectForKey:@"name"]]) {
                JSONData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@buildings&id=%@", jsonURL, [json objectForKey:@"id" ]]]];
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
                        [NSAlert alertWithMessageText:@"Application error" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please add building."];
                        NSLog(@"No buildings were returned.");
                    }
                    else {
                        {
                            [chooseBuildingButton removeAllItems];
                            [chooseBuildingButton setHidden:YES];
                            [chooseRoomButton removeAllItems];
                            [chooseRoomButton setHidden:YES];
                            [chooseBuildingButton addItemWithTitle:@"Choose your building"];
                            for(NSDictionary *json in buildingsJsonArray) {
                                NSLog(@"Item: %@", json);
                                NSLog(@"name = %@", [json objectForKey:@"name"]);
                                [chooseBuildingButton addItemWithTitle:[json objectForKey:@"name"]];
                            }
                        }
                        
                        [chooseBuildingButton setHidden:NO];
                        
                    }
                }
                break;
            }
        }
    }
}


- (IBAction)chooseBuilding:(id)sender{
    NSLog(@"\n\n\n\nIn Building\n\n\n\n");
    
    if ([[[chooseBuildingButton selectedItem] title] isEqual:@"Choose your building"]){
        [chooseRoomButton removeAllItems];
        [chooseRoomButton setHidden:YES];
    }
    else{
        for (NSDictionary* json in buildingsJsonArray){
            if ([[[chooseBuildingButton selectedItem] title] isEqual:[json objectForKey:@"name"]]) {
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
                        [NSAlert alertWithMessageText:@"Application error" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please add room."];
                        NSLog(@"No rooms were returned.");
                    }
                    else {
                        {
                            [chooseRoomButton removeAllItems];
                            [chooseRoomButton setHidden:YES];
                            [chooseRoomButton addItemWithTitle:@"Choose your room"];
                            for(NSDictionary *json in roomsJsonArray) {
                                NSLog(@"Item: %@", json);
                                NSLog(@"name = %@", [json objectForKey:@"name"]);
                                [chooseRoomButton addItemWithTitle:[json objectForKey:@"name"]];
                            }
                        }
                        
                        [chooseRoomButton setHidden:NO];
                        
                    }
                }
                break;
            }
        }
    }
}

- (IBAction)chooseRoom:(id)sender{
    for (NSDictionary* json in roomsJsonArray){
        if ([[[chooseRoomButton selectedItem] title] isEqual:[json objectForKey:@"name"]]) {
            JSONData = [NSData dataWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"%@devices&id=%@", jsonURL, [json objectForKey:@"id" ]]]];
            [statusLabel setHidden:NO];
            [checkmark setHidden:NO];
            if (JSONData == nil) {
                [self receivingDataError];
            } else {
                
                NSError *error = nil;
                
                devicesJsonArray = [NSJSONSerialization
                                      JSONObjectWithData:JSONData
                                      options:NSJSONReadingAllowFragments
                                      error:&error];
                
                NSLog(@"devicesJsonArray = %@", devicesJsonArray);
                
                if (!devicesJsonArray) {
                    NSLog(@"Error parsing JSON: %@", error);
                }
                else if ([devicesJsonArray count] < 1){
                    [NSAlert alertWithMessageText:@"Application error" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please add campus."];
                    NSLog(@"No campuses were returned.");
                }
                else
                {
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
                            NSLog(@"I am right before the connect");
                            [connection connectToAppleTVWithSettings:defaultJSON andDevices:devicesJsonArray];
                            //When history UI is ready, uncomment the code below and use history array to populate history UI.
                            /*
                             NSDictionary* individualHistory;
                             BOOL addIndividualHistory = YES;
                             
                             individualHistory = @{@"campus": [[chooseCampusButton selectedItem] title], @"building":[[chooseBuildingButton selectedItem] title], @"rooms":[[chooseRoomButton selectedItem] title]};
                             
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





@end
