//
//  NSPDynamoSync.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 20/05/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPDynamoSync.h"

#import "NSManagedObjectContext+NSPTask.h"

#import "BFTask+NSPUtils.h"

#import "NSPDynamoStore.h"
#import "NSPDynamoStoreKeyPair.h"
#import "NSEntityDescription+NSPDynamoStore.h"
#import "NSRelationshipDescription+NSPDynamoStore.h"

#import <NSPCoreUtils/NSArray+NSPCollectionUtils.h>
#import <NSPCoreUtils/NSDictionary+NSPCollectionUtils.h>
#import <NSPCoreUtils/NSPLogger.h>

#import <Bolts/Bolts.h>

@import CoreData;

NSString* const NSPDynamoSyncErrorDomain = @"NSPDynamoSyncError";

NSString* const NSPDynamoSyncErrorRelationshipKey = @"NSPDynamoSyncErrorRelationship";
NSString* const NSPDynamoSyncErrorFetchRequestKey = @"NSPDynamoSyncErrorFetchRequest";

NSString* const NSPDynamoSyncFetchRequestKey = @"NSPDynamoSyncFetchRequest";
NSString* const NSPDynamoSyncWipeOldObjectsKey = @"NSPDynamoSyncWipeOldObjects";

@interface NSPDynamoSyncProgressInfo : NSObject

@property (nonatomic, copy) void (^progressCallback)(float);
@property (nonatomic, assign) float startRange;
@property (nonatomic, assign) float endRange;

-(void)setAbsoluteProgress:(float)absoluteProgress;

-(instancetype)initWithStart:(float)startRange end:(float)endRange callback:(void (^)(float))progressCallback;
+(instancetype)progressInfoWithStart:(float)startRange end:(float)endRange callback:(void (^)(float))progressCallback;
-(NSArray *)progressInfoDividedIntoParts:(NSUInteger)numberOfParts;

@end

float NSPScaleProgress(float absoluteProgress, float startRange, float endRange)
{
    return (endRange - startRange) * absoluteProgress + startRange;
}

@implementation NSPDynamoSyncProgressInfo

-(void)setAbsoluteProgress:(float)absoluteProgress
{
    if (self.progressCallback) self.progressCallback(NSPScaleProgress(absoluteProgress, self.startRange, self.endRange));
}

- (instancetype)initWithStart:(float)startRange end:(float)endRange callback:(void (^)(float))progressCallback
{
    self = [self init];
    if (self) {
        self.startRange = startRange;
        self.endRange = endRange;
        self.progressCallback = progressCallback;
    }
    return self;
}

-(NSArray *)progressInfoDividedIntoParts:(NSUInteger)numberOfParts
{
    NSMutableArray* progressInfos = [NSMutableArray arrayWithCapacity:numberOfParts];
    for (NSUInteger i = 0; i < numberOfParts; i++) {
        float starRange = NSPScaleProgress((float)i / numberOfParts, self.startRange, self.endRange);
        float endRange = NSPScaleProgress((float)(i + 1) / numberOfParts, self.startRange, self.endRange);
        [progressInfos addObject:[NSPDynamoSyncProgressInfo progressInfoWithStart:starRange end:endRange callback:self.progressCallback]];
    }
    return progressInfos;
}

-(NSArray*)progressInfoWithDivisionPoints:(NSArray*)divisionPoints
{
    NSUInteger count = [divisionPoints count];
    NSParameterAssert(count > 0);
    NSMutableArray* progressInfos = [NSMutableArray arrayWithCapacity:count + 1];
    for (NSUInteger i = 0; i < count + 1; i++) {
        float startProgress = NSPScaleProgress((i == 0) ? 0.0 : [divisionPoints[i - 1] floatValue], self.startRange, self.endRange);
        float endProgress = NSPScaleProgress((i == count) ? 1.0 : [divisionPoints[i] floatValue], self.startRange, self.endRange);
        [progressInfos addObject:[NSPDynamoSyncProgressInfo progressInfoWithStart:startProgress end:endProgress callback:self.progressCallback]];
    }

    return progressInfos;
}

