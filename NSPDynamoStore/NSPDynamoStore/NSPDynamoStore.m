//
//  NSPDynamoStore.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPDynamoStore.h"

#import "NSObject+NSPTypeCheck.h"
#import "NSArray+NSPCollectionUtils.h"
#import "AWSDynamoDBAttributeValue+NSPDynamoStore.h"
#import "NSEntityDescription+NSPDynamoStore.h"
#import "NSPropertyDescription+NSPDynamoStore.h"
#import "NSPDynamoStoreExpression.h"
#import "NSPDynamoStoreErrors.h"

#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSCognito/AWSCognito.h>

NSString* const NSPDynamoStoreDynamoDBKey = @"NSPDynamoStoreDynamoDBKey";

@interface NSPDynamoStore ()

@property (nonatomic, strong) AWSDynamoDB* dynamoDB;
@property (nonatomic, strong) NSCache* cache;

@property (nonatomic, strong) NSMutableDictionary* embeddedObjects;

@end

@implementation NSPDynamoStore

+ (void)initialize
{
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:[self storeType]];
}

+ (NSString *)storeType
{
    return NSStringFromClass(self);
}

-(NSCache *)cache
{
    if (!_cache) {
        _cache = [NSCache new];
    }
    return _cache;
}

-(NSMutableDictionary *)embeddedObjects
{
    if (!_embeddedObjects) {
        _embeddedObjects = [NSMutableDictionary new];
    }
    return _embeddedObjects;
}

#pragma mark - NSIncrementalStore

/// @override NSIncrementalStore
- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)root
                                 configurationName:(NSString *)name
                                               URL:(NSURL *)url
                                           options:(NSDictionary *)options
{
    self = [super initWithPersistentStoreCoordinator:root configurationName:name URL:url options:options];
    if (self) {
        NSString* dynamoDBKey = options[NSPDynamoStoreDynamoDBKey];

        if (dynamoDBKey) {
            self.dynamoDB = [AWSDynamoDB DynamoDBForKey:dynamoDBKey];
        }

        NSAssert(self.dynamoDB, @"NSPDynamoStore: Can not find DynamoDB for the key '%@'. You must register a DynamoDB instance with "
                 "[AWSDynamoDB registerDynamoDBWithConfiguration:yourConfiguration forKey:@\"yourKey\"] and pass your key in the persistent store "
                 "options dictionary with NSPDynamoStoreDynamoDBKey key.", dynamoDBKey);
    }
    return self;
}

// @override NSIncrementalStore
-(BOOL)loadMetadata:(NSError *__autoreleasing *)error
{
    [self setMetadata:@{ NSStoreTypeKey : [[self class] storeType],
                         NSStoreUUIDKey : [[NSProcessInfo processInfo] globallyUniqueString] }];
    return YES;
}

// @override NSIncrementalStore
-(id)executeRequest:(NSPersistentStoreRequest *)request
        withContext:(NSManagedObjectContext *)context
              error:(NSError *__autoreleasing *)error
{
    if (request.requestType == NSFetchRequestType) {
        return [self executeFetchRequest:(NSFetchRequest*)request withContext:context error:error];
    } else {
        NSAssert(NO, @"NSPDynamoStore: currently only fetch requests are supported.");
    }

    return nil;
}

