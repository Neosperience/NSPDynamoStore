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

#import "AWSItem.h"
#import "Item.h"

#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSCognito/AWSCognito.h>
#import <Mantle/Mantle.h>

NSString* const kAWSAccountID = @"754753050238";
NSString* const kCognitoPoolID = @"us-east-1:60afae78-f8b8-43d8-bcb3-001d8a1b9f6a";
NSString* const kCognitoRoleUnauth = @"arn:aws:iam::754753050238:role/Cognito_HelloCognitoPoolUnauth_DefaultRole";

AWSDynamoDBComparisonOperator NSPAWSOperatorFromNSOperator(NSPredicateOperatorType predicateOperatorType)
{
    switch (predicateOperatorType) {
        case NSLessThanPredicateOperatorType:               return AWSDynamoDBComparisonOperatorLT;
        case NSLessThanOrEqualToPredicateOperatorType:      return AWSDynamoDBComparisonOperatorLE;
        case NSGreaterThanPredicateOperatorType:            return AWSDynamoDBComparisonOperatorGT;
        case NSGreaterThanOrEqualToPredicateOperatorType:   return AWSDynamoDBComparisonOperatorGE;
        case NSEqualToPredicateOperatorType:                return AWSDynamoDBComparisonOperatorEQ;
        case NSNotEqualToPredicateOperatorType:             return AWSDynamoDBComparisonOperatorNE;

        case NSBeginsWithPredicateOperatorType:             return AWSDynamoDBComparisonOperatorBeginsWith;
        case NSInPredicateOperatorType:                     return AWSDynamoDBComparisonOperatorIN;
        case NSContainsPredicateOperatorType:               return AWSDynamoDBComparisonOperatorContains;
        case NSBetweenPredicateOperatorType:                return AWSDynamoDBComparisonOperatorBetween;

        case NSCustomSelectorPredicateOperatorType:
        case NSEndsWithPredicateOperatorType:
        case NSLikePredicateOperatorType:
        case NSMatchesPredicateOperatorType:
        default:
            NSCAssert(NO, @"NSPDynamoStore: predicate operator type %@ not supported", @(predicateOperatorType));
            return AWSDynamoDBComparisonOperatorUnknown;
    }
}


@interface NSPDynamoStore ()

@property (nonatomic, strong) AWSDynamoDBObjectMapper* dynamoDBObjectMapper;
@property (nonatomic, strong) AWSServiceConfiguration* serviceConfiguration;
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

- (instancetype)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)root
                                 configurationName:(NSString *)name
                                               URL:(NSURL *)url
                                           options:(NSDictionary *)options
{
    self = [super initWithPersistentStoreCoordinator:root configurationName:name URL:url options:options];
    if (self) {
        [self setupObjectMapper];
        self.cache = [NSCache new];
    }
    return self;
}

-(void)setupObjectMapper
{
    AWSCognitoCredentialsProvider *credentialsProvider = [AWSCognitoCredentialsProvider credentialsWithRegionType:AWSRegionUSEast1
                                                                                                        accountId:kAWSAccountID
                                                                                                   identityPoolId:kCognitoPoolID
                                                                                                    unauthRoleArn:kCognitoRoleUnauth
                                                                                                      authRoleArn:nil];

    self.serviceConfiguration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                             credentialsProvider:credentialsProvider];

    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = self.serviceConfiguration;

    self.dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    self.dynamoDB = [[AWSDynamoDB alloc] initWithConfiguration:self.serviceConfiguration];

}

-(BOOL)loadMetadata:(NSError *__autoreleasing *)error
{
    [self setMetadata:@{ NSStoreTypeKey : [[self class] storeType],
                         NSStoreUUIDKey : [[NSProcessInfo processInfo] globallyUniqueString] }];
    return YES;
}

-(id)executeRequest:(NSPersistentStoreRequest *)request
        withContext:(NSManagedObjectContext *)context
              error:(NSError *__autoreleasing *)error
{
    if (request.requestType == NSFetchRequestType) {
        return [self executeFetchRequest:(NSFetchRequest*)request withContext:context error:error];
    }

    return nil;
}

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

        nativeAttributes = [objectID.entity nsp_dynamoDBAttributesToNativeAttributes:dynamoAttributes];
        [self.cache setObject:nativeAttributes forKey:objectID];
    }

    return [[NSIncrementalStoreNode alloc] initWithObjectID:objectID withValues:nativeAttributes version:1];
}

#pragma mark - Private

-(NSArray*)executeFetchRequest:(NSFetchRequest*)fetchRequest
                   withContext:(NSManagedObjectContext *)context
                         error:(NSError *__autoreleasing *)error
{
    if (fetchRequest.resultType == NSManagedObjectResultType) {
        return [self fetchRemoteObjectsWithRequest:fetchRequest context:context];
    } else if (fetchRequest.resultType == NSManagedObjectIDResultType) {
        return [self fetchRemoteObjectsWithRequest:fetchRequest context:context];
    }
    return nil;
}

