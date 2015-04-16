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
#import "NSAttributeDescription+NSPDynamoStore.h"
#import "NSRelationshipDescription+NSPDynamoStore.h"

#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSCognito/AWSCognito.h>

NSString* const kNSPDynamoStoreDynamoDBKey = @"NSPDynamoStoreDynamoDBKey";
NSString* const kNSPDynamoStoreKeySeparator = @"<nsp_key_separator>";

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
        NSString* dynamoDBKey = options[kNSPDynamoStoreDynamoDBKey];

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

    NSDictionary* keys = [self dynamoPrimaryKeyValuesFromObjectID:objectID];
    getItemInput.key = keys;

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

    NSString* fetchRequestTemplateName = [relationship nsp_fetchRequestTemplateName];
    NSDictionary* fetchRequestVariableKeyPathMap = [relationship nsp_fetchRequestVariableKeyPathMap];

    NSMutableDictionary* substitutionDictionary = [NSMutableDictionary dictionaryWithCapacity:[fetchRequestVariableKeyPathMap count]];
    for (NSString* key in [fetchRequestVariableKeyPathMap allKeys]) {
        NSString* attributeKeyPath = fetchRequestVariableKeyPathMap[key];
        id attributeKeyPathValue = [nativeAttributes valueForKeyPath:attributeKeyPath];

        // TODO: this should be a runtime error, not an assert
        NSAssert(attributeKeyPathValue, @"NSPDynamoStore: Can not evaluate key path in source object for relationship fetch request template. \n"
                                        "\trelationship: %@.%@\n\tfetch request template: %@\n\tkey path: %@\n\tsource object: %@",
                                        relationship.entity.name, relationship.name, fetchRequestTemplateName, attributeKeyPath, nativeAttributes);

        [substitutionDictionary setValue:attributeKeyPathValue forKey:key];
    }

    NSFetchRequest* fetchRequest = [[relationship.entity.managedObjectModel fetchRequestFromTemplateWithName:fetchRequestTemplateName
                                                                                       substitutionVariables:substitutionDictionary] copy];

    fetchRequest.resultType = NSManagedObjectIDResultType;

    NSError* fetchError = nil;
    NSArray* fetchResult = [context executeFetchRequest:fetchRequest error:&fetchError];
    id result = nil;

    if (fetchError) {
        if (error) *error = [NSPDynamoStoreErrors fetchErrorWithUnderlyingError:fetchError];
        return nil;
    }

    if (!relationship.isToMany) {

        // TODO: this should be a runtime error, not an assert
        NSAssert([fetchResult count] <= 1, @"NSPDynamoStore: fetch request %@ for to-one relationship %@.%@ returned more then one result "
                 "for objectId: %@", fetchRequestTemplateName, relationship.entity.name, relationship.name, objectID);
        result = [fetchResult lastObject];
    } else {
        result = [fetchResult count] > 0 ? fetchResult : nil;
    }

    return result;
}

#pragma mark - Private

