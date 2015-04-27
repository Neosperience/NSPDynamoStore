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
#import "NSDictionary+NSPCollectionUtils.h"
#import "AWSDynamoDBAttributeValue+NSPDynamoStore.h"
#import "NSEntityDescription+NSPDynamoStore.h"
#import "NSPropertyDescription+NSPDynamoStore.h"
#import "NSPDynamoStoreExpression.h"
#import "NSPDynamoStoreErrors.h"
#import "NSAttributeDescription+NSPDynamoStore.h"
#import "NSRelationshipDescription+NSPDynamoStore.h"
#import "NSPDynamoStoreKeyPair.h"

#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSCognito/AWSCognito.h>

NSString* const NSPDynamoStoreType = @"NSPDynamoStore";
NSString* const NSPDynamoStoreDynamoDBKey = @"NSPDynamoStoreDynamoDBKey";
NSString* const NSPDynamoStoreKeySeparator = @"<nsp_key_separator>";

@interface NSPDynamoStore ()

@property (nonatomic, strong) AWSDynamoDB* dynamoDB;
@property (nonatomic, strong) NSCache* cache;

@end

@implementation NSPDynamoStore

+ (void)load
{
    [NSPersistentStoreCoordinator registerStoreClass:self forStoreType:NSPDynamoStoreType];
}

