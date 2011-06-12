//
//  iTunesParserDelegate.h
//  iTunesModule
//
//  Created by James on 6/11/11.
//  Copyright 2011 university of md college park. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface iTunesParserDelegate : NSObject <NSXMLParserDelegate> {
    NSMutableArray *objects;
    SEL currentStartSelector;
    SEL currentEndSelector;
    id currentObject;
}

@end
