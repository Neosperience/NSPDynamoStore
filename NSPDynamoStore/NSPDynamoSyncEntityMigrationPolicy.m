//
//  NSPDynamoSyncEntityMigrationPolicy.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 13/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPDynamoSyncEntityMigrationPolicy.h"
#import "NSEntityDescription+NSPDynamoStore.h"

@implementation NSPDynamoSyncEntityMigrationPolicy

-(BOOL)beginEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    NSLog(@"BEGIN entity mapping: %@", mapping.sourceEntityName);
    return [super beginEntityMapping:mapping manager:manager error:error];
}

-(BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sourceInstance
                                     entityMapping:(NSEntityMapping *)mapping
                                           manager:(NSMigrationManager *)manager
                                             error:(NSError *__autoreleasing *)error
{
    NSString* sourceHashKeyName = [sourceInstance.entity nsp_dynamoHashKeyName];
    id hashKeyValue = [sourceInstance valueForKey:sourceHashKeyName];

    NSEntityDescription* destinationEntity = [manager.destinationModel entitiesByName][mapping.destinationEntityName];
    NSString* destinationHashKeyName = [destinationEntity nsp_dynamoHashKeyName];

    NSLog(@"CREATE destination for source with key: %@ == %@", sourceHashKeyName, hashKeyValue);
    NSLog(@"    destination entity: %@, key name: %@", destinationEntity.name, destinationHashKeyName);

    // first try to fetch if an existing object exists with this hash key
    NSFetchRequest* existingDestinationRequest = [NSFetchRequest fetchRequestWithEntityName:mapping.destinationEntityName];
    NSPredicate* existingDestinationPredicate = [NSPredicate predicateWithFormat:@"%K == %@", destinationHashKeyName, hashKeyValue];
    existingDestinationRequest.predicate = existingDestinationPredicate;
    existingDestinationRequest.fetchLimit = 1;

    NSError* fetchError = nil;
    NSArray* existingObjects = [manager.destinationContext executeFetchRequest:existingDestinationRequest error:&fetchError];

    if (fetchError) {
        if (error) *error = fetchError;
        return NO;
    }

    NSManagedObject* destinationInstance = [existingObjects lastObject];

    if (!destinationInstance) {
        // no existing object, create a new one
        NSLog(@"    NO existing instance, creating new");
        destinationInstance = [NSEntityDescription insertNewObjectForEntityForName:mapping.destinationEntityName
                                                            inManagedObjectContext:manager.destinationContext];
    } else {
        NSLog(@"    existing instance found, updating");
    }

    // update object with new attributes
    
    for (NSPropertyMapping* attributeMapping in mapping.attributeMappings) {

        NSMutableDictionary *context =
            [@{ NSMigrationManagerKey : manager,
                NSMigrationSourceObjectKey : sourceInstance,
                NSMigrationDestinationObjectKey : destinationInstance,
                NSMigrationEntityMappingKey : mapping,
                NSMigrationPropertyMappingKey : attributeMapping,
                NSMigrationEntityPolicyKey : self } mutableCopy];

        id expressionResult = [attributeMapping.valueExpression expressionValueWithObject:nil context:context];
        NSString* destinationAttributeName = attributeMapping.name;
        [destinationInstance setValue:expressionResult forKey:destinationAttributeName];
        NSLog(@"    set value for key: { %@ : %@ }", destinationAttributeName, expressionResult);
    }

    [manager associateSourceInstance:sourceInstance withDestinationInstance:destinationInstance forEntityMapping:mapping];
    return YES;
}

-(BOOL)endEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    NSLog(@"END entity mapping: %@", mapping.sourceEntityName);
    return [super endEntityMapping:mapping manager:manager error:error];
}

@end