-(NSDictionary*)scanFilterForPredicate:(NSPredicate*)predicate
{
    NSMutableDictionary* scanFilter = [NSMutableDictionary dictionary];

    NSComparisonPredicate* comparisionPredicate = [NSComparisonPredicate typeCastOrNil:predicate];
    if (comparisionPredicate) {

        if (!(comparisionPredicate.leftExpression.expressionType == NSKeyPathExpressionType &&
              comparisionPredicate.rightExpression.expressionType == NSConstantValueExpressionType)) {
            NSAssert(NO, @"NSPDynamoStore: only keyPath - constant type predicates are supported");
            return nil;
        }

        if ((comparisionPredicate.options & NSCaseInsensitivePredicateOption) ||
            (comparisionPredicate.options & NSDiacriticInsensitivePredicateOption)) {
            NSAssert(NO, @"NSPDynamoStore: case insesitive search is not supported");
            return nil;
        }

        AWSDynamoDBComparisonOperator dynamoOperator = NSPAWSOperatorFromNSOperator(comparisionPredicate.predicateOperatorType);
        NSMutableArray* dynamoRightAttributes = [NSMutableArray array];
        id rightAttribute = comparisionPredicate.rightExpression.constantValue;
        if (!rightAttribute) {
            if (comparisionPredicate.predicateOperatorType == NSEqualToPredicateOperatorType) {
                dynamoOperator = AWSDynamoDBComparisonOperatorNull;
            } else {
                NSAssert(NO, @"NULL attribute value is supported only with \"equal to\" operator type");
            }
        } else if ([rightAttribute respondsToSelector:@selector(countByEnumeratingWithState:objects:count:)]) {
            for (id element in rightAttribute) {
                AWSDynamoDBAttributeValue* dynamoElement = [AWSDynamoDBAttributeValue new];
                [dynamoElement nsp_setAttributeValue:element];
                [dynamoRightAttributes addObject:dynamoElement];
            }
        } else {
            AWSDynamoDBAttributeValue* dynamoRightAttribute = [AWSDynamoDBAttributeValue new];
            [dynamoRightAttribute nsp_setAttributeValue:rightAttribute];
            [dynamoRightAttributes addObject:dynamoRightAttribute];
        }

        NSString* key = comparisionPredicate.leftExpression.keyPath; // TODO: convert to dynamo attribute names or reject keyPaths with period
        AWSDynamoDBCondition* condition = [AWSDynamoDBCondition new];
        condition.comparisonOperator = dynamoOperator;
        condition.attributeValueList = [dynamoRightAttributes count] > 0 ? dynamoRightAttributes : nil;
        scanFilter[key] = condition;
    }

    return [scanFilter count] > 0 ? scanFilter : nil;
}

-(NSArray*)fetchRemoteObjectsWithRequest:(NSFetchRequest*)fetchRequest
                                 context:(NSManagedObjectContext*)context
{
    NSMutableArray* results = [NSMutableArray array];
    NSEntityDescription* entity = fetchRequest.entity;
    NSString* hashKeyName = [entity nsp_dynamoHashKeyName];
    NSString* tableName = [entity nsp_dynamoTableName];
    NSUInteger limit = fetchRequest.fetchLimit;

    AWSDynamoDBScanInput *scanInput = [AWSDynamoDBScanInput new];

    scanInput.tableName = tableName;

    if (limit > 0) scanInput.limit = @(limit);

    if (!fetchRequest.includesPropertyValues) {
        scanInput.projectionExpression = hashKeyName;
    } else if (fetchRequest.propertiesToFetch) {
        NSArray* dynamoPropertiesToFetch = [fetchRequest.propertiesToFetch map:^id(NSPropertyDescription* property) { return [property nsp_dynamoName]; }];
        scanInput.projectionExpression = [dynamoPropertiesToFetch componentsJoinedByString:@","];
    }

//    scanInput.exclusiveStartKey = expression.exclusiveStartKey;
    if (fetchRequest.predicate) {
        scanInput.scanFilter = [self scanFilterForPredicate:fetchRequest.predicate];
    }

     [[[self.dynamoDB scan:scanInput] continueWithBlock:^id(BFTask *task) {
         AWSDynamoDBScanOutput *scanOutput = task.result;

         for (NSDictionary* dynamoAttributes in scanOutput.items) {
             NSManagedObjectID* objectId = [self objectIdForNewObjectOfEntity:fetchRequest.entity
                                                             dynamoAttributes:dynamoAttributes
                                                                   putToCache:fetchRequest.includesPropertyValues];
             if (fetchRequest.resultType == NSManagedObjectResultType) {
                 NSManagedObject* object = [context objectWithID:objectId];
                 [results addObject:object];
             } else if (fetchRequest.resultType == NSManagedObjectIDResultType) {
                 [results addObject:objectId];
             }
         }
         return nil;
    }] waitUntilFinished];

    return results;
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
            NSDictionary* nativeAttributes = [entity nsp_dynamoDBAttributesToNativeAttributes:dynamoAttributes];
            [self.cache setObject:nativeAttributes forKey:objectId];
        }

        return objectId;
    }
    return nil;
}

@end
