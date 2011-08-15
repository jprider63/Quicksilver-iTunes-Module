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

// Referenced "http://stackoverflow.com/questions/1138759/convert-first-number-in-an-nsstring-into-an-integer".
- (QSObject *)rateSong:(QSObject *)dObject withRating:(QSObject *)iObject {
    // TODO: force single iObject
    NSNumber *rating;
    
    // Object is and iTunes Module Rating.
    if ([ iObject containsType:iTunesModuleRating ]) {
        rating = [ iObject objectForType:iTunesModuleRating ];
    }
    else if ([ iObject containsType:NSStringPboardType ]) {
        NSCharacterSet* nonDigits = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        int parsed = [[[ iObject objectForType:NSStringPboardType ] stringByTrimmingCharactersInSet:nonDigits] intValue ];
        
        if ( parsed > 5 || parsed < 1) {
            // display "Please select a rating from 1 to 5." large text//3rd pane??
            return nil;
        }
        
        rating = [ NSNumber numberWithInt:parsed * 20 ];
    }
    
    iTunesApplication *iTunes = [SBApplication applicationWithBundleIdentifier:@"com.apple.iTunes"];
    
    if ( [iTunes isRunning] ) {
        iTunesLibraryPlaylist *library = [[ iTunes sources ] objectAtIndex:0 ];
        //[[librarySource playlists] objectAtIndex:1]?
        
        // For now, not efficient:
        for ( NSString *song in [ dObject arrayForType:iTunesModuleSong ]) {
            [[ library searchFor:song only:iTunesESrASongs ] setRating:[ rating integerValue ]];
        }
    }
    else {
        // display "iTunes is not currently running." large text//3rd pane??
        NSBeep();
        
        return nil;
    }

	return nil;
}

#pragma mark -
#pragma mark QSActionProvider methods.

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject {
    NSLog(@"validIndirectObjectsForAction: %@", action);
    if ([ action isEqualToString:@"Rate Song" ])
        //add text input //[QSObject textProxyObjectWithDefaultValue:@""]
        return [ QSLib scoredArrayForString:nil inSet:[ QSLib arrayForType:iTunesModuleRating ]];
    
    return nil;
}


#pragma mark -
#pragma mark Notification methods.

// Referenced QSWeatherPlugin at "https://github.com/quicksilver/Plugins/blob/master/QSWeatherPlugin/trunk/QSWeatherPluginAction.m".
-(void)displayNotification:(NSString*)data andTitle:(NSString *)title usingIcon:(NSImage *) icon {
    id notifier = [[ QSRegistry sharedInstance ] preferredNotifier ];
    
    if( notifier) {
        [ notifier displayNotificationWithAttributes:[ NSDictionary dictionaryWithObjectsAndKeys:
                                                     data, QSNotifierText,
                                                     title, QSNotifierTitle,
                                                     icon, QSNotifierIcon,
                                                     nil ]];
    }
}

@end
