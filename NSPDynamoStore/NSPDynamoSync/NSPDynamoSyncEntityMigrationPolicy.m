//
//  NSPDynamoSyncEntityMigrationPolicy.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 13/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPDynamoSyncEntityMigrationPolicy.h"
#import "NSEntityDescription+NSPDynamoStore.h"
#import "NSPDynamoStoreKeyPair.h"

#import <NSPCoreUtils/NSPLogger.h>

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
    NSPDynamoStoreKeyPair* keyPair = [entity nsp_primaryKeys];

    id hashKeyValue = [existingInstance valueForKey:keyPair.hashKeyName];
    NSAssert(hashKeyValue, @"NSPDynamoSyncEntityMigrationPolicy: no hash key value in item");

    id pkRangeKeyValue = nil;

    if (keyPair.rangeKeyName) {
        pkRangeKeyValue = [existingInstance valueForKey:keyPair.rangeKeyName];
        NSAssert(pkRangeKeyValue, @"NSPDynamoSyncEntityMigrationPolicy: no primary key range key value in item");
    }

    return [self mapKeyForHashKeyValue:hashKeyValue primaryKeyRangeKeyValue:pkRangeKeyValue];
}

#pragma mark - NSEntityMigrationPolicy

-(BOOL)beginEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    NSPLogDebug(@"BEGIN entity mapping: %@", mapping.sourceEntityName);
    NSMutableDictionary* existingInstancesIndex = [NSMutableDictionary dictionary];

    // Pre-fetch existing instances for destination entity. They will be used for uniquing in createDestinationInstancesForSourceInstance.
    NSFetchRequest* existingInstancesRequest = [NSFetchRequest fetchRequestWithEntityName:mapping.destinationEntityName];
    NSError* fetchError = nil;
    NSEntityDescription* destinationEntity = [manager.destinationModel entitiesByName][mapping.destinationEntityName];


    NSArray* existingInstances = [manager.destinationContext executeFetchRequest:existingInstancesRequest error:&fetchError];

    if (fetchError) {
        NSPLogError(@"NSPDynamoSyncEntityMigrationPolicy: failed existing instances fetch request: %@ ", fetchError);
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

    NSPDynamoStoreKeyPair* destinationKeyPair = [destinationEntity nsp_primaryKeys];

    id hashKeyValue = evaluateDestinationAttributeWithName(destinationKeyPair.hashKeyName, nil);
    NSAssert(hashKeyValue, @"NSPDynamoSyncEntityMigrationPolicy: no hash key value in source instance");

    id pkRangeKeyValue = nil;

    if (destinationKeyPair.rangeKeyName) {
        pkRangeKeyValue = evaluateDestinationAttributeWithName(destinationKeyPair.rangeKeyName, nil);
        NSAssert(pkRangeKeyValue, @"NSPDynamoSyncEntityMigrationPolicy: no primary key range key value in source instance");
    }

    NSPLogDebug(@"CREATE destination entity: %@, key: { %@ : %@, %@ : %@ }",
                destinationEntity.name, destinationKeyPair.hashKeyName, hashKeyValue, destinationKeyPair.rangeKeyName, pkRangeKeyValue);

    // check if an instance with this key already exists in destination context (check memory cache fetched in beginEntityMapping)
    NSMutableDictionary* destinationInstancesIndex = self.existingInstancesIndices[mapping.destinationEntityName];
    id mapKey = [self mapKeyForHashKeyValue:hashKeyValue primaryKeyRangeKeyValue:pkRangeKeyValue];
    NSManagedObject* destinationInstance = destinationInstancesIndex[mapKey];

    if (!destinationInstance) {
        // no existing object, create a new one
        NSPLogDebug(@"    NO existing instance, creating new");
        destinationInstance = [NSEntityDescription insertNewObjectForEntityForName:mapping.destinationEntityName
                                                            inManagedObjectContext:manager.destinationContext];
    } else {
        NSPLogDebug(@"    existing instance found, updating");
    }

    // update object with new attributes
    for (NSPropertyMapping* attributeMapping in mapping.attributeMappings) {
        NSString* destinationAttributeName = attributeMapping.name;
        id expressionResult = evaluatePropertyMapping(attributeMapping, destinationInstance);
        [destinationInstance setValue:expressionResult forKey:destinationAttributeName];
        NSPLogDebug(@"    set value for key: { %@ : %@ }", destinationAttributeName, expressionResult);
    }

    [manager associateSourceInstance:sourceInstance withDestinationInstance:destinationInstance forEntityMapping:mapping];
    return YES;
}

-(BOOL)endEntityMapping:(NSEntityMapping *)mapping manager:(NSMigrationManager *)manager error:(NSError *__autoreleasing *)error
{
    NSPLogDebug(@"END entity mapping: %@", mapping.sourceEntityName);

    [self.existingInstancesIndices removeObjectForKey:mapping.destinationEntityName];

    return [super endEntityMapping:mapping manager:manager error:error];
}

@end
