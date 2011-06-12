//
//  iTunesModuleSource.m
//  iTunesModule
//
//  Created by James on 6/5/11.
//  Copyright university of md college park 2011. All rights reserved.
//

#import "iTunesModuleSource.h"


@implementation iTunesModuleSource

#pragma mark -
#pragma mark Load iTunes Module objects.

// Load iTunesModuleRating objects.
-(NSArray *) ratings {
    NSMutableArray *objects = [ NSMutableArray arrayWithCapacity:5 ];
    
    QSObject *object = [ QSObject objectWithName:@"5 Stars" ];
    [ object setObject:[ NSNumber numberWithInt:5 ] forType:iTunesModuleRating ];
    // set identifier?
    // [ object setIcon:[ QSResourceManager imageNamed:@"" ]];
    [ objects addObject:object ];
    
    object = [ QSObject objectWithName:@"4 Stars" ];
    [ object setObject:[ NSNumber numberWithInt:4 ] forType:iTunesModuleRating ];
    // set identifier?
    // [ object setIcon:[ QSResourceManager imageNamed:@"" ]];
    [ objects addObject:object ];
    
    object = [ QSObject objectWithName:@"3 Stars" ];
    [ object setObject:[ NSNumber numberWithInt:3 ] forType:iTunesModuleRating ];
    // set identifier?
    // [ object setIcon:[ QSResourceManager imageNamed:@"" ]];
    [ objects addObject:object ];
    
    object = [ QSObject objectWithName:@"2 Stars" ];
    [ object setObject:[ NSNumber numberWithInt:2 ] forType:iTunesModuleRating ];
    // set identifier?
    // [ object setIcon:[ QSResourceManager imageNamed:@"" ]];
    [ objects addObject:object ];
    
    object = [ QSObject objectWithName:@"1 Star" ];
    [ object setObject:[ NSNumber numberWithInt:1 ] forType:iTunesModuleRating ];
    // set identifier?
    // [ object setIcon:[ QSResourceManager imageNamed:@"" ]];
    [ objects addObject:object ];

    return objects;
}

// Load iTunes library objects. Referenced "https://github.com/quicksilver/Plugins/blob/master/DeliciousLibrary/QSDeliciousLibraryModule_Source.m".
-(NSArray *) iTunesLibraryWithLocation:(NSString *) location {
    //detach thread?
    
    // Parse iTunes library xml file.
    /* http://stackoverflow.com/questions/4299840/parsing-large-plist-and-memory-footprint
    NSData *data = [ NSData dataWithContentsOfFile:location ];
    NSXMLParser *parser = [[ NSXMLParser alloc ] initWithData:data ];
    iTunesParserDelegate *delegate = [[ iTunesParserDelegate alloc ] init ];
    
    [ parser setDelegate:delegate ];
    [ parser parse ];
    
    [ parser release ];
    [ delegate autorelease ];
    
    return [ delegate objects ];//retain this?
    */
    
    // For now:
    NSDictionary *library = [ NSDictionary dictionaryWithContentsOfFile:location ];
    NSMutableArray *objects = [ NSMutableArray arrayWithCapacity:100 ];

    for ( NSDictionary *tracks in [ library objectForKey:@"Tracks" ]) {
        for ( NSDictionary *track in tracks) {
            NSDictionary *newTrack = [ NSDictionary dictionaryWithObjectsAndKeys:
                                      [ track objectForKey:@"Name" ], @"Name",
                                      [ track objectForKey:@"Track ID" ], @"Track ID",
                                      [ track objectForKey:@"Artist" ], @"Artist",
                                      [ track objectForKey:@"Genre" ], @"Genre",
                                      // file location
                                      nil ];
            QSObject *object = [ QSObject objectWithName:[ track objectForKey:@"Name" ]];
            [ object setObject:newTrack forType:iTunesModuleSong ];
            // set text, url type?
            [ object setIdentifier:[ iTunesModuleSong stringByAppendingFormat:@"%d", [ track objectForKey:@"Track ID" ]]];
            
            [ objects addObject:object ];
        }
    }
    
    // add current song proxy
    return objects;
}