-(NSCache *)cache
{
    if (!_cache) {
        _cache = [NSCache new];
    }
    return _cache;
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
    [self setMetadata:@{ NSStoreTypeKey : NSPDynamoStoreType,
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

    NSDictionary* nativeAttributes = [self nativeAttributeValuesFromDynamoAttributeValues:dynamoAttributes ofEntity:objectID.entity];
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

    __block BOOL incompleteRequest = NO;
    NSDictionary* substitutionDictionary = [fetchRequestVariableKeyPathMap map:^id(id key, id value) {
        id attributeKeyPathValue = [nativeAttributes valueForKeyPath:value];
        if (!attributeKeyPathValue) {
            // no relationship value for this object
            incompleteRequest = YES;
        }
        return attributeKeyPathValue;
    }];

    if (incompleteRequest) {
        return nil;
    }

    NSManagedObjectModel* model = relationship.entity.managedObjectModel;
    NSFetchRequest* fetchRequest = [[model fetchRequestFromTemplateWithName:fetchRequestTemplateName
                                                      substitutionVariables:substitutionDictionary] copy];

    fetchRequest.resultType = NSManagedObjectIDResultType;

    NSPDynamoStoreExpression* expression = [NSPDynamoStoreExpression elementWithPredicate:fetchRequest.predicate];
    NSPDynamoStoreKeyPair* primaryKeys = [fetchRequest.entity nsp_primaryKeys];
    NSArray* explodedDynamoConditions = nil;

    NSArray* results = nil;

    // Check if we can use batch get. If yes, then we have all info for recostructing the managed object IDs without a fetch.
    if ([expression canBatchGetForKeyPair:primaryKeys explodedConditions:&explodedDynamoConditions]) {

        NSLog(@"Creating RELATIONSHIP from without network request of entity: %@ for predicate: %@",
              fetchRequest.entityName, fetchRequest.predicate);

        results = [explodedDynamoConditions map:^id(NSDictionary* item) {
            return [self objectIDForNewObjectOfEntity:fetchRequest.entity
                                     dynamoAttributes:item
                                           putToCache:NO];
        }];

    } else {

        NSError* fetchError = nil;
        results = [context executeFetchRequest:fetchRequest error:&fetchError];

        if (fetchError) {
            if (error) *error = [NSPDynamoStoreErrors fetchErrorWithUnderlyingError:fetchError];
            return nil;
        }

    }

    id result = nil;

    if (!relationship.isToMany) {

        // TODO: this should be a runtime error, not an assert
        NSAssert([results count] <= 1, @"NSPDynamoStore: fetch request %@ for to-one relationship %@.%@ returned more then one result "
                 "for objectId: %@", fetchRequestTemplateName, relationship.entity.name, relationship.name, objectID);
        result = [results lastObject];
    } else {
        result = [results count] > 0 ? results : nil;
    }

    return result;
}

#pragma mark - Private

-(void)configureRequest:(AWSRequest*)request withFetchRequest:(NSFetchRequest*)fetchRequest
{
    NSAssert([fetchRequest.sortDescriptors count] == 0, @"NSPDynamoStore: sort descriptors are not supported.");
    NSAssert([request isKindOfClass:[AWSDynamoDBScanInput class]] || [request isKindOfClass:[AWSDynamoDBQueryInput class]],
             @"NSPDynamoStore: only AWSDynamoDBScanInput and AWSDynamoDBQueryInput instances can be configured with this method");

    id input = request;
    NSPDynamoStoreKeyPair* keyPair = [fetchRequest.entity nsp_primaryKeys];
    NSString* tableName = [fetchRequest.entity nsp_dynamoTableName];

    [input setTableName:tableName];

    if (!fetchRequest.includesPropertyValues) {
        [input setProjectionExpression:[keyPair dynamoProjectionExpression]];
    } else if (fetchRequest.propertiesToFetch) {
        NSArray* dynamoPropertiesToFetch = [fetchRequest.propertiesToFetch map:^id(NSPropertyDescription* property) {
            return [property nsp_dynamoName]; }];
        NSString* projectionExpression = [dynamoPropertiesToFetch componentsJoinedByString:@","];
        [input setProjectionExpression:projectionExpression];
    }

    // TODO: support limit and skip if possible with exclusiveStartKey
    // scanInput.exclusiveStartKey = expression.exclusiveStartKey;

    NSUInteger limit = fetchRequest.fetchLimit;
    if (limit > 0) [input setLimit:@(limit)];
}

-(AWSDynamoDBScanInput*)scanInputForFetchRequest:(NSFetchRequest*)fetchRequest
{
    AWSDynamoDBScanInput *scanInput = [AWSDynamoDBScanInput new];
    [self configureRequest:scanInput withFetchRequest:fetchRequest];

//    NSLog(@"Executing SCAN for fetch request for entity name: %@, predicate: %@", fetchRequest.entityName, fetchRequest.predicate);

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

    return scanInput;
}

-(AWSDynamoDBQueryInput*)queryInputForFetchRequest:(NSFetchRequest*)fetchRequest
{
    AWSDynamoDBQueryInput* queryInput = nil;

    if ([fetchRequest.predicate isKindOfClass:[NSCompoundPredicate class]] || [fetchRequest.predicate isKindOfClass:[NSComparisonPredicate class]]) {

        NSPDynamoStoreExpression* expression = [NSPDynamoStoreExpression elementWithPredicate:fetchRequest.predicate];
        __block NSString* queryIndexName = nil;

        [[fetchRequest.entity nsp_dynamoIndices] enumerateKeysAndObjectsUsingBlock:^(NSString* indexName, NSPDynamoStoreKeyPair* index, BOOL *stop) {
            if ([expression canQueryForKeyPair:index]) queryIndexName = indexName;
        }];

        if ([expression canQueryForKeyPair:[fetchRequest.entity nsp_primaryKeys]] || (queryIndexName != nil)) {

            queryInput = [AWSDynamoDBQueryInput new];
            [self configureRequest:queryInput withFetchRequest:fetchRequest];

            queryInput.keyConditions = [expression dynamoConditions];
            queryInput.indexName = queryIndexName;
        }
    }

    return queryInput;
}

-(AWSDynamoDBBatchGetItemInput*)batchGetInputForFetchRequest:(NSFetchRequest*)fetchRequest
{
    AWSDynamoDBBatchGetItemInput* batchGetInput = nil;

    if ([fetchRequest.predicate isKindOfClass:[NSCompoundPredicate class]] || [fetchRequest.predicate isKindOfClass:[NSComparisonPredicate class]]) {

        NSPDynamoStoreExpression* expression = [NSPDynamoStoreExpression elementWithPredicate:fetchRequest.predicate];

        NSPDynamoStoreKeyPair* primaryKeys = [fetchRequest.entity nsp_primaryKeys];
        NSArray* explodedConditions = nil;
        if ([expression canBatchGetForKeyPair:primaryKeys explodedConditions:&explodedConditions]) {
            batchGetInput = [AWSDynamoDBBatchGetItemInput new];
            NSString* tableName = [fetchRequest.entity nsp_dynamoTableName];
            AWSDynamoDBKeysAndAttributes* keysAndAttributes = [AWSDynamoDBKeysAndAttributes new];
            keysAndAttributes.keys = explodedConditions;
            batchGetInput.requestItems = @{ tableName : keysAndAttributes };
        }
    }

    return batchGetInput;
}

-(NSArray*)executeFetchRequest:(NSFetchRequest*)fetchRequest
                   withContext:(NSManagedObjectContext *)context
                         error:(NSError *__autoreleasing *)error
{
    BFTask* task = nil;

    AWSDynamoDBBatchGetItemInput* batchGetInput = [self batchGetInputForFetchRequest:fetchRequest];

    if (batchGetInput) {
        task = [self.dynamoDB batchGetItem:batchGetInput];
        NSLog(@"Executing BATCH GET of entity: %@ for predicate: %@", fetchRequest.entityName, fetchRequest.predicate);
    } else {
        AWSDynamoDBQueryInput* queryInput = [self queryInputForFetchRequest:fetchRequest];
        if (queryInput) {
            task = [self.dynamoDB query:queryInput];
            NSLog(@"Executing QUERY of entity: %@ for predicate: %@", fetchRequest.entityName, fetchRequest.predicate);
        } else {
            AWSDynamoDBScanInput* scanInput = [self scanInputForFetchRequest:fetchRequest];
            task = [self.dynamoDB scan:scanInput];
            NSLog(@"Executing SCAN of entity: %@ for predicate: %@", fetchRequest.entityName, fetchRequest.predicate);
        }
    }

    __block NSError* fetchError = nil;
    NSMutableArray* results = [NSMutableArray array];

    [[task continueWithBlock:^id(BFTask *task) {

        if (task.error) {
            fetchError = task.error;
            return [BFTask taskWithError:task.error];
        }

        NSArray* items = nil;
        if ([task.result isKindOfClass:[AWSDynamoDBScanOutput class]] || [task.result isKindOfClass:[AWSDynamoDBQueryOutput class]]) {
            items = [task.result valueForKey:@"items"];
        } else if ([task.result isKindOfClass:[AWSDynamoDBBatchGetItemOutput class]]) {
            AWSDynamoDBBatchGetItemOutput* batchGetOutput = task.result;
            NSString* tableName = [fetchRequest.entity nsp_dynamoTableName];
            items = [batchGetOutput.responses valueForKey:tableName];
        }

        for (NSDictionary* dynamoAttributes in items) {
            NSManagedObjectID* objectId = [self objectIDForNewObjectOfEntity:fetchRequest.entity
                                                            dynamoAttributes:dynamoAttributes
                                                                  putToCache:fetchRequest.includesPropertyValues];
            if (fetchRequest.resultType == NSManagedObjectResultType) {
                [results addObject:[context objectWithID:objectId]];
            } else if (fetchRequest.resultType == NSManagedObjectIDResultType) {
                [results addObject:objectId];
            } else if (fetchRequest.resultType == NSDictionaryResultType) {
                NSDictionary* result = [self nativeAttributeValuesFromDynamoAttributeValues:dynamoAttributes ofEntity:fetchRequest.entity];
                [results addObject:result];
            }
        }

        return results;

    }] waitUntilFinished];

    return results;
}

-(id)nativeAttributeValueFromDynamoAttributeValue:(AWSDynamoDBAttributeValue*)dynamoAttributeValue ofAttribute:(NSAttributeDescription*)attribute
{
    id nativeAttributeValue = [dynamoAttributeValue nsp_getAttributeValue];
    NSValueTransformer* valueTransformer = [attribute nsp_valueTransformer];
    return valueTransformer ? [valueTransformer transformedValue:nativeAttributeValue] : nativeAttributeValue;
}

-(NSDictionary*)nativeAttributeValuesFromDynamoAttributeValues:(NSDictionary*)dynamoAttributes ofEntity:(NSEntityDescription*)entity
{
    return [entity.attributesByName map:^id(NSString* attributeName, NSAttributeDescription* attribute) {
        NSString* dynamoAttributeName = [attribute nsp_dynamoName];
        AWSDynamoDBAttributeValue* dynamoAttributeValue = dynamoAttributes[dynamoAttributeName];
        return [self nativeAttributeValueFromDynamoAttributeValue:dynamoAttributeValue ofAttribute:attribute];
    }];
}

-(NSManagedObjectID*)objectIDForNewObjectOfEntity:(NSEntityDescription*)entity
                                 dynamoAttributes:(NSDictionary*)dynamoAttributes
                                       putToCache:(BOOL)putToCache
{
    id referenceObject = nil;
    NSPDynamoStoreKeyPair* keyPair = [entity nsp_primaryKeys];
    NSAttributeDescription* hashKeyAttribute = entity.attributesByName[keyPair.hashKeyName];
    NSString* dynamoHashKeyName = [hashKeyAttribute nsp_dynamoName];

    AWSDynamoDBAttributeValue* hashKeyDynamoValue = dynamoAttributes[dynamoHashKeyName];
    id hashKeyNativeValue = [self nativeAttributeValueFromDynamoAttributeValue:hashKeyDynamoValue ofAttribute:hashKeyAttribute];
    NSAssert(hashKeyNativeValue, @"NSDynamoStore: no hash key value in DynamoDB item");

    if (keyPair.rangeKeyName) {
        NSAttributeDescription* pkRangeKeyAttribute = entity.attributesByName[keyPair.rangeKeyName];
        AWSDynamoDBAttributeValue* pkRangeKeyDynamoValue = dynamoAttributes[keyPair.rangeKeyName];
        id pkRangeKeyNativeValue = [self nativeAttributeValueFromDynamoAttributeValue:pkRangeKeyDynamoValue ofAttribute:pkRangeKeyAttribute];
        NSAssert(pkRangeKeyNativeValue, @"NSDynamoStore: no primary range key value in DynamoDB item");
        referenceObject = [@[[hashKeyNativeValue description], [pkRangeKeyNativeValue description]] componentsJoinedByString:NSPDynamoStoreKeySeparator];
    } else {
        referenceObject = hashKeyNativeValue;
    }

    NSManagedObjectID* objectId = [self newObjectIDForEntity:entity referenceObject:referenceObject];

    if (putToCache) {
        NSDictionary* nativeAttributes = [self nativeAttributeValuesFromDynamoAttributeValues:dynamoAttributes ofEntity:entity];
        [self.cache setObject:nativeAttributes forKey:objectId];
    }

    return objectId;
}

-(NSDictionary*)nativePrimaryKeyValuesFromObjectID:(NSManagedObjectID*)objectID
{
    id pk = [self referenceObjectForObjectID:objectID];

    NSPDynamoStoreKeyPair* keyPair = [objectID.entity nsp_primaryKeys];

    NSAttributeDescription* hashKeyAttribute = objectID.entity.attributesByName[keyPair.hashKeyName];
    NSAttributeDescription* pkRangeKeyAttribute = keyPair.rangeKeyName ? objectID.entity.attributesByName[keyPair.rangeKeyName] : nil;

    NSAssert([hashKeyAttribute nsp_isStringType] || [hashKeyAttribute nsp_isNumberType],
             @"NSPDynamoStore: hash key attribute must be string or number type");

    id hashKeyValue = nil;
    id pkRangeKeyValue = nil;

    if (!keyPair.rangeKeyName) {
        hashKeyValue = pk;
    } else {
        NSAssert([pkRangeKeyAttribute nsp_isStringType] || [pkRangeKeyAttribute nsp_isNumberType],
                 @"NSPDynamoStore: primary range key attribute must be string or number type");
        [NSString typeCheck:pk];
        NSArray* pkComponents = [pk componentsSeparatedByString:NSPDynamoStoreKeySeparator];
        NSParameterAssert([pkComponents count] == 2);

        hashKeyValue = [hashKeyAttribute nsp_isStringType] ? pkComponents[0] : @([pkComponents[0] doubleValue]);
        pkRangeKeyValue = [pkRangeKeyAttribute nsp_isStringType] ? pkComponents[1] : @([pkComponents[0] doubleValue]);
    }

    NSMutableDictionary* result = [@{ keyPair.hashKeyName : hashKeyValue } mutableCopy];
    if (keyPair.rangeKeyName) [result setValue:pkRangeKeyValue forKey:keyPair.rangeKeyName];
    return result;
}

-(NSDictionary*)dynamoPrimaryKeyValuesFromObjectID:(NSManagedObjectID*)objectID
{
    return [[self nativePrimaryKeyValuesFromObjectID:objectID] map:^id(id key, id value) {
        AWSDynamoDBAttributeValue *dynamoValue = [AWSDynamoDBAttributeValue new];
        [dynamoValue nsp_setAttributeValue:value];
        return dynamoValue;
    }];
}

@end
