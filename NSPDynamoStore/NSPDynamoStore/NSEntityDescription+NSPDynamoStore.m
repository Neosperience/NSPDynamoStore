//
//  NSEntityDescription+NSPDynamoStore.m
//  NSPDynamoStore
//
//  Created by Janos Tolgyesi on 31/03/15.
//  Copyright (c) 2015 Neosperience SpA. All rights reserved.
//

#import "NSEntityDescription+NSPDynamoStore.h"
#import "NSPropertyDescription+NSPDynamoStore.h"
#import "AWSDynamoDBAttributeValue+NSPDynamoStore.h"
#import "NSPDynamoStoreKeyPair.h"

#import <AWSDynamoDB/AWSDynamoDB.h>

NSString* const kNSPDynamoPrimaryKeysKey = @"NSPDynamoPrimaryKeys";
NSString* const kNSPDynamoTableNameKey = @"NSPDynamoTableName";
NSString* const kNSPDynamoIndicesKey = @"NSPDynamoIndices";

@implementation NSEntityDescription (NSPDynamoStore)

-(NSPDynamoStoreKeyPair*)nsp_primaryKeys
{
    NSString* keyPairString = self.userInfo[kNSPDynamoPrimaryKeysKey];
    NSAssert(keyPairString, @"NSPDynamoStore: The user info of the entity must contain a value for %@ key for entity: %@",
             kNSPDynamoPrimaryKeysKey, self.name);
    return [NSPDynamoStoreKeyPair keyPairWithString:keyPairString];
}

-(NSString*)nsp_dynamoTableName
{
    return self.userInfo[kNSPDynamoTableNameKey] ? : self.name;
}

-(NSDictionary*)nsp_dynamoIndices
{
    NSString* indicesString = self.userInfo[kNSPDynamoIndicesKey];
    return indicesString ? [NSPDynamoStoreKeyPair indicesWithString:indicesString] : nil;
}

@end