// Get iTunes library location.
-(NSString *) iTunesLibraryLocation  {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [ defaults addSuiteNamed:@"com.apple.iTunes" ];
    NSString *location = [[ defaults objectForKey:@"NSNavLastRootDirectory" ] stringByAppendingString:@"iTunes Music Library.xml" ];
    [ defaults removeSuiteNamed:@"com.apple.iTunes" ];
    
    return location;
}

#pragma mark -
#pragma mark iTunes Module source.

- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    if ( [[ theEntry objectForKey:@"name" ] isEqualToString:@"Ratings" ])
        return YES;
    else if ( [[ theEntry objectForKey:@"name" ] isEqualToString:@"iTunes Library" ]) {
        // Compare last modified date of iTunes library.
        NSString *location = [ self iTunesLibraryLocation ];
        NSError *err = nil;
        NSDictionary *xmlAttributes = [[ NSFileManager defaultManager ] attributesOfItemAtPath:location error:&err ];
        if ( err)
            return NO;
        
        return [[ xmlAttributes objectForKey:NSFileModificationDate ] isEqualToString:[ theEntry objectForKey:NSFileModificationDate ]];
    }
    
    return YES;
}

- (NSImage *) iconForEntry:(NSDictionary *)dict{
    return nil;
}


// Return a unique identifier for an object (if you haven't assigned one before)
//- (NSString *)identifierForObject:(id <QSObject>)object{
//    return nil;
//}

- (NSArray *) objectsForEntry:(NSDictionary *)theEntry{
    id notifier = [[QSRegistry sharedInstance] preferredNotifier];
    
    if( notifier != nil) {
        [notifier displayNotificationWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                     @"itunesmodule", QSNotifierText,
                                                     [ theEntry objectForKey:@"name" ], QSNotifierTitle,
                                                     NULL, QSNotifierIcon,
                                                     nil]];
        return;
    }
    
    
    NSArray *objects;
    
    if ( [[ theEntry objectForKey:@"name" ] isEqualToString:@"Ratings" ]) {
        objects = [ self ratings ];
    }
    else if ( [[ theEntry objectForKey:@"name" ] isEqualToString:@"iTunes Library" ]) {
        NSString *location = [ self iTunesLibraryLocation ];
    
        // Get last modified date of iTunes library.
        NSError *err = nil;
        NSDictionary *xmlAttributes = [[ NSFileManager defaultManager ] attributesOfItemAtPath:location error:&err ];
        if ( err) {
            [ theEntry setValue:@"Error retrieving last modified date of iTunes library." forKey:NSFileModificationDate ];// Can i do this???
        }
        else {
            [ theEntry setValue:[ xmlAttributes objectForKey:NSFileModificationDate ] forKey:NSFileModificationDate ];// Can i do this???
        }

        objects = [ self iTunesLibraryWithLocation:location ];
    }
  
    return objects;
}

- (BOOL)objectHasChildren:(QSObject *)object {
    return YES;
}

- (NSArray *)validIndirectObjectsForAction:(NSString *)action directObject:(QSObject *)dObject {
    if ([ action isEqualToString:@"Rate Song" ])
        //add text input //[QSObject textProxyObjectWithDefaultValue:@""]
        return [ QSLib scoredArrayForString:nil inSet:[ QSLib arrayForType:iTunesModuleRating ]];
    
    return nil;
}

// Object Handler Methods

/*
- (void)setQuickIconForObject:(QSObject *)object{
    [object setIcon:nil]; // An icon that is either already in memory or easy to load
}
- (BOOL)loadIconForObject:(QSObject *)object{
	return NO;
    id data=[object objectForType:iTunesModuleType];
	[object setIcon:nil];
    return YES;
}
*/
@end