+(instancetype)progressInfoWithStart:(float)startProgress end:(float)endProgress callback:(void (^)(float))progressCallback
{
    return [[self alloc] initWithStart:startProgress end:endProgress callback:progressCallback];
}

@end

@interface NSPDynamoSync ()

@property (nonatomic, strong) NSManagedObjectContext* sourceContext;
@property (nonatomic, strong) NSManagedObjectContext* destinationContext;

@property (nonatomic, strong) NSPersistentStoreCoordinator* sourceCoordinator;
@property (nonatomic, strong) NSPersistentStoreCoordinator* destinationCoordinator;

@property (nonatomic, assign) BOOL stacksSetupCompleted;

@end

@implementation NSPDynamoSync

#pragma mark - Init and setup

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel*)managedObjectModel
{
    self = [self init];
    if (self) {
        self.managedObjectModel = managedObjectModel;
        self.stacksSetupCompleted = NO;
    }
    return self;
}

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
                            sourceStoreURL:(NSURL*)sourceStoreURL
                           sourceStoreType:(NSString*)sourceStoreType
                        sourceStoreOptions:(NSDictionary*)sourceStoreOptions
                       destinationStoreURL:(NSURL*)destinationStoreURL
                      destinationStoreType:(NSString*)destinationStoreType
                   destinationStoreOptions:(NSDictionary*)destinationStoreOptions
{
    self = [self initWithManagedObjectModel:managedObjectModel];
    if (self) {
        self.sourceStoreURL = sourceStoreURL;
        self.sourceStoreType = sourceStoreType;
        self.sourceStoreOptions = sourceStoreOptions;
        self.destinationStoreURL = destinationStoreURL;
        self.destinationStoreType = destinationStoreType;
        self.destinationStoreOptions = destinationStoreOptions;
    }
    return self;
}

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
                               dynamoDBKey:(NSString *)dynamoDBKey
                       destinationStoreURL:(NSURL *)destinationStoreURL
                      destinationStoreType:(NSString *)destinationStoreType
                   destinationStoreOptions:(NSDictionary *)destinationStoreOptions
{
    return [self initWithManagedObjectModel:managedObjectModel
                             sourceStoreURL:nil
                            sourceStoreType:NSPDynamoStoreType
                         sourceStoreOptions:@{ NSPDynamoStoreDynamoDBKey : dynamoDBKey }
                        destinationStoreURL:destinationStoreURL
                       destinationStoreType:destinationStoreType
                    destinationStoreOptions:destinationStoreOptions];
}

-(BOOL)setupStacksWithError:(NSError* __autoreleasing *)error
{
    self.sourceCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    self.destinationCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];

    NSError* sourceError = nil;
    [self.sourceCoordinator addPersistentStoreWithType:self.sourceStoreType
                                         configuration:nil
                                                   URL:self.sourceStoreURL
                                               options:self.sourceStoreOptions
                                                 error:&sourceError];

    if (sourceError) {
        if (error) *error = [NSPDynamoSync errorWithCode:NSPDynamoSyncErrorAddingSourceStore
                                               underlyingError:sourceError
                                                      userInfo:nil];
        return NO;
    }

    NSError* destinationError = nil;
    [self.destinationCoordinator addPersistentStoreWithType:self.destinationStoreType
                                              configuration:nil
                                                        URL:self.destinationStoreURL
                                                    options:self.destinationStoreOptions
                                                      error:&destinationError];

    if (destinationError) {
        if (error) *error = [NSPDynamoSync errorWithCode:NSPDynamoSyncErrorAddingDestinationStore
                                               underlyingError:destinationError
                                                      userInfo:nil];
        return NO;
    }

    // TODO: do automatic migration of stores if necessary

    self.sourceContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.sourceContext setPersistentStoreCoordinator:self.sourceCoordinator];

    self.destinationContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [self.destinationContext setPersistentStoreCoordinator:self.destinationCoordinator];

    return YES;
}

