//
//  NSPDynamoSyncEntityMigrationPolicy.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 13/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPDynamoSyncEntityMigrationPolicy.h"
#import "NSEntityDescription+NSPDynamoStore.h"

NSString* const kNSPDynamoSynchHashKeySeparator = @"<nsp_key_separator>";

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

-(id)mapKeyForHashKeyValue:(id)hashKeyValue primaryKeyRangeKeyValue:(id)pkRangeKeyValue
{
    if (pkRangeKeyValue) {
        return [@[[hashKeyValue description], [pkRangeKeyValue description]] componentsJoinedByString:kNSPDynamoSynchHashKeySeparator];
    } else {
        return hashKeyValue;
    }
}

-(id)mapKeyForInstance:(id)existingInstance entity:(NSEntityDescription*)entity
{
    NSString* hashKeyName = [entity nsp_dynamoHashKeyName];
    id hashKeyValue = [existingInstance valueForKey:hashKeyName];
    NSAssert(hashKeyValue, @"NSPDynamoSyncEntityMigrationPolicy: no hash key value in item");

    NSString* pkRangeKeyName = [entity nsp_dynamoPrimaryRangeKeyName];
    id pkRangeKeyValue = nil;

    if (pkRangeKeyName) {
        pkRangeKeyValue = [existingInstance valueForKey:pkRangeKeyName];
        NSAssert(pkRangeKeyValue, @"NSPDynamoSyncEntityMigrationPolicy: no primary key range key value in item");
    }

    return [self mapKeyForHashKeyValue:hashKeyValue primaryKeyRangeKeyValue:pkRangeKeyValue];
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


    NSArray* existingInstances = [manager.destinationContext executeFetchRequest:existingInstancesRequest error:&fetchError];

    if (fetchError) {
        NSLog(@"NSPDynamoSyncEntityMigrationPolicy: failed existing instances fetch request: %@ ", fetchError);
        if (error) *error = fetchError;
        return NO;
    }

    // Create primary key -> instance index for easy access
    for (id existingInstance in existingInstances) {
        id hashKey = [self mapKeyForInstance:existingInstance entity:destinationEntity];
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
        return [propertyMapping.valueExpression expressionValueWithObject:nil context:evaluationContext];
    };

    id (^evaluateDestinationAttributeWithName)(NSString*, id)  = ^id (NSString* destinationAttributeName, id destinationInstance)
    {
        NSPredicate* pkRangeKeyPropertyMappingFilter = [NSPredicate predicateWithFormat:@"name == %@", destinationAttributeName];
        NSArray* pkRangeKeyPropertyMappingArray = [mapping.attributeMappings filteredArrayUsingPredicate:pkRangeKeyPropertyMappingFilter];
        NSPropertyMapping* pkRangeKeyPropertyMapping = [pkRangeKeyPropertyMappingArray lastObject];
        return evaluatePropertyMapping(pkRangeKeyPropertyMapping, destinationInstance);
    };

    NSEntityDescription* destinationEntity = [manager.destinationModel entitiesByName][mapping.destinationEntityName];

    NSString* destinationHashKeyName = [destinationEntity nsp_dynamoHashKeyName];
    id hashKeyValue = evaluateDestinationAttributeWithName(destinationHashKeyName, nil);
    NSAssert(hashKeyValue, @"NSPDynamoSyncEntityMigrationPolicy: no hash key value in source instance");

    id pkRangeKeyValue = nil;

    NSString* destinationPKRangeKeyName = [destinationEntity nsp_dynamoPrimaryRangeKeyName];
    if (destinationPKRangeKeyName) {
        pkRangeKeyValue = evaluateDestinationAttributeWithName(destinationPKRangeKeyName, nil);
        NSAssert(pkRangeKeyValue, @"NSPDynamoSyncEntityMigrationPolicy: no primary key range key value in source instance");
    }

    NSLog(@"CREATE destination entity: %@, key: { %@ : %@, %@ : %@ }",
          destinationEntity.name, destinationHashKeyName, hashKeyValue, destinationPKRangeKeyName, pkRangeKeyValue);

    // check if an instance with this key already exists in destination context (check memory cache fetched in beginEntityMapping)
    NSMutableDictionary* destinationInstancesIndex = self.existingInstancesIndices[mapping.destinationEntityName];
    id mapKey = [self mapKeyForHashKeyValue:hashKeyValue primaryKeyRangeKeyValue:pkRangeKeyValue];
    NSManagedObject* destinationInstance = destinationInstancesIndex[mapKey];

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
