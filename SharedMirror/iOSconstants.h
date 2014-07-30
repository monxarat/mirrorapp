//
//  iOSconstatns.h
//  Mirror
//
//  Copyright 2014, The Pennsylvania State University
//  Distributed under MIT License
//
//  Change the mirrordemo.tlt.psu.edu url below to point to your own distribution point for the latest updates.
//  VERSION_FILE_PATH points to the plist file containing the current version number of your Mirror App
//  This can be a different url than your Mirror App Server
//

#define ENTAPP_HOST @"mirrordemo.tlt.psu.edu"

#define VERSION_FILE_PATH (@"https://" ENTAPP_HOST @"/app/mirror/iOSMirror.plist")
#define URL_TO_UPDATE (@"itms-services://?action=download-manifest&url=https://" ENTAPP_HOST @"/app/mirror/iOSMirror.plist")
