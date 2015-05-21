//
//  NSManagedObjectContext+NSPTask.h
//  Canopus
//
//  Created by Janos Tolgyesi on 04/05/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <CoreData/CoreData.h>

@class BFTask;

@interface NSManagedObjectContext (NSPTask)

-(BFTask*)executeFetchRequestInBackground:(NSFetchRequest*)fetchRequest;
-(BFTask*)performBlockInBackground:(id (^)(NSError* __autoreleasing *))block;

@end
