//
//  NSManagedObjectModel+NSPUtils.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 03/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectModel (NSPUtils)

-(NSEntityDescription*)entityForManagedObjectClass:(Class)managedObjectClass;

@end
