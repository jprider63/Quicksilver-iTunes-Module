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
    [ object setObject:[ NSNumber numberWithInt:100 ] forType:iTunesModuleRating ];
    //[ object setEnabled ];??
    //[[ QSLibrarian sharedInstance ] setItem:object isOmitted:YES ];
    
    
    // set identifier?
    // [ object setIcon:[ QSResourceManager imageNamed:@"" ]];
    [ objects addObject:object ];
    
    object = [ QSObject objectWithName:@"4 Stars" ];
    [ object setObject:[ NSNumber numberWithInt:80 ] forType:iTunesModuleRating ];
    // set identifier?
    // [ object setIcon:[ QSResourceManager imageNamed:@"" ]];
    [ objects addObject:object ];
    
    object = [ QSObject objectWithName:@"3 Stars" ];
    [ object setObject:[ NSNumber numberWithInt:60 ] forType:iTunesModuleRating ];
    // set identifier?
    // [ object setIcon:[ QSResourceManager imageNamed:@"" ]];
    [ objects addObject:object ];
    
    object = [ QSObject objectWithName:@"2 Stars" ];
    [ object setObject:[ NSNumber numberWithInt:40 ] forType:iTunesModuleRating ];
    // set identifier?
    // [ object setIcon:[ QSResourceManager imageNamed:@"" ]];
    [ objects addObject:object ];
    
    object = [ QSObject objectWithName:@"1 Star" ];
    [ object setObject:[ NSNumber numberWithInt:20 ] forType:iTunesModuleRating ];
    // set identifier?
    // [ object setIcon:[ QSResourceManager imageNamed:@"" ]];
    [ objects addObject:object ];

    return objects;
}

// Load iTunes songs. Referenced "https://github.com/quicksilver/Plugins/blob/master/DeliciousLibrary/QSDeliciousLibraryModule_Source.m".
-(NSArray *) iTunesSongsWithLocation:(NSString *) location {
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

    for ( NSDictionary *track in [[ library objectForKey:@"Tracks" ] allValues ]) {
	    NSDictionary *newTrack = [ NSDictionary dictionaryWithObjectsAndKeys:
		    [ track objectForKey:@"Name" ], @"Name",
		    [ track objectForKey:@"Track ID" ], @"Track ID",
		    [ track objectForKey:@"Artist" ], @"Artist",
		    [ track objectForKey:@"Genre" ], @"Genre",
		    // file location
		    nil ];
	    QSObject *object = [ QSObject objectWithName:[ track objectForKey:@"Name" ]];
	    [ object setObject:newTrack forType:iTunesModuleSong ];
        [ object setDetails: [ track objectForKey:@"Artist" ]];
	    // set text, url type?
	    [ object setIdentifier:[ iTunesModuleSong stringByAppendingFormat:@"%d", [ track objectForKey:@"Track ID" ]]];

	    [ objects addObject:object ];
    }
    
    // add current song proxy
    return objects;
}

// Get iTunes library location.
-(NSString *) iTunesLibraryLocation  {
    /*NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [ defaults addSuiteNamed:@"com.apple.iTunes" ];
    NSString *location = [[ defaults stringForKey:@"NSNavLastRootDirectory" ] stringByAppendingString:@"/iTunes Music Library.xml" ];
    [ defaults removeSuiteNamed:@"com.apple.iTunes" ];
    */

    //for now:
    NSString *location = @"/users/james/Music/iTunes/iTunes Music Library.xml";
    
    return location;
}

#pragma mark -
#pragma mark iTunes Module source.

// Referenced "https://github.com/pjrobertson/1Password-Plugin/blob/master/OnePasswordSource.m".
- (BOOL)indexIsValidFromDate:(NSDate *)indexDate forEntry:(NSDictionary *)theEntry{
    // NSLog(@"indexIsValidFromDate: called\n%@", [ theEntry description ]);
    
    return NO;
    
    if ( [[ theEntry objectForKey:@"name" ] isEqualToString:@"Ratings" ])
        return YES;// isFirstRun/isStartingUp?
    else if ( [ theEntry objectForKey:@"iTunes item" ]) { //[[ theEntry objectForKey:@"name" ] isEqualToString:@"Songs" ]) {
        // Compare last modified date of iTunes library.
        NSString *location = [ self iTunesLibraryLocation ];
        NSError *err = nil;
        NSFileManager *mgmt = [[ NSFileManager alloc ] init ];
        NSDictionary *xmlAttributes = [ mgmt attributesOfItemAtPath:location error:&err ]; // retain this?
        
        if ( err) {
            [ mgmt release ];
            return NO;
        }
        
        NSDate *modificationDate = [ xmlAttributes objectForKey:NSFileModificationDate ];
        Boolean modified = ([ modificationDate compare:indexDate ] == NSOrderedAscending );
        
        [ mgmt release ];
        return modified;
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
    // NSLog(@"objectsForEntry: called\n%@", [ theEntry description ]);
    
    NSArray *objects = nil;
    NSString *name = [ theEntry objectForKey:@"name" ];
    
    /*if ( [[ theEntry objectForKey:@"name" ] isEqualToString:@"iTunes" ])
        return [ theEntry objectForKey:@"children" ];
    else*/
    if ([ name isEqualToString:@"Ratings" ]) {
        objects = [ self ratings ];
    }
    else if ([ name isEqualToString:@"Songs" ]) {
        // NSLog(@"in Songs");
        NSString *location = [ self iTunesLibraryLocation ];
        // NSLog(@"%@", location);

        objects = [ self iTunesSongsWithLocation:location ];
    }
  
    return objects;
}

- (BOOL)objectHasChildren:(QSObject *)object {
    return NO;
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
