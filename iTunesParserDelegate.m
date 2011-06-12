//
//  iTunesParserDelegate.m
//  iTunesModule
//
//  Created by James on 6/11/11.
//  Copyright 2011 university of md college park. All rights reserved.
//

#import "iTunesParserDelegate.h"


@implementation iTunesParserDelegate

- (id)init
{
    self = [super init];
    if (self) {
        objects = [ NSMutableArray arrayWithCapacity:100 ];
        currentObject = NULL;
        currentStartSelector = NULL;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

#pragma mark -
#pragma mark XML parser delegate.

// better to simply iterate through Tracks nsdictionary at end?
-(void) parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if ( currentStartSelector)
        [ self performSelector:currentStartSelector withObject:elementName withObject:attributeDict ];
    else if ( [ elementName isEqualToString:@"Tracks" ]) {
        currentStartSelector = @selector(startParseTrack:attributes:);//sel_getUid?
        currentEndSelector = @selector(endParseTrack:);//sel_getUid?
    }
        
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ( currentEndSelector)
        [ self performSelector:currentEndSelector withObject:elementName ];
    else if ( [ elementName isEqualToString:@"Tracks" ]) {
        currentStartSelector = NULL;
        currentEndSelector = NULL;
    }
}

// Assumes "Track ID" always comes first.
-(void) startParseTrack:(NSString *) name attributes:(NSDictionary *) attributes {
    if ( [ name isEqualToString:@"Track ID" ]) {
        currentObject = [[ NSDictionary alloc ] initWithObjectsAndKeys:@"Track ID", , nil ];//
    }
}

@end
