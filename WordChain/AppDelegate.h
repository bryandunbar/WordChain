//
//  AppDelegate.h
//  WordChain
//
//  Created by Bryan Dunbar on 8/23/11.
//  Copyright Great American Insurance 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
    
    NSManagedObjectModel * managedObjectModel;
	NSManagedObjectContext * managedObjectContext;
	NSPersistentStoreCoordinator * persistentStoreCoordinator;
}

@property (nonatomic, retain) UIWindow *window;

@property (nonatomic, retain, readonly) NSManagedObjectModel * managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext * managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator * persistentStoreCoordinator;


@end
