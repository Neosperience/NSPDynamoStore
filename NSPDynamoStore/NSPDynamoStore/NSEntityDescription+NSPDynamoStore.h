//
//  NSEntityDescription+NSPDynamoStore.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <CoreData/CoreData.h>

@class NSPDynamoStoreKeyPairDescriptor;

@interface NSEntityDescription (NSPDynamoStore)

/**
 @brief Returns the DynamoDB primary keys.
 */
-(NSPDynamoStoreKeyPairDescriptor*)nsp_primaryKeys;

/**
 @brief Returns the name of the Dynamo table.
 */
-(NSString*)nsp_dynamoTableName;

/**
 @brief Returns the indices defined for the entity. The dictionary keys are the indices name and the instances are
 NSPDynamoStoreIndexDescriptor instances.
 */
-(NSDictionary*)nsp_dynamoIndices;

@end
