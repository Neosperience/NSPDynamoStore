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

#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSCognito/AWSCognito.h>

NSString* const NSPDynamoStoreDynamoDBKey = @"NSPDynamoStoreDynamoDBKey";

@interface NSPDynamoStore ()

@property (nonatomic, strong) AWSDynamoDB* dynamoDB;
@property (nonatomic, strong) NSCache* cache;

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

        self.cache = [NSCache new];
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
    }

    return nil;
}

// @override NSIncrementalStore
-(NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID
                                        withContext:(NSManagedObjectContext *)context
                                              error:(NSError *__autoreleasing *)error
{
    NSDictionary* nativeAttributes = [self.cache objectForKey:objectID];
    if (!nativeAttributes) {
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
        [[[self.dynamoDB getItem:getItemInput] continueWithBlock:^id(BFTask *task) {
            AWSDynamoDBGetItemOutput *getItemOutput = task.result;
            dynamoAttributes = getItemOutput.item;
            return nil;
        }] waitUntilFinished];

        nativeAttributes = [self nativeAttributesFromDynamoAttributes:dynamoAttributes ofEntity:objectID.entity];
        [self.cache setObject:nativeAttributes forKey:objectID];
    }

    // TODO: use for example lastModified timestamp as version field to help Core Data to resolve conflicts
    return [[NSIncrementalStoreNode alloc] initWithObjectID:objectID withValues:nativeAttributes version:1];
}

// @override NSIncrementalStore
-(id)newValueForRelationship:(NSRelationshipDescription *)relationship
             forObjectWithID:(NSManagedObjectID *)objectID
                 withContext:(NSManagedObjectContext *)context
                       error:(NSError *__autoreleasing *)error
{
    // TODO: handle to-many relationships here
    return nil;
}

#pragma mark - Private

-(NSArray*)executeFetchRequest:(NSFetchRequest*)fetchRequest
                   withContext:(NSManagedObjectContext *)context
                         error:(NSError *__autoreleasing *)error
{
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

    // TODO: decide in a best-effort way if we can use query operation
    [[[self.dynamoDB scan:scanInput] continueWithBlock:^id(BFTask *task) {
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
         return nil;
    }] waitUntilFinished];

    return results;
}

-(NSDictionary*)nativeAttributesFromDynamoAttributes:(NSDictionary*)dynamoAttributes ofEntity:(NSEntityDescription*)entity
{
    NSMutableDictionary* transformedValues = [NSMutableDictionary dictionaryWithCapacity:[dynamoAttributes count]];

    [entity.attributesByName enumerateKeysAndObjectsUsingBlock:^(NSString* attributeName, NSAttributeDescription* attribute, BOOL *stop) {
        NSString* dynamoAttributeName = [attribute nsp_dynamoName];
        AWSDynamoDBAttributeValue* dynamoAttribute = dynamoAttributes[dynamoAttributeName];
        if (dynamoAttribute) {
            [transformedValues setValue:[dynamoAttribute nsp_getAttributeValue] forKey:attribute.name];
        }
    }];

    [entity.relationshipsByName enumerateKeysAndObjectsUsingBlock:^(NSString* relationshipName, NSRelationshipDescription* relationship, BOOL *stop) {

        // Only to-one relationships are handled here. To-many relationships are handled in newValueForRelationship
        if (relationship.toMany) return;

        NSString* dynamoAttributeName = [relationship nsp_dynamoName];
        AWSDynamoDBAttributeValue* dynamoAttribute = dynamoAttributes[dynamoAttributeName];
        id referenceObject = [dynamoAttribute nsp_getAttributeValue];

        if (referenceObject) {
            NSAssert([referenceObject isKindOfClass:[NSString class]] || [referenceObject isKindOfClass:[NSNumber class]],
                     @"NSDynamoStore: the value of a relationship type property must be a number or a string and it must be the hash key of the "
                     "destination object. Entity: %@, relationship: %@, value: %@", entity, relationshipName, referenceObject);
            NSManagedObjectID* objectId = [self newObjectIDForEntity:relationship.destinationEntity referenceObject:referenceObject];
            [transformedValues setValue:objectId forKey:relationship.name];
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
