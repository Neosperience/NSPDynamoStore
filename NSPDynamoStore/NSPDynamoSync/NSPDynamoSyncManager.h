//
//  NSPDynamoSyncManager.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 20/04/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectModel, BFTask;

@interface NSPDynamoSyncManager : NSObject

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
                   destinationStoreOptions:(NSDictionary*)destinationStoreOptions
                        fetchRequestParams:(NSDictionary*)fetchRequestParams;

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)managedObjectModel
                               dynamoDBKey:(NSString *)dynamoDBKey
                       destinationStoreURL:(NSURL *)destinationStoreURL
                      destinationStoreType:(NSString *)destinationStoreType
                   destinationStoreOptions:(NSDictionary *)destinationStoreOptions
                        fetchRequestParams:(NSDictionary*)fetchRequestParams;

-(BFTask*)synchronize;
-(BFTask*)synchronizeWithProgressBlock:(void (^)(float progress))progressBlock;

@end