#pragma mark - Synchronization logic - Public methods

-(BFTask *)synchronizeWithFetchRequestParams:(NSDictionary *)fetchRequestParams progressInfo:(NSPDynamoSyncProgressInfo*)progressInfo
{
    if (!self.stacksSetupCompleted) {
        NSError* stacksSetupError = nil;
        self.stacksSetupCompleted = [self setupStacksWithError:&stacksSetupError];
        if (!self.stacksSetupCompleted) {
            return [BFTask taskWithError:stacksSetupError];
        }
    }

    NSArray* progressInfos = [progressInfo progressInfoDividedIntoParts:2];
    BFTask* synchronizeAttributesTask = [self synchronizeAttributesWithFetchRequestParams:fetchRequestParams progressInfo:progressInfos[0]];
    return [[synchronizeAttributesTask continueWithSuccessBlock:^id(BFTask *task) {
        return [self reconstructRelationshipsWithFetchRequestParams:fetchRequestParams progressInfo:progressInfos[1]];
    }] continueWithSuccessBlock:^id(BFTask *task) {
        return [self.destinationContext performBlockInBackground:^id(NSError *__autoreleasing *error) {
            NSError* saveError = nil;
            if ([self.destinationContext save:&saveError]) {
                return [BFTask taskWithDelay:0];
            } else {
                return [BFTask taskWithError:saveError];
            }
        }];
    }];
}

-(BFTask*)synchronizeWithFetchRequestParams:(NSDictionary *)fetchRequestParams progressBlock:(void (^)(float))progressBlock
{
    NSPDynamoSyncProgressInfo* progressInfo = [NSPDynamoSyncProgressInfo progressInfoWithStart:0.0 end:1.0 callback:progressBlock];
    return [self synchronizeWithFetchRequestParams:fetchRequestParams progressInfo:progressInfo];
}

-(BFTask*)synchronizeWithFetchRequestParams:(NSDictionary*)fetchRequestParams
{
    return [self synchronizeWithFetchRequestParams:fetchRequestParams progressBlock:nil];
}

#pragma mark Wipe out old objects

-(BFTask*)wipeOutTaskForEntity:(NSEntityDescription*)entity
{
    BFTask* wipeOutTask = nil;
    BOOL wipeOutOldObjects = [entity.userInfo[NSPDynamoSyncWipeOldObjectsKey] boolValue];

    if (wipeOutOldObjects) {
        NSFetchRequest* wipeFetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity.name];
        wipeFetchRequest.includesSubentities = NO;
        wipeFetchRequest.includesPropertyValues = NO;
        wipeFetchRequest.resultType = NSManagedObjectResultType;
        wipeOutTask = [[self.destinationContext executeFetchRequestInBackground:wipeFetchRequest] continueWithSuccessBlock:^id(BFTask *task) {
            for (NSManagedObject* objectToWipe in wipeOutTask.result) {
                [self.destinationContext deleteObject:objectToWipe];
            }
            return [BFTask taskWithDelay:0];
        }];
    } else {
        wipeOutTask = [BFTask taskWithDelay:0];
    }

    return wipeOutTask;
}

#pragma mark Synchronize instance attribute values

-(BFTask*)synchronizeAttributesWithFetchRequestParams:(NSDictionary*)fetchRequestParams progressInfo:(NSPDynamoSyncProgressInfo*)progressInfo
{
    NSUInteger entityCount = [self.managedObjectModel.entities count];
    __block NSUInteger entityIndex = 0;

    NSArray* tasks = [self.managedObjectModel.entities map:^id(NSEntityDescription* entity) {
        return [[self synhronizeAttributesForEntity:entity fetchRequestParams:fetchRequestParams] continueWithSuccessBlock:^id(BFTask *task) {
            [progressInfo setAbsoluteProgress:(float)entityIndex++ / entityCount];
            return task;
        }];
    }];

    return [BFTask taskForSerialCompletionOfAllTasks:tasks];
}

