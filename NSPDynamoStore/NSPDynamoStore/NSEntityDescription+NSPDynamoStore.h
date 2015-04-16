//
//  NSEntityDescription+NSPDynamoStore.h
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSEntityDescription (NSPDynamoStore)

/**
 @brief Returns the name of the Dynamo hash key.
 */
-(NSString*)nsp_dynamoHashKeyName;

/**
 @brief If the Dynamo primary key is made of a (hash key, range key) double then returns the name of the range key part
 of primary key, otherwise nill.
 */
-(NSString*)nsp_dynamoPrimaryRangeKeyName;

/**
 @brief Returns the name of the Dynamo table.
 */
-(NSString*)nsp_dynamoTableName;

@end
