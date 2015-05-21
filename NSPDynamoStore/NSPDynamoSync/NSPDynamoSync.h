//
//  NSPDynamoSync.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 20/05/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NSPCoreUtils/NSPDefines.h>

NSP_EXTERN NSString* const NSPDynamoSyncErrorDomain;

NSP_EXTERN NSString* const NSPDynamoSyncErrorRelationshipKey;
NSP_EXTERN NSString* const NSPDynamoSyncErrorFetchRequestKey;

typedef enum : NSUInteger {
    NSPDynamoSyncErrorAddingSourceStore           = 100,
    NSPDynamoSyncErrorAddingDestinationStore,
    NSPDynamoSyncErrorTooManyRelationshipDestinations,
} NSPDynamoSyncErrorCode;

@class NSManagedObjectModel, BFTask;

@interface NSPDynamoSync : NSObject

@property (nonatomic, strong) NSManagedObjectModel* managedObjectModel;

@property (nonatomic, strong) NSURL* sourceStoreURL;
@property (nonatomic, strong) NSString* sourceStoreType;
@property (nonatomic, strong) NSDictionary* sourceStoreOptions;

@property (nonatomic, strong) NSURL* destinationStoreURL;
@property (nonatomic, strong) NSString* destinationStoreType;
@property (nonatomic, strong) NSDictionary* destinationStoreOptions;

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
                            sourceStoreURL:(NSURL*)sourceStoreURL
                           sourceStoreType:(NSString*)sourceStoreType
                        sourceStoreOptions:(NSDictionary*)sourceStoreOptions
                       destinationStoreURL:(NSURL*)destinationStoreURL
                      destinationStoreType:(NSString*)destinationStoreType
                   destinationStoreOptions:(NSDictionary*)destinationStoreOptions;

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
                               dynamoDBKey:(NSString *)dynamoDBKey
                       destinationStoreURL:(NSURL *)destinationStoreURL
                      destinationStoreType:(NSString *)destinationStoreType
                   destinationStoreOptions:(NSDictionary *)destinationStoreOptions;

- (BFTask*)synchronizeWithFetchRequestParams:(NSDictionary*)fetchRequestParams progressBlock:(void (^)(float progress))progressBlock;
- (BFTask*)synchronizeWithFetchRequestParams:(NSDictionary*)fetchRequestParams;

@end
