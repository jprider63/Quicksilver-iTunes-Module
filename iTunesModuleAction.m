//
//  iTunesModuleAction.m
//  iTunesModule
//
//  Created by James on 6/5/11.
//  Copyright university of md college park 2011. All rights reserved.
//

#import "iTunesModuleAction.h"

@implementation iTunesModuleAction

#pragma mark -
#pragma mark iTunes Module actions.

- (QSObject *)playNextInPartyShuffle:(QSObject *)dObject{
	return nil;
}

- (QSObject *)playSong:(QSObject *)dObject{
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    if ( [iTunes isRunning] ) {
        [ self displayNotification:[[iTunes currentTrack] name] andTitle:@"" usingIcon:nil ];
    }
    else
        [ self displayNotification:@"iTunes is not playing a song" andTitle:@"" usingIcon:nil ];
    
	return nil;
}

- (QSObject *)rateSong:(QSObject *)dObject{
	return nil;
}

#pragma mark -
#pragma mark Notification methods.

// Referenced QSWeatherPlugin at "https://github.com/quicksilver/Plugins/blob/master/QSWeatherPlugin/trunk/QSWeatherPluginAction.m".
-(void)displayNotification:(NSString*)data andTitle:(NSString *)title usingIcon:(NSImage *) icon {
    id notifier = [[QSRegistry sharedInstance] preferredNotifier];
    
    if( notifier != nil) {
        [notifier displayNotificationWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     data, QSNotifierText,
                                                     title, QSNotifierTitle,
                                                     icon, QSNotifierIcon,
                                                     nil]];
        return;
    }
}

@end
