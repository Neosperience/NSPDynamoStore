//
//  NSPDynamoSyncManager.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 20/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSPDynamoSyncManager.h"
#import "NSPDynamoSyncEntityMigrationPolicy.h"
#import "NSPDynamoStore.h"

#import <CoreData/CoreData.h>
#import <Bolts/Bolts.h>

@interface NSPDynamoSyncManager ()

@property (nonatomic, strong) NSMigrationManager* migrationManager;
@property (nonatomic, strong) NSMappingModel* mappingModel;
@property (nonatomic, copy) void (^progressBlock)(float progress);

@end

@implementation NSPDynamoSyncManager

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel*)managedObjectModel
{
    self = [self init];
    if (self) {
        self.managedObjectModel = managedObjectModel;
        self.migrationManager = [[NSMigrationManager alloc] initWithSourceModel:managedObjectModel
                                                               destinationModel:managedObjectModel];
        NSError* error = nil;
        [self setupMappingModelWithError:&error];
        if (error) return nil;
    }
    return self;
}

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
                            sourceStoreURL:(NSURL*)sourceStoreURL
                           sourceStoreType:(NSString*)sourceStoreType
                        sourceStoreOptions:(NSDictionary*)sourceStoreOptions
                       destinationStoreURL:(NSURL*)destinationStoreURL
                      destinationStoreType:(NSString*)destinationStoreType
                  destionationStoreOptions:(NSDictionary*)destionationStoreOptions
{
    self = [self initWithManagedObjectModel:managedObjectModel];
    if (self) {
        self.sourceStoreURL = sourceStoreURL;
        self.sourceStoreType = sourceStoreType;
        self.sourceStoreOptions = sourceStoreOptions;
        self.destinationStoreURL = destinationStoreURL;
        self.destinationStoreType = destinationStoreType;
        self.destionationStoreOptions = destionationStoreOptions;
    }
    return self;
}

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
                               dynamoDBKey:(NSString *)dynamoDBKey
                       destinationStoreURL:(NSURL *)destinationStoreURL
                      destinationStoreType:(NSString *)destinationStoreType
                  destionationStoreOptions:(NSDictionary *)destionationStoreOptions
{
    return [self initWithManagedObjectModel:managedObjectModel
                             sourceStoreURL:nil
                            sourceStoreType:NSPDynamoStoreType
                         sourceStoreOptions:@{ NSPDynamoStoreDynamoDBKey : dynamoDBKey }
                        destinationStoreURL:destinationStoreURL
                       destinationStoreType:destinationStoreType
                   destionationStoreOptions:destionationStoreOptions];
}

-(void)setupMappingModelWithError:(NSError* __autoreleasing *)error
{
    NSError* modelError = nil;
    self.mappingModel = [NSMappingModel inferredMappingModelForSourceModel:self.managedObjectModel
                                                          destinationModel:self.managedObjectModel
                                                                     error:&modelError];

    if (modelError) {
        if (error) *error = modelError;
        NSLog(@"NSPDynamoSyncManager: Error creating mapping model: %@", modelError);
        return;
    }

    for (NSEntityMapping* entityMapping in self.mappingModel.entityMappings) {
        [entityMapping setEntityMigrationPolicyClassName:NSStringFromClass([NSPDynamoSyncEntityMigrationPolicy class])];
    }
}

-(BFTask*)synchronizeWithProgressBlock:(void (^)(float progress))progressBlock
{
    self.progressBlock = progressBlock;
    return [self synchronize];
}

-(void)setProgressBlock:(void (^)(float))progressBlock
{
    if (_progressBlock) {
        [self.migrationManager removeObserver:self forKeyPath:@"migrationProgress" context:NULL];
    }

    _progressBlock = progressBlock;

    if (progressBlock) {
        [self.migrationManager addObserver:self forKeyPath:@"migrationProgress" options:0 context:NULL];
    }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.migrationManager && [keyPath isEqualToString:@"migrationProgress"]) {
        float progress = self.migrationManager.migrationProgress;
        if (self.progressBlock) {
            self.progressBlock(progress);
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

-(BFTask*)synchronize
{
    NSAssert(self.sourceStoreType && self.destinationStoreType,
             @"NSPDynamoSyncManager: You must set at least sourceStoreType and destinationStoreType before calling synchronize method.");

    BFTaskCompletionSource* taskCompletionSource = [BFTaskCompletionSource taskCompletionSource];

    dispatch_queue_t lowQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
    dispatch_async(lowQueue, ^{

        NSError* error = nil;

        [self.migrationManager migrateStoreFromURL:self.sourceStoreURL
                                              type:self.sourceStoreType
                                           options:self.sourceStoreOptions
                                  withMappingModel:self.mappingModel
                                  toDestinationURL:self.destinationStoreURL
                                   destinationType:self.destinationStoreType
                                destinationOptions:self.destionationStoreOptions
                                             error:&error];

        self.progressBlock = nil;

        if (error) {
            [taskCompletionSource setError:error];
        } else {
            [taskCompletionSource setResult:@(YES)];
        }
    });

    return taskCompletionSource.task;
}

@end