-(BFTask*)synhronizeAttributesForEntity:(NSEntityDescription*)entity
                     fetchRequestParams:(NSDictionary*)fetchRequestParams
{
    return [[[self wipeOutTaskForEntity:entity] continueWithSuccessBlock:^id(BFTask *task)
    {
        NSFetchRequest* fetchRequest = [self fetchRequestForEntity:entity fetchRequestParams:fetchRequestParams];
        fetchRequest.resultType = NSDictionaryResultType;

        return [self.sourceContext executeFetchRequestInBackground:fetchRequest];

    }] continueWithSuccessBlock:^id(BFTask *task) {

        NSArray* sourceInstances = task.result;

        NSArray* instanceAttributeSynchronizationTasks = [sourceInstances map:^id(NSDictionary* sourceAttributes) {
            return [[self findOrCreateDestinationInstanceForSourceAttributes:sourceAttributes entity:entity] continueWithSuccessBlock:^id(BFTask *task) {
                NSManagedObject* destinationInstance = task.result;
                // "Setter methods on queue-based managed object contexts are thread-safe"
                [sourceAttributes enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
                    [destinationInstance setValue:value forKey:key];
                }];
                return task;
            }];
        }];

        return [BFTask taskForSerialCompletionOfAllTasks:instanceAttributeSynchronizationTasks];
    }];
}

-(BFTask*)findOrCreateDestinationInstanceForSourceAttributes:(NSDictionary *)sourceAttributes entity:(NSEntityDescription*)entity
{
    NSPDynamoStoreKeyPair* keyPair = [entity nsp_primaryKeys];

    NSPredicate* destinationPredicate = [keyPair predicateForKeyObject:sourceAttributes];

    NSFetchRequest* destinationFetchRequest = [NSFetchRequest fetchRequestWithEntityName:entity.name];
    destinationFetchRequest.predicate = destinationPredicate;
    destinationFetchRequest.includesPropertyValues = NO;
    destinationFetchRequest.includesSubentities = NO;
    destinationFetchRequest.resultType = NSManagedObjectResultType;

    return [[self.destinationContext executeFetchRequestInBackground:destinationFetchRequest] continueWithSuccessBlock:^id(BFTask *task) {
        NSArray* results = task.result;
        NSManagedObject* destinationInstance = [results lastObject];
        if (!destinationInstance) {
            destinationInstance = [[NSManagedObject alloc] initWithEntity:entity insertIntoManagedObjectContext:self.destinationContext];
        }
        return [BFTask taskWithResult:destinationInstance];
    }];
}

#pragma mark Reconstruct relationships

-(BFTask*)reconstructRelationshipsWithFetchRequestParams:(NSDictionary*)fetchRequestParams
                                            progressInfo:(NSPDynamoSyncProgressInfo*)progressInfo
{
    NSUInteger entityCount = [self.managedObjectModel.entities count];
    __block NSUInteger entityIndex = 0;

    NSArray* tasks = [self.managedObjectModel.entities map:^id(NSEntityDescription* entity) {
        return [[self reconstructRelationshipsForEntity:entity fetchRequestParams:fetchRequestParams] continueWithSuccessBlock:^id(BFTask *task) {
            [progressInfo setAbsoluteProgress:(float)entityIndex++ / entityCount];
            return task;
        }];
    }];

    return [BFTask taskForSerialCompletionOfAllTasks:tasks];
}

