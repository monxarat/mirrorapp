Mirror App
=========

Mirror is an enterprise iOS and OS X app that allows you to wirelessly share content and mirror your iPad or iPhone screen to select classroom displays. In order to accomplish this Mirror acts as a bonjour repeater broadcasting an appletv registration to the device. The user is presented with a list of registrations that are stored on a [Mirror App Server](https://github.com/psutlt/mirrorapp-server), which is located in another github project. [AirServer](http://www.airserver.com/) and [Reflector](http://www.airsquirrels.com/reflector/) are also supported as an alternative to the AppleTV.

Project development and feedback is encouraged and a Yammer partner group can be accessd by signing up to become a partner at [http://mirror.psu.edu/](http://mirror.psu.edu/).  

![Mirror image](http://mirror.psu.edu/wp-content/uploads/sites/4426/2014/02/MirrorFrame-151x300.png)![architecture](https://sites.psu.edu/airplay/wp-content/uploads/sites/4426/2014/07/architecture.png)

This project is currently developed on XCode 5.1.1 and contains two targets.

* iOSMirror - iOS version of the application for iPad, iPhone, and iPod touch
* OSXMirror - OS X version

(airplay mirroring requirements : [iOS][iOS], [OS X][OS X])
[iOS]: http://support.apple.com/kb/ht5209
[OS X]: http://support.apple.com/kb/ht5404

## Requirements

 * XCode >= 5.1.1
 * iOS Enterprise Developer Program needed for distribution of iOS version - [https://developer.apple.com/programs/ios/enterprise/](https://developer.apple.com/programs/ios/enterprise/) 
 * A working Mirror App Server - [https://github.com/psutlt/mirrorapp-server](https://github.com/psutlt/mirrorapp-server)
 

## Setup

Several settings need to changed in the project before compiling for each platform.

#### For iOS: ([Apple Documentation](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/ConfiguringYourApp/ConfiguringYourApp.html#//apple_ref/doc/uid/TP40012582-CH28-SW1))

1. In the iOSMirror target, under General properties, set the appropriate Bundle identifier, Version and Team for your Enterprise Developer Account.
2. In build settings, under code signing make sure to specify the "Code Signing Identity" you wish to use for developemnt.
3. In the file **SharedMirror/constants.h**: Set the url of the your Mirror App Server
4. In the file **SharedMirror/iOSconstants.h**: Set the url for your App distribution point. When you compile your enterprise app for distribution an iOSMirror.ipa and iOSMirror.plist file will be created. This url is the location of the web server where these files will be located.
5. To build the enterprise iOS app, first select the iOSMirror target and your device, then choose Product-> Archive from the menu in Xcode.
6. Select "Distribute" from the right and choose "Save for Enterprise or Ad Hoc Deployment". Click Next.
7. Select the Provsioning Profile to use for your enterprise account. Click Export.
8. Select the "Save for Enterprise Distribution" checkbox and enter the "Application URL" where your app will be located (i.e. - https://mirrordemo.tlt.psu.edu/app/mirror/iOSMirror.ipa).
9. Enter the "Mirror" as the Title.
10. Save your file locally and upload both files to the web path you specified earlier.


#### For OS X: ([Apple Documentation](https://developer.apple.com/library/ios/documentation/IDEs/Conceptual/AppDistributionGuide/DistributingApplicationsOutside/DistributingApplicationsOutside.html#//apple_ref/doc/uid/TP40012582-CH12-SW2))

1. In the OSXMirror target, under General properties, set the appropriate Bundle identifier and Version.
2. Select "Developer ID" for signing, and choose the appropriate Team for your Enterprise Developer Account.
3. In build settings, under code signing make sure to specify the "Code Signing Identity" you wish to use for developemnt.
4. In the file **SharedMirror/constants.h**: Set the url of the your Mirror App Server
5. To build the enterprise OS X app, first select the OSXMirror target and your computer, then choose Product-> Archive from the menu in Xcode.
6. Select "Distribute" from the right and choose "Export Developer ID-signed Application". Click Next.
7. Select the Developer ID to use for your OS X enterprise account. Click Export.
8. Save your OSX App locally and distribute to your organization.

## Distribution methods

Apple requires that an Enterprise App must be restricted to only your institution. For distribuition at Penn State we are using an IP restricted download. The reason we chose this method is to allow the auto-updating feature we wrote into the iOS App to work. If we were using some other authentication method iOS wouldn't be able to install the App directly to the device, or allow the app to auto-update. Each time the iOS App loads it checks the iOSMirror.plist file on the server for the latest version. If the latest version is not installed it will ask the user to update. If the user chooses to update the App will automatically be re-downloaded. An MDM server can also be used. We haven't written the auto-update capability into the OS X Version yet.

## Contributors

* Sherwyn Saul 
* Jason Heffner
* Ben Brautigum 

## License

Copyright: © 2014, The Pennsylvania State University  
Distributed under MIT License
