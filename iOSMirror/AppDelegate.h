//
//  AppDelegate.h
//  iOSMirror
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#import "constants.h"
#import "iOSconstants.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;

-(NSString *) getThisVersion;
-(void) promptUpdateToVersion:(NSString *)newVersion FromVersion:(NSString *)oldVersion;
-(void) checkRemoteVersion;
-(void) launchSafari:(NSString *) siteUrl;
-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end