-(NSDictionary*)fetchNativeAttributesOfObjectWithId:(NSManagedObjectID*)objectID
                                              error:(NSError *__autoreleasing *)error
{
    AWSDynamoDBGetItemInput *getItemInput = [AWSDynamoDBGetItemInput new];
    getItemInput.tableName = [objectID.entity nsp_dynamoTableName];
    id referenceObject = [self referenceObjectForObjectID:objectID];

    NSMutableDictionary *key = [NSMutableDictionary new];
    AWSDynamoDBAttributeValue *hashAttributeValue = [AWSDynamoDBAttributeValue new];
    [hashAttributeValue nsp_setAttributeValue:referenceObject];
    [key setObject:hashAttributeValue
            forKey:[objectID.entity nsp_dynamoHashKeyName]];
    getItemInput.key = key;

    __block NSDictionary* dynamoAttributes = nil;
    __block NSError* fetchError = nil;
    [[[self.dynamoDB getItem:getItemInput] continueWithBlock:^id(BFTask *task) {

        if (task.error) {
            fetchError = task.error;
            return [BFTask taskWithError:task.error];
        }

        AWSDynamoDBGetItemOutput *getItemOutput = task.result;
        dynamoAttributes = getItemOutput.item;

        return dynamoAttributes;

    }] waitUntilFinished];

    if (fetchError) {
        if (error) *error = [NSPDynamoStoreErrors fetchErrorWithUnderlyingError:fetchError];
        return nil;
    }

    NSDictionary* nativeAttributes = [self nativeAttributesFromDynamoAttributes:dynamoAttributes ofEntity:objectID.entity];
    [self.cache setObject:nativeAttributes forKey:objectID];

    return nativeAttributes;
}

