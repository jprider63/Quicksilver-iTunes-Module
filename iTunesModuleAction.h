//
//  iTunesModuleAction.h
//  iTunesModule
//
//  Created by James on 6/5/11.
//  Copyright university of md college park 2011. All rights reserved.
//

#import <QSCore/QSActionProvider.h>
#import "iTunesModule.h"

#define kiTunesModuleAction @"iTunesModuleAction"

@interface iTunesModuleAction : QSActionProvider
{
}
// Sleep action to fade out volume over period of time?

// Notification methods.
-(void)displayNotification:(NSString*)data andTitle:(NSString *)title usingIcon:(NSImage *) icon;
@end

