//
//  DefaultData.m
//  Text Memory
//
//  Created by Geoffrey Hom on 9/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DefaultData.h"
#import "Text.h"
#import "TextMemoryAppDelegate.h"

NSString *defaultStoreName = @"defaultDataStore.sqlite";

NSString *welcomeTextTitle = @"Introduction";

// Private category for private methods.
@interface DefaultData ()

// Add the default data (from a property list) to the given context.
+ (void)addDefaultData:(NSManagedObjectContext *)theManagedObjectContext;

@end

@implementation DefaultData

+ (void)addDefaultData:(NSManagedObjectContext *)theManagedObjectContext {
	
	// Get the default data from the default-data property list.
	NSString *defaultDataPath = [[NSBundle mainBundle] pathForResource:@"default-data" ofType:@"plist"];
	NSFileManager *aFileManager = [[NSFileManager alloc] init];
	NSData *defaultDataXML = [aFileManager contentsAtPath:defaultDataPath];
	[aFileManager release];
	NSString *errorDesc = nil; 
	NSPropertyListFormat format;
	NSDictionary *rootDictionary = (NSDictionary *)[NSPropertyListSerialization propertyListFromData:defaultDataXML mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorDesc];
	if (!rootDictionary) { 
		NSLog(@"Error reading default plist: %@, format: %d", errorDesc, format);
	} else {
		
		// The property list is a dictionary of Texts: The key is the Text's title, and the value is the Text. Each Text is also represented by a dictionary.
		NSString *textTitleString;
		Text *aText;
		NSDictionary *intraTextDictionary;
		NSString *key;
		for (textTitleString in rootDictionary) {
			
			// Add the Text to the context.
			aText = (Text *)[NSEntityDescription insertNewObjectForEntityForName:@"Text" inManagedObjectContext:theManagedObjectContext];
			aText.title = textTitleString;
			aText.isDefaultData = YES;
			intraTextDictionary = [rootDictionary objectForKey:textTitleString];
			for (key in intraTextDictionary) {
				if ([key isEqualToString:@"Text"]) {
					aText.text = [intraTextDictionary objectForKey:key];
				}
			}
		}
	}
	
	NSError *error; 
	if (![theManagedObjectContext save:&error]) {
		NSLog(@"DefaultData: Error saving default data.");
		NSLog(@"DefaultData: Error is:%@", [error localizedDescription]);
		NSDictionary *aDictionary = [error userInfo];
		NSArray *anArray = (NSArray *)[aDictionary valueForKey:NSDetailedErrorsKey];
		for (error in anArray) {
			NSLog(@"testing error:%@", [error localizedDescription]);
		}
	}
	NSLog(@"Default data added from property list to store.");
}

+ (void)copyDefaultStoreToURL:(NSURL *)theURL {
	
	NSURL *defaultStoreURL = [[NSBundle mainBundle] URLForResource:defaultStoreName withExtension:nil];
	if (defaultStoreURL) {
		NSFileManager *aFileManager = [[NSFileManager alloc] init];
		[aFileManager copyItemAtURL:defaultStoreURL toURL:theURL error:NULL];
		[aFileManager release];
		NSLog(@"Default store copied.");
	} else {
		NSLog(@"Warning: Default store not found in main bundle.");
	}
}

+ (void)makeStore {
	
	NSLog(@"Making default-data store.");
	
	// Delete existing default-data store, if any.
	NSFileManager *aFileManager = [[NSFileManager alloc] init];
	TextMemoryAppDelegate *aTextMemoryAppDelegate = [[UIApplication sharedApplication] delegate];
	NSURL *documentDirectoryURL = [aTextMemoryAppDelegate applicationDocumentsDirectory];
	NSURL *defaultStoreURL = [documentDirectoryURL URLByAppendingPathComponent:defaultStoreName];
	BOOL deletionResult = [aFileManager removeItemAtURL:defaultStoreURL error:nil];
	NSLog(@"Deleted previous default-data store from application's document directory: %d", deletionResult);
	[aFileManager release];
	
	// Remove the main store from the persistent store coordinator.
	NSURL *mainStoreURL = [documentDirectoryURL URLByAppendingPathComponent:mainStoreName];
	NSPersistentStoreCoordinator *aPersistentStoreCoordinator = [aTextMemoryAppDelegate persistentStoreCoordinator];
	NSPersistentStore *mainPersistentStore = [aPersistentStoreCoordinator persistentStoreForURL:mainStoreURL];
	[aPersistentStoreCoordinator removePersistentStore:mainPersistentStore error:nil];
	
	// Add the default-data store to the persistent store coordinator.
	NSError *error = nil;
	NSPersistentStore *defaultPersistentStore = [aPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:defaultStoreURL options:nil error:&error];
	if (!defaultPersistentStore) {
		NSLog(@"Unresolved error making default store: %@, %@", error, [error userInfo]);
	} else {
		NSLog(@"Default store added: %@", [defaultStoreURL path]);
	}
	
	// Populate the store.
	[DefaultData addDefaultData:[aTextMemoryAppDelegate managedObjectContext]];
	
	// Remove the default-data store and add back the main store.
	[aPersistentStoreCoordinator removePersistentStore:defaultPersistentStore error:nil];
	[aPersistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:mainStoreURL options:nil error:nil];
}

+ (void)restore {
	
	// Proceed only if the main store exists.
	TextMemoryAppDelegate *aTextMemoryAppDelegate = [[UIApplication sharedApplication] delegate];
	NSURL *mainStoreURL = [[aTextMemoryAppDelegate applicationDocumentsDirectory] URLByAppendingPathComponent:mainStoreName];
	NSString *mainStorePath = [mainStoreURL path];
	NSFileManager *aFileManager = [[NSFileManager alloc] init];
	if ([aFileManager fileExistsAtPath:mainStorePath]) {
		
		// Fetch all default-data texts. Delete them.
		NSManagedObjectContext *aManagedObjectContext = [aTextMemoryAppDelegate managedObjectContext];
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Text" inManagedObjectContext:aManagedObjectContext];
		[fetchRequest setEntity:entityDescription];
		
		// isDefaultData_ is a BOOL but is stored in Core Data as an NSNumber. Fortunately, predicate below seems to work.
		NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isDefaultData_ == YES"]; 
		
		[fetchRequest setPredicate:predicate];
		NSError *error = nil;
		NSArray *array = [aManagedObjectContext executeFetchRequest:fetchRequest error:&error];
		[fetchRequest release];
		if (array == nil) {
			NSLog(@"fetch failed?");
		}
		NSLog(@"DD restore: fetch count:%d", array.count);
		
		// delete...
		
		// add the default ones from the default-data store. How to copy from one persistent store to another?
		//NSLog(@"Copying default-data store to main store.");
	} 
	[aFileManager release];
}

@end
