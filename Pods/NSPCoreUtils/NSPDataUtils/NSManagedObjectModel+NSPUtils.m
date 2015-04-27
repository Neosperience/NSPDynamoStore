//
//  NSManagedObjectModel+NSPUtils.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 03/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSManagedObjectModel+NSPUtils.h"

@implementation NSManagedObjectModel (NSPUtils)

-(NSEntityDescription *)entityForManagedObjectClass:(Class)managedObjectClass
{
    NSString* managedObjectClassName = NSStringFromClass(managedObjectClass);
    NSArray* matchingEntities = [self.entities filteredArrayUsingPredicate:
                                 [NSPredicate predicateWithFormat:@"managedObjectClassName == %@", managedObjectClassName]];
    return [matchingEntities firstObject];
}

@end
