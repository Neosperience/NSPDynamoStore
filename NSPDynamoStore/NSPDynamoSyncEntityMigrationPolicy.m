//
//  NSPDynamoSyncEntityMigrationPolicy.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 13/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPDynamoSyncEntityMigrationPolicy.h"
#import "NSEntityDescription+NSPDynamoStore.h"

@interface NSPDynamoSyncEntityMigrationPolicy ()

@property (nonatomic, strong) NSMutableDictionary* existingInstancesIndices;

@end

@implementation NSPDynamoSyncEntityMigrationPolicy

-(NSMutableDictionary *)existingInstancesIndices
{
    if (!_existingInstancesIndices) {
        _existingInstancesIndices = [NSMutableDictionary dictionary];
    }
    return _existingInstancesIndices;
}

#pragma mark - NSEntityMigrationPolicy

-(BOOL)beginEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    NSLog(@"BEGIN entity mapping: %@", mapping.sourceEntityName);
    NSMutableDictionary* existingInstancesIndex = [NSMutableDictionary dictionary];

    // Pre-fetch existing instances for destination entity. They will be used for uniquing in createDestinationInstancesForSourceInstance.
    NSFetchRequest* existingInstancesRequest = [NSFetchRequest fetchRequestWithEntityName:mapping.destinationEntityName];
    NSError* fetchError = nil;
    NSEntityDescription* destinationEntity = [manager.destinationModel entitiesByName][mapping.destinationEntityName];
    NSString* hashKeyName = [destinationEntity nsp_dynamoHashKeyName];
    NSArray* existingInstances = [manager.destinationContext executeFetchRequest:existingInstancesRequest error:&fetchError];

    if (fetchError) {
        NSLog(@"NSPDynamoSyncEntityMigrationPolicy: failed existing instances fetch request: %@ ", fetchError);
        if (error) *error = fetchError;
        return NO;
    }

    // Create hash key -> instance index for easy access
    for (id existingInstance in existingInstances) {
        id hashKey = [existingInstance valueForKey:hashKeyName];
        existingInstancesIndex[hashKey] = existingInstance;
    }

    self.existingInstancesIndices[mapping.destinationEntityName] = existingInstancesIndex;

    return [super beginEntityMapping:mapping manager:manager error:error];
}

-(BOOL)createDestinationInstancesForSourceInstance:(NSManagedObject *)sourceInstance
                                     entityMapping:(NSEntityMapping *)mapping
                                           manager:(NSMigrationManager *)manager
                                             error:(NSError *__autoreleasing *)error
{
    id (^evaluatePropertyMapping)(NSPropertyMapping*, id) = ^id (NSPropertyMapping* propertyMapping, id destinationInstance)
    {
        NSMutableDictionary *evaluationContext =
        [@{ NSMigrationManagerKey : manager,
            NSMigrationSourceObjectKey : sourceInstance,
            NSMigrationEntityMappingKey : mapping,
            NSMigrationEntityPolicyKey : self,
            NSMigrationPropertyMappingKey : propertyMapping } mutableCopy];
        [evaluationContext setValue:destinationInstance forKey:NSMigrationDestinationObjectKey];
        return  [propertyMapping.valueExpression expressionValueWithObject:nil context:evaluationContext];
    };

    NSEntityDescription* destinationEntity = [manager.destinationModel entitiesByName][mapping.destinationEntityName];
    NSString* destinationHashKeyName = [destinationEntity nsp_dynamoHashKeyName];

    NSArray* hashKeyPropertyMappingArray = [mapping.attributeMappings filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", destinationHashKeyName]];

    NSPropertyMapping* hashKeyPropertyMapping= [hashKeyPropertyMappingArray lastObject];

    id hashKeyValue = evaluatePropertyMapping(hashKeyPropertyMapping, nil);

    NSLog(@"CREATE destination destination entity: %@, key: { %@ : %@ }", destinationEntity.name, destinationHashKeyName, hashKeyValue);

    // check if an instance with this key already exists in destination context (check memory cache fetched in beginEntityMapping)
    NSMutableDictionary* destinationInstancesIndex = self.existingInstancesIndices[mapping.destinationEntityName];
    NSManagedObject* destinationInstance = destinationInstancesIndex[hashKeyValue];

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
        NSString* destinationAttributeName = attributeMapping.name;
        id expressionResult = evaluatePropertyMapping(attributeMapping, destinationInstance);
        [destinationInstance setValue:expressionResult forKey:destinationAttributeName];
        NSLog(@"    set value for key: { %@ : %@ }", destinationAttributeName, expressionResult);
    }

    [manager associateSourceInstance:sourceInstance withDestinationInstance:destinationInstance forEntityMapping:mapping];
    return YES;
}

-(BOOL)endEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    NSLog(@"END entity mapping: %@", mapping.sourceEntityName);

    [self.existingInstancesIndices removeObjectForKey:mapping.destinationEntityName];

    return [super endEntityMapping:mapping manager:manager error:error];
}

@end
