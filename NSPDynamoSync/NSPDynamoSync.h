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

-(instancetype)initWithSourceContext:(NSManagedObjectContext *)sourceParentContext
                  destinationContext:(NSManagedObjectContext *)destinationParentContext;

- (BFTask*)synchronizeWithFetchRequestParams:(NSDictionary*)fetchRequestParams progressBlock:(void (^)(float progress))progressBlock;
- (BFTask*)synchronizeWithFetchRequestParams:(NSDictionary*)fetchRequestParams;

@end
