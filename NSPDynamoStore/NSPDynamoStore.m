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

#import "AWSItem.h"
#import "Item.h"

#import <AWSDynamoDB/AWSDynamoDB.h>
#import <AWSCognito/AWSCognito.h>
#import <Mantle/Mantle.h>

NSString* const kAWSAccountID = @"[AWS account ID here]";
NSString* const kCognitoPoolID = @"[AWS cognito pool ID here]";
NSString* const kCognitoRoleUnauth = @"[AWS unauthenticated role ARN here";

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
    if (fetchRequest.returnsObjectsAsFaults) {
        scanInput.projectionExpression = hashKeyName;
    }
//    scanInput.exclusiveStartKey = expression.exclusiveStartKey;
//    scanInput.scanFilter = expression.scanFilter;

     [[[self.dynamoDB scan:scanInput] continueWithBlock:^id(BFTask *task) {
         AWSDynamoDBScanOutput *scanOutput = task.result;

         for (NSDictionary* dynamoAttributes in scanOutput.items) {
             NSManagedObjectID* objectId = [self objectIdForNewObjectOfEntity:fetchRequest.entity
                                                             dynamoAttributes:dynamoAttributes
                                                                   putToCache:!fetchRequest.returnsObjectsAsFaults];
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
            NSDictionary* transformedValues = [entity nsp_dynamoDBAttributesToNativeAttributes:dynamoAttributes];
            [self.cache setObject:transformedValues forKey:objectId];
        }

        return objectId;
    }
    return nil;
}

@end
