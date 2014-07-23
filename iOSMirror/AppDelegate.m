//
//  AppDelegate.m
//  iOSMirror
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        UIStoryboard *storyBoard;
        
        storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        
        self.viewController = [storyBoard instantiateViewControllerWithIdentifier:@"launchiPhone"];
        
        
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        UIStoryboard *storyBoard;
        storyBoard = [UIStoryboard storyboardWithName:@"Main_iPad" bundle:nil];
        
        self.viewController = [storyBoard instantiateViewControllerWithIdentifier:@"launchiPad"];
    }
    
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [self checkRemoteVersion];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    
    // Dispatch notification to controllers
    [[NSNotificationCenter defaultCenter] postNotificationName: @"didBecomeActive"
                                                        object: nil
                                                      userInfo: nil];
}

- (NSString *) getThisVersion
{
    // get version of this app
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (void)promptUpdateToVersion:(NSString *)newVersion FromVersion:(NSString *)oldVersion
{
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:[NSString stringWithFormat:@"Version %@ Available", newVersion]
                          message:[NSString stringWithFormat:@"This application (Version %@) is outdated. Do you want to download the latest version from the internet?", oldVersion]
                          delegate:self
                          cancelButtonTitle:@"No"
                          otherButtonTitles:@"Update", nil];
    [alert show];
    
}

- (void) checkRemoteVersion
{
    // read the local version
    NSString *thisVersion = [self getThisVersion];
    
    // insert additional iOS info
    NSString *udidVendor = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSLog(@"SSUID %@", udidVendor);
    NSString *VERSION_FILE_PATH_WITH_UUID = [NSString stringWithFormat:@"%@%s%@", VERSION_FILE_PATH, "?udid=", udidVendor];
    
    // load remote version!
    NSDictionary *versionFile = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:VERSION_FILE_PATH_WITH_UUID]];
    
    if(versionFile != nil)
    {
        
        // look for latest version in the remote pondscatalogue.plist file
        
        NSArray *items = (NSArray *)[versionFile objectForKey:@"items"];
        NSDictionary *metaData;
        NSString *latestVersion;
        for(NSDictionary *dict in items)
        {
            metaData = [dict objectForKey:@"metadata"];
            if(metaData != nil)
            {
                latestVersion = [metaData objectForKey:@"bundle-version"];
                break;
            }
        }
        NSLog(@"application version %@", thisVersion);
        NSLog(@"latest version is %@", latestVersion);
        if([latestVersion floatValue] > [thisVersion floatValue])
        {
            // the remote plist shows that there is a newer version available
            // prompt user whether he want to update
            [self promptUpdateToVersion:latestVersion FromVersion:thisVersion];
        }
    }   // else problem reading the remote version file, just don't prompt user anything about version
}
- (void)launchSafari:(NSString *) siteUrl
{
    NSURL *url = [ [ NSURL alloc ] initWithString: siteUrl];
    [[UIApplication sharedApplication] openURL:url];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex)
    {
        case 0: //stay
            NSLog(@"user stay");
            break;
        case 1: //open safari
            NSLog(@"user wanna update");
            [self launchSafari:URL_TO_UPDATE];
            exit(0);
            //break;
    }
}

@end
