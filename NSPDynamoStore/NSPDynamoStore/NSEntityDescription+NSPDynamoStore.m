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

#import <AWSDynamoDB.h>

NSString* const kNSPDynamoStoreEntityHashKeyAttributeNameKey = @"NSPDynamoStoreEntityHashKeyAttributeName";
NSString* const kNSPDynamoStoreEntityRangeKeyAttributeNameKey = @"NSPDynamoStoreEntityRangeKeyAttributeName";
NSString* const kNSPDynamoStoreEntityDynamoDBTableNameKey = @"NSPDynamoStoreEntityDynamoDBTableName";

@implementation NSEntityDescription (NSPDynamoStore)

-(NSString*)nsp_dynamoHashKeyName
{
    return self.userInfo[kNSPDynamoStoreEntityHashKeyAttributeNameKey];
}

-(NSString*)nsp_dynamoRangeKeyName
{
    return self.userInfo[kNSPDynamoStoreEntityRangeKeyAttributeNameKey];
}

-(NSString*)nsp_dynamoTableName
{
    return self.userInfo[kNSPDynamoStoreEntityDynamoDBTableNameKey] ? : self.name;
}

@end