-(BFTask*)reconstructRelationshipsForEntity:(NSEntityDescription*)entity
                         fetchRequestParams:(NSDictionary*)fetchRequestParams
{
    NSFetchRequest* fetchRequest = [self fetchRequestForEntity:entity fetchRequestParams:fetchRequestParams];
    return [[self.destinationContext executeFetchRequestInBackground:fetchRequest] continueWithSuccessBlock:^id(BFTask *task) {

        NSArray* sourceInstances = task.result;

        NSArray* reconstructRelationshipsTasks = [sourceInstances map:^id(NSManagedObject* sourceInstance) {

            return [self reconstructRelationshipsForInstance:sourceInstance];

        }];

        return [BFTask taskForSerialCompletionOfAllTasks:reconstructRelationshipsTasks];

    }];
}

-(BFTask*)reconstructRelationshipsForInstance:(NSManagedObject*)instance
{
    NSArray* relationshipTasks = [[instance.entity.relationshipsByName allValues] map:^id(NSRelationshipDescription* relationship) {

        NSFetchRequest* relationshipFetchRequest = [relationship nsp_destinationFetchRequestForSourceObject:instance];
        relationshipFetchRequest.includesPropertyValues = NO;
        relationshipFetchRequest.includesSubentities = NO;
        relationshipFetchRequest.resultType = NSManagedObjectResultType;

        if (!relationshipFetchRequest) {
            // unmodelled inverse relationships return nil fetch request
            return nil;

        } else {

            return [[instance.managedObjectContext executeFetchRequestInBackground:relationshipFetchRequest] continueWithSuccessBlock:^id(BFTask *task) {
                NSArray* destinationObjects = task.result;
                if (!relationship.isToMany) {
                    if ([destinationObjects count] > 1) {
                        NSError* error = [NSPDynamoSync errorWithCode:NSPDynamoSyncErrorTooManyRelationshipDestinations
                                                            underlyingError:nil
                                                                   userInfo:@{ NSPDynamoSyncErrorFetchRequestKey : relationshipFetchRequest,
                                                                               NSPDynamoSyncErrorRelationshipKey : relationshipFetchRequest }];
                        return [BFTask taskWithError:error];
                    }
                    id destinationObject = [destinationObjects lastObject];
                    [instance setValue:destinationObject forKey:relationship.name];
                } else {
                    NSMutableSet* relationshipProxy = [instance mutableSetValueForKey:relationship.name];
                    [relationshipProxy removeAllObjects];
                    [relationshipProxy addObjectsFromArray:destinationObjects];
                }
                return task;
            }];

        }
    }];

    return [BFTask taskForSerialCompletionOfAllTasks:relationshipTasks];
}

#pragma mark - Utilities

+(NSError*)errorWithCode:(NSPDynamoSyncErrorCode)code underlyingError:(NSError*)underlyingError userInfo:(NSDictionary*)userInfo
{
    NSMutableDictionary* mutableUserInfo = (underlyingError && !userInfo) ? [NSMutableDictionary dictionaryWithCapacity:1] : [userInfo mutableCopy];
    [mutableUserInfo setValue:underlyingError forKey:NSUnderlyingErrorKey];
    return [NSError errorWithDomain:NSPDynamoSyncErrorDomain code:code userInfo:mutableUserInfo];
}

-(NSFetchRequest*)fetchRequestForEntity:(NSEntityDescription*)entity fetchRequestParams:(NSDictionary*)fetchRequestParams
{
    NSString* fetchRequestTemplateName = entity.userInfo[NSPDynamoSyncFetchRequestKey];

    NSAssert(fetchRequestTemplateName,
             @"NSPDynamoSync: No fetch request template name defined for key %@ in the userInfo of entity %@",
             NSPDynamoSyncFetchRequestKey, entity.name);

    NSFetchRequest* fetchRequest = [self.managedObjectModel fetchRequestFromTemplateWithName:fetchRequestTemplateName
                                                                       substitutionVariables:fetchRequestParams];

    fetchRequest.includesSubentities = NO;
    fetchRequest.includesPropertyValues = YES;

    return fetchRequest;
}

@end