-(NSArray*)executeFetchRequest:(NSFetchRequest*)fetchRequest
                   withContext:(NSManagedObjectContext *)context
                         error:(NSError *__autoreleasing *)error
{
    NSMutableArray* results = [NSMutableArray array];
    NSEntityDescription* entity = fetchRequest.entity;
    NSString* hashKeyName = [entity nsp_dynamoHashKeyName];
    NSString* pkRangeKeyName = [entity nsp_dynamoPrimaryRangeKeyName];
    NSString* tableName = [entity nsp_dynamoTableName];
    NSUInteger limit = fetchRequest.fetchLimit;

    // TODO: examine the possibility to support sort descriptors if they refer to Global Secondary Indices
    NSAssert([fetchRequest.sortDescriptors count] == 0, @"NSPDynamoStore: sort descriptors are not supported.");

    AWSDynamoDBScanInput *scanInput = [AWSDynamoDBScanInput new];

    scanInput.tableName = tableName;

    if (!fetchRequest.includesPropertyValues) {
        scanInput.projectionExpression = pkRangeKeyName ? [NSString stringWithFormat:@"%@,%@", hashKeyName, pkRangeKeyName] : hashKeyName;
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
        } else if ([NSStringFromClass([fetchRequest.predicate class]) isEqualToString:@"NSFalsePredicate"]) {
            return nil;
        } else {
            NSPDynamoStoreExpression* expression = [NSPDynamoStoreExpression elementWithPredicate:fetchRequest.predicate];
            scanInput.scanFilter = [expression dynamoConditions];

            if ([scanInput.scanFilter count] > 1) {
                if ([expression operatorSupported:NSPDynamoStoreExpressionOperatorOR]) {
                    scanInput.conditionalOperator = AWSDynamoDBConditionalOperatorOr;
                } else if ([expression operatorSupported:NSPDynamoStoreExpressionOperatorAND]) {
                    scanInput.conditionalOperator = AWSDynamoDBConditionalOperatorAnd;
                } else {
                    NSAssert(NO, @"NSPDynamoStore: expressions containing both AND and OR are not supported: %@", fetchRequest.predicate);
                }
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

    return transformedValues;
}

-(NSManagedObjectID*)objectIdForNewObjectOfEntity:(NSEntityDescription*)entity
                                 dynamoAttributes:(NSDictionary*)dynamoAttributes
                                       putToCache:(BOOL)putToCache
{
    id referenceObject = nil;

    NSString* hashKeyName = [entity nsp_dynamoHashKeyName];
    NSAttributeDescription* hashKeyAttribute = entity.attributesByName[hashKeyName];
    NSString* dynamoHashKeyName = [hashKeyAttribute nsp_dynamoName];

    AWSDynamoDBAttributeValue* hashKeyDynamoValue = dynamoAttributes[dynamoHashKeyName];
    id hashKeyNativeValue = [hashKeyDynamoValue nsp_getAttributeValue];
    NSAssert(hashKeyNativeValue, @"NSDynamoStore: no hash key value in DynamoDB item");

    NSString* pkRangeKeyName = [entity nsp_dynamoPrimaryRangeKeyName];
    if (pkRangeKeyName) {
        AWSDynamoDBAttributeValue* pkRangeKeyDynamoValue = dynamoAttributes[pkRangeKeyName];
        id pkRangeKeyNativeValue = [pkRangeKeyDynamoValue nsp_getAttributeValue];
        NSAssert(pkRangeKeyNativeValue, @"NSDynamoStore: no primary range key value in DynamoDB item");
        referenceObject = [@[[hashKeyNativeValue description], [pkRangeKeyNativeValue description]] componentsJoinedByString:kNSPDynamoStoreKeySeparator];
    } else {
        referenceObject = hashKeyNativeValue;
    }

    NSManagedObjectID* objectId = [self newObjectIDForEntity:entity referenceObject:referenceObject];

    if (putToCache) {
        NSDictionary* nativeAttributes = [self nativeAttributesFromDynamoAttributes:dynamoAttributes ofEntity:entity];
        [self.cache setObject:nativeAttributes forKey:objectId];
    }

    return objectId;
}

-(NSDictionary*)nativePrimaryKeyValuesFromObjectID:(NSManagedObjectID*)objectID
{
    id pk = [self referenceObjectForObjectID:objectID];

    NSString* hashKeyName = [objectID.entity nsp_dynamoHashKeyName];
    NSString* pkRangeKeyName = [objectID.entity nsp_dynamoPrimaryRangeKeyName];

    NSAttributeDescription* hashKeyAttribute = objectID.entity.attributesByName[hashKeyName];
    NSAttributeDescription* pkRangeKeyAttribute = pkRangeKeyName ? objectID.entity.attributesByName[pkRangeKeyName] : nil;

    NSAssert([hashKeyAttribute nsp_isStringType] || [hashKeyAttribute nsp_isNumberType],
             @"NSPDynamoStore: hash key attribute must be string or number type");

    id hashKeyValue = nil;
    id pkRangeKeyValue = nil;

    if (!pkRangeKeyName) {
        hashKeyValue = pk;
    } else {
        NSAssert([pkRangeKeyAttribute nsp_isStringType] || [pkRangeKeyAttribute nsp_isNumberType],
                 @"NSPDynamoStore: primary range key attribute must be string or number type");
        NSParameterAssert([pk isKindOfClass:[NSString class]]);
        NSArray* pkComponents = [pk componentsSeparatedByString:kNSPDynamoStoreKeySeparator];
        NSParameterAssert([pkComponents count] == 2);

        hashKeyValue = [hashKeyAttribute nsp_isStringType] ? pkComponents[0] : @([pkComponents[0] doubleValue]);
        pkRangeKeyValue = [pkRangeKeyAttribute nsp_isStringType] ? pkComponents[1] : @([pkComponents[0] doubleValue]);
    }

    NSMutableDictionary* result = [@{ hashKeyName : hashKeyValue } mutableCopy];
    if (pkRangeKeyName) [result setValue:pkRangeKeyValue forKey:pkRangeKeyName];
    return result;
}

-(NSDictionary*)dynamoPrimaryKeyValuesFromObjectID:(NSManagedObjectID*)objectID
{
    NSDictionary* primaryKeys = [self nativePrimaryKeyValuesFromObjectID:objectID];
    NSMutableDictionary* dynamoKeys = [NSMutableDictionary dictionaryWithCapacity:[primaryKeys count]];
    [primaryKeys enumerateKeysAndObjectsUsingBlock:^(NSString* keyName, id keyValue, BOOL *stop) {
        AWSDynamoDBAttributeValue *dynamoValue = [AWSDynamoDBAttributeValue new];
        [dynamoValue nsp_setAttributeValue:keyValue];
        dynamoKeys[keyName] = dynamoValue;
    }];
    return dynamoKeys;
}

@end