// @override NSIncrementalStore
-(NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID
                                        withContext:(NSManagedObjectContext *)context
                                              error:(NSError *__autoreleasing *)error
{
    NSDictionary* nativeAttributes = [self.cache objectForKey:objectID];

    if (!nativeAttributes) {
        nativeAttributes = [self.embeddedObjects objectForKey:objectID];
    }

    if (!nativeAttributes) {
        nativeAttributes = [self fetchNativeAttributesOfObjectWithId:objectID error:error];
    }

    if (nativeAttributes) {
        // TODO: use for example lastModified timestamp as version field to help Core Data to resolve conflicts
        return [[NSIncrementalStoreNode alloc] initWithObjectID:objectID withValues:nativeAttributes version:1];
    } else {
        return nil;
    }
}

// @override NSIncrementalStore
-(id)newValueForRelationship:(NSRelationshipDescription *)relationship
             forObjectWithID:(NSManagedObjectID *)objectID
                 withContext:(NSManagedObjectContext *)context
                       error:(NSError *__autoreleasing *)error
{
    NSDictionary* nativeAttributes = [self.cache objectForKey:objectID];
    if (!nativeAttributes) {
        nativeAttributes = [self fetchNativeAttributesOfObjectWithId:objectID error:error];
    }

    return nativeAttributes[relationship.name];
}

#pragma mark - Private

-(NSArray*)executeFetchRequest:(NSFetchRequest*)fetchRequest
                   withContext:(NSManagedObjectContext *)context
                         error:(NSError *__autoreleasing *)error
{
    NSLog(@"NSPDynamoStore executing fetch request: %@", fetchRequest);

    NSMutableArray* results = [NSMutableArray array];
    NSEntityDescription* entity = fetchRequest.entity;
    NSString* hashKeyName = [entity nsp_dynamoHashKeyName];
    NSString* tableName = [entity nsp_dynamoTableName];
    NSUInteger limit = fetchRequest.fetchLimit;

    // TODO: examine the possibility to support sort descriptors if they refer to Global Secondary Indices
    NSAssert([fetchRequest.sortDescriptors count] == 0, @"NSPDynamoStore: sort descriptors are not supported.");

    AWSDynamoDBScanInput *scanInput = [AWSDynamoDBScanInput new];

    scanInput.tableName = tableName;

    if (!fetchRequest.includesPropertyValues) {
        scanInput.projectionExpression = hashKeyName;
    } else if (fetchRequest.propertiesToFetch) {
        NSArray* dynamoPropertiesToFetch = [fetchRequest.propertiesToFetch map:^id(NSPropertyDescription* property) { return [property nsp_dynamoName]; }];
        scanInput.projectionExpression = [dynamoPropertiesToFetch componentsJoinedByString:@","];
    }

    // TODO: support limit and skip if possible with exclusiveStartKey
    // scanInput.exclusiveStartKey = expression.exclusiveStartKey;

    if (limit > 0) scanInput.limit = @(limit);

    if (fetchRequest.predicate) {
        if ([NSStringFromClass([fetchRequest.predicate class]) isEqualToString:@"NSTruePredicate"]) {
            scanInput.scanFilter = nil;
            scanInput.conditionalOperator = AWSDynamoDBConditionalOperatorUnknown;
        } else if ([NSStringFromClass([fetchRequest.predicate class]) isEqualToString:@"NSFalsePredicate"]) {
            return nil;
        } else {
            NSPDynamoStoreExpression* expression = [NSPDynamoStoreExpression elementWithPredicate:fetchRequest.predicate];
            if ([expression operatorSupported:NSPDynamoStoreExpressionOperatorOR]) {
                scanInput.scanFilter = [expression dynamoConditions];
                scanInput.conditionalOperator = AWSDynamoDBConditionalOperatorOr;
            } else if ([expression operatorSupported:NSPDynamoStoreExpressionOperatorAND]) {
                scanInput.scanFilter = [expression dynamoConditions];
                scanInput.conditionalOperator = AWSDynamoDBConditionalOperatorAnd;
            } else {
                NSAssert(NO, @"NSPDynamoStore: expressions containing both AND and OR are not supported: %@", fetchRequest.predicate);
            }
        }
    }

    // TODO: decide in a best-effort way if we can use query operation

    __block NSError* fetchError = nil;
    [[[self.dynamoDB scan:scanInput] continueWithBlock:^id(BFTask *task) {

        if (task.error) {
            fetchError = task.error;
            return [BFTask taskWithError:task.error];
        }

        AWSDynamoDBScanOutput *scanOutput = task.result;

        for (NSDictionary* dynamoAttributes in scanOutput.items) {
            NSManagedObjectID* objectId = [self objectIdForNewObjectOfEntity:fetchRequest.entity
                                                             dynamoAttributes:dynamoAttributes
                                                                   putToCache:fetchRequest.includesPropertyValues];
            if (fetchRequest.resultType == NSManagedObjectResultType) {
                [results addObject:[context objectWithID:objectId]];
            } else if (fetchRequest.resultType == NSManagedObjectIDResultType) {
                [results addObject:objectId];
            } else if (fetchRequest.resultType == NSDictionaryResultType) {
                NSDictionary* result = [self nativeAttributesFromDynamoAttributes:dynamoAttributes ofEntity:fetchRequest.entity];
                [results addObject:result];
            }
         }
         return results;

    }] waitUntilFinished];

    [self.embeddedObjects enumerateKeysAndObjectsUsingBlock:^(NSManagedObjectID* managedObjectId, id embeddedObject, BOOL *stop)
    {
        // TODO: add objects only if they conform fetchRequest.predicate
        if ([managedObjectId.entity.name isEqualToString:fetchRequest.entityName]) {
            if (fetchRequest.resultType == NSManagedObjectResultType) {
                [results addObject:[context objectWithID:managedObjectId]];
            } else if (fetchRequest.resultType == NSManagedObjectIDResultType) {
                [results addObject:managedObjectId];
            } else if (fetchRequest.resultType == NSDictionaryResultType) {
                NSDictionary* result = [self nativeAttributesFromDynamoAttributes:embeddedObject ofEntity:fetchRequest.entity];
                [results addObject:result];
            }
        }
    }];

    if (fetchError) {
        if (error) *error = [NSPDynamoStoreErrors fetchErrorWithUnderlyingError:fetchError];
        return nil;
    } else {
        return results;
    }
}

-(NSDictionary*)nativeAttributesFromDynamoAttributes:(NSDictionary*)dynamoAttributes ofEntity:(NSEntityDescription*)entity
{
    NSMutableDictionary* transformedValues = [NSMutableDictionary dictionaryWithCapacity:[dynamoAttributes count]];

    [entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString* attributeName, NSAttributeDescription* attribute, BOOL *stop) {
        NSString* dynamoAttributeName = [attribute nsp_dynamoName];
        AWSDynamoDBAttributeValue* dynamoAttributeValue = dynamoAttributes[dynamoAttributeName];
        id nativeAttributeValue = [dynamoAttributeValue nsp_getAttributeValue];
        id encodedValue = nil;

        if (attribute.attributeType == NSBinaryDataAttributeType) {
            NSValueTransformer* dataTransformer = [NSValueTransformer valueTransformerForName:NSKeyedUnarchiveFromDataTransformerName];
            encodedValue = [dataTransformer reverseTransformedValue:nativeAttributeValue];
        } else {
            encodedValue = nativeAttributeValue;
        }

        if (nativeAttributeValue) {
            [transformedValues setValue:encodedValue forKey:attribute.name];
        }
    }];

    [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString* relationshipName, NSRelationshipDescription* relationship, BOOL *stop) {

        NSString* dynamoAttributeName = [relationship nsp_dynamoName];
        AWSDynamoDBAttributeValue* dynamoAttribute = dynamoAttributes[dynamoAttributeName];
        id relationshipObject = [dynamoAttribute nsp_getAttributeValue];

        if (relationshipObject) {
            if (![relationship isToMany]) {
                if ([relationshipObject isKindOfClass:[NSString class]] || [relationshipObject isKindOfClass:[NSNumber class]]) {
                    NSManagedObjectID* objectId = [self newObjectIDForEntity:relationship.destinationEntity referenceObject:relationshipObject];
                    [transformedValues setValue:objectId forKey:relationship.name];
                } else {
                    NSAssert(NO, @"NSDynamoStore: the value of a to-one relationship field must be a collection containing only strings or numbers "
                             "representing the destination object hash key.\n"
                             "Entity: %@, relationship: %@, value: %@", entity, relationshipName, relationshipObject);
                }
            } else {
                if ([relationshipObject respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
                    NSMutableArray* objectIds = [NSMutableArray array];
                    for (id referenceObject in relationshipObject) {
                        NSAssert([referenceObject isKindOfClass:[NSString class]] || [referenceObject isKindOfClass:[NSNumber class]],
                                 @"NSDynamoStore: the value of a to-many relationship field must be a collection containing only strings or numbers "
                                 "represnting the destination object hash key.\n"
                                 "Entity: %@, relationship: %@, value: %@", entity, relationshipName, relationshipObject);
                        NSManagedObjectID* objectId = [self newObjectIDForEntity:relationship.destinationEntity referenceObject:referenceObject];
                        [objectIds addObject:objectId];
                    }
                    [transformedValues setValue:objectIds forKey:relationship.name];
                } else {
                    NSAssert(NO, @"NSDynamoStore: the value of a to-many relationship type property must be a collection.\n"
                                  "Entity: %@, relationship: %@, value: %@", entity, relationshipName, relationshipObject);
                }

            }
        }

    }];

    return transformedValues;
}

-(NSManagedObjectID*)objectIdForNewObjectOfEntity:(NSEntityDescription*)entity
                                 dynamoAttributes:(NSDictionary*)dynamoAttributes
                                       putToCache:(BOOL)putToCache
{
    NSString* hashKeyName = [entity nsp_dynamoHashKeyName];
    AWSDynamoDBAttributeValue* hasKeyValue = dynamoAttributes[hashKeyName];
    id referenceId = [hasKeyValue nsp_getAttributeValue];
    if (referenceId) {
        NSManagedObjectID* objectId = [self newObjectIDForEntity:entity referenceObject:referenceId];

        if (putToCache) {
            NSDictionary* nativeAttributes = [self nativeAttributesFromDynamoAttributes:dynamoAttributes ofEntity:entity];
            [self.cache setObject:nativeAttributes forKey:objectId];
        }

        return objectId;
    }
    return nil;
}

@end
